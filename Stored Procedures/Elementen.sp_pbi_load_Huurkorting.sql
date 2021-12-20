SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Elementen].[sp_pbi_load_Huurkorting] (@Peildatum DATE = null) 
AS
/* #############################################################################################################################

EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Procedure die de boekingen ophaalt van kortingselementen en verwerkt in de volgende tabellen:
	   staedion_dm.Elementen.HuurkortingSamenvatting
	   staedion_dm.Elementen.HuurkortingDetails
	   Deze twee datasets worden gebruikt door Power BI rapport Huurkortingen en zijn gekoppeld aan staedion_dm.PowerApps.Bevindingen (middels aparte sleutel)
	   Per 20-12-2021: A810400 = 061|062|063|065|066|067|070|071|418|419|537|903 (IC HKDOORS + IC HKHERST + IC HUURKRT)
	   '
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Elementen'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_sp_pbi_load_Huurkorting';
GO
exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'Dashboard','sp_load_kpi_sp_pbi_load_Huurkorting'
GO
--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20211115 JvdW aangemaakt
20211129 JvdW feedback van Marieke, Nathalie, Petra
> Toevoegen: Toevoegen: broncode + adres + documentnr + user van creditfactuur + thuisteam
> Toevoegen: Tussenstapjes
20211220 JvdW feedback van Marieke, Nathalie, Petra verwerkt

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Elementen].[sp_pbi_load_Huurkorting]

-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_pbi_load_Huurkorting%' ORDER BY begintijd desc

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE + TESTEN: zie onderaan
--------------------------------------------------------------------------------------------------------------------------------


############################################################################################################################# */



BEGIN TRY

	SET NOCOUNT ON;
	DECLARE @Onderwerp AS NVARCHAR(100);
	DECLARE @_Bron nvarchar(100) =  OBJECT_NAME(@@PROCID);
	DECLARE @AantalRecords DECIMAL(12, 0);
	declare @start as datetime
	declare @finish as datetime

	set	@start = current_timestamp
-----------------------------------------------------------------------------------
set @onderwerp = 'Vullen ##details_prolongatieposten (incl details dus meerdere regels per eenheid/klant)';
----------------------------------------------------------------------------------- 
	DROP TABLE IF EXISTS ##details_prolongatieposten;
	DROP TABLE IF EXISTS ##BasisRapportage;
	DROP TABLE IF EXISTS ##notitie;

	TRUNCATE TABLE [Elementen].[HuurkortingDetails];
	DELETE FROM [Elementen].[HuurkortingSamenvatting] WHERE 1=1;

	;With cte_rekeningnummers
	as (select 'A810400' as rekeningnummer)	-- Huurkorting incidenteel
	,cte_element 
	as  (select Elementnr = Nr_, Omschrijving,ElementSoort, Productboekingsgroep, Administratie, Diversen, Eenmalig
	from		empire_data.dbo.[Staedion$Element] 
	where		Tabel = 0									-- algemene tabel
	and			Soort = 0
	and			Productboekingsgroep  IN ('IC HKDOORS','IC HKHERST','IC HUURKRT')
	)
	SELECT Maand = MONTH(Boekingsdatum)
			,Boekingsdatum
			,Bedrag = CONVERT(FLOAT,bedrag)
			,Elementnr = Elementnr_
			,Eenheidnr = PP.[Eenheidnr_]
			,Klantnr = [Customer No_]
			,Contractvolgnr = Contractvolgnr_
			,Stuknummer
			,[Backdated Correction]
			,[Contract Change]
			,[G_L Entry No_]
			,Bron = Iif(PP.Contractvolgnr_ <> 0, 'Contractregels', 'Aparte nota')
			,VHM.[Ingevoerd door], VHM.[Datum invoer], VHM.[Gefiatteerd door]
		INTO ##details_prolongatieposten
		FROM empire_data.dbo.Staedion$Prolongatiepost AS PP
		LEFT OUTER JOIN empire_data.dbo.[Staedion$Verhuurmutatie] AS VHM ON VHM.Eenheidnr_ = PP.Eenheidnr_
		AND VHM.Verhuurcontractvolgnr_ = PP.Contractvolgnr_
		WHERE PP.Elementnr_ IN (SELECT Elementnr FROM cte_element)
			AND YEAR(Boekingsdatum) >= 2020
	;
	SET @AantalRecords = @@rowcount

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

-----------------------------------------------------------------------------------
set @onderwerp = 'Vullen [HuurkortingSamenvatting]';
----------------------------------------------------------------------------------- 
	
	INSERT INTO [Elementen].[HuurkortingSamenvatting]
			   ([Sleutel]
			   ,[Eenheidnr]
			   ,[Klantnr]
			   ,Klantnaam
			   ,[Elementnr]
			   ,[Elementnaam]
			   ,[Adres]
			   ,[Thuisteam])
	SELECT	DISTINCT 'Huurkorting'+ '|'+ BASIS.eenheidnr+ '|'+BASIS.[Klantnr]+'|'+BASIS.[Elementnr] AS Sleutel
			, BASIS.eenheidnr
			, BASIS.[Klantnr]
			, REPLACE(CUST.[Name],' e.a','')
			, BASIS.[Elementnr]
			, (SELECT omschrijving FROM empire_data.dbo.staedion$element WHERE TABeL = 0 AND Nr_ = BASIS.Elementnr) AS Elementnaam
			, EIG.adres
			, EIG.Thuisteam
	FROM ##details_prolongatieposten AS BASIS
		LEFT OUTER JOIN staedion_dm.eenheden.Eigenschappen AS EIG
				ON EIG.Eenheidnr = BASIS.eenheidnr
				AND EIG.Einddatum IS NULL
		LEFT OUTER JOIN empire_data.dbo.customer AS CUST
		ON CUST.No_ = BASIS.[Klantnr]
			--WHERE BASIS.Eenheidnr = 'OGEH-0014039'

	SET @AantalRecords = @@rowcount

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

-----------------------------------------------------------------------------------
set @onderwerp = 'Vullen ##BasisRapportage (ophalen grootboeknr en vullen basistabel)';
----------------------------------------------------------------------------------- 
	;WITH cte_grootboek
	AS (
		SELECT GL.[G_L Account No_]
			,CTE.[G_L Entry No_]
			,GL.[Source Code]
		FROM ##details_prolongatieposten AS CTE
		JOIN empire_data.dbo.staedion$g_l_entry AS GL ON CTE.[G_L Entry No_] = GL.[Entry No_]
		)
	SELECT Grootboekrekening = GRB.[G_L Account No_]
			,BASIS.Eenheidnr
			,BASIS.Klantnr
			,Elementnr = BASIS.Elementnr
			,Elementnaam = (SELECT omschrijving FROM empire_data.dbo.staedion$element WHERE TABeL = 0 AND Nr_ = BASIS.Elementnr)
			,[Stuknummer(s)] = STRING_AGG(Stuknummer + ' ('+ GRB.[Source Code]+')', + ';' +CHAR(10) )
			,TotaalBedrag = CONVERT(FLOAT,SUM(bedrag))
			,Boekingsdatum
			,[Bedrag buiten contractregels om geprolongeerd] = CONVERT(FLOAT,NULL)
			,[Facturen buiten contractregels om geprolongeerd] = CONVERT(NVARCHAR(1000),NULL)
			,[Info verhuurmutatie] = CONVERT(NVARCHAR(1000),NULL)
			,[Info notitieveld contractregels] = CONVERT(NVARCHAR(1000),NULL)
			,Boekjaar = YEAR(BASIS.Boekingsdatum)
	INTO ##BasisRapportage
	FROM ##details_prolongatieposten AS BASIS
	LEFT OUTER JOIN cte_grootboek AS GRB ON GRB.[G_L Entry No_] = BASIS.[G_L Entry No_]
		--WHERE BASIS.Eenheidnr = 'OGEH-0014039'
		GROUP BY  GRB.[G_L Account No_]
		,BASIS.Eenheidnr
		,BASIS.Klantnr
		,BASIS.Elementnr
		,Boekingsdatum
		;
	SET @AantalRecords = @@rowcount

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')



-----------------------------------------------------------------------------------
set @onderwerp = 'Vullen [Elementen].[HuurkortingDetails]';
----------------------------------------------------------------------------------- 

	;WITH cte_grootboek
	AS (
		SELECT GL.[G_L Account No_]
			,CTE.[G_L Entry No_]
			,GL.[Source Code]
		FROM ##details_prolongatieposten AS CTE
		JOIN empire_data.dbo.staedion$g_l_entry AS GL ON CTE.[G_L Entry No_] = GL.[Entry No_]
		)
	INSERT INTO [Elementen].[HuurkortingDetails]
			   ([Sleutel]
			   ,[Grootboekrekening]
			   ,[Eenheidnr]
			   ,[Klantnr]
			   ,[Elementnr]
			   ,[Stuknummer]
			   ,[Bedrag]
			   ,[Volgnummer]
			   ,Boekdatum
			   --,[Info verhuurmutatie]
			   )
	SELECT	'Huurkorting'+ '|'+ BASIS.eenheidnr+ '|'+BASIS.[Klantnr]+'|'+BASIS.[Elementnr] AS Sleutel
			, GRB.[G_L Account No_] AS Grootboekrekening
			, BASIS.eenheidnr
			, BASIS.[Klantnr]
			, BASIS.[Elementnr]
			, BASIS.Stuknummer
			, BASIS.Bedrag
			, BASIS.Contractvolgnr
			,BASIS.Boekingsdatum
	FROM ##details_prolongatieposten AS BASIS
		LEFT OUTER JOIN cte_grootboek AS GRB ON GRB.[G_L Entry No_] = BASIS.[G_L Entry No_]
			--WHERE BASIS.Eenheidnr = 'OGEH-0014039'
		
	SET @AantalRecords = @@rowcount

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

-----------------------------------------------------------------------------------
set @onderwerp = 'Update huurkorting details - info verhuurmutatie';
----------------------------------------------------------------------------------- 

		UPDATE [Elementen].[HuurkortingDetails]
		SET [Info verhuurmutatie] = FORMAT(DET.[Datum invoer],'yyyy-MM-dd ') + DET.[Ingevoerd door] + ' fiat: '+ COALESCE(NULLIF(DET.[Gefiatteerd door],''),'?')
		FROM [Elementen].[HuurkortingDetails] AS BASIS
		JOIN ##details_prolongatieposten AS DET 
		ON	DET.eenheidnr = [BASIS].eenheidnr
			AND DET.klantnr = [BASIS].klantnr
			AND DET.elementnr = [BASIS].elementnr

	SET @AantalRecords = @@rowcount

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')




-----------------------------------------------------------------------------------
--set @onderwerp = 'Vullen ##stuknummer_incl_gebruiker en update [Facturen buiten contractregels om geprolongeerd]';
----------------------------------------------------------------------------------- 

	--DROP TABLE IF EXISTS ##stuknummer_incl_gebruiker
	--;
	--select distinct TMP.Stuknummer, Klantnr, Eenheidnr, [G_L Entry No_],Elementnr,  CONVERT(NVARCHAR(50),NULL) AS [user id]
	--INTO ##stuknummer_incl_gebruiker
	--FROM  ##details_prolongatieposten AS TMP
	--WHERE TMP.Contractvolgnr = 0
	--;
	--CREATE INDEX ##stuknummer_incl_gebruiker_i1 ON ##stuknummer_incl_gebruiker ([G_L Entry No_])
	--;
	--UPDATE BASIS
	--SET	[user id] = GL.[user id]
	--FROM ##stuknummer_incl_gebruiker AS BASIS
	--JOIN empire_data.dbo.[Staedion$g_l_entry] AS GL
	--ON GL.[Entry no_] = BASIS.[G_L Entry No_]
	--;
	--UPDATE ##BasisRapportage
	--SET [Facturen buiten contractregels om geprolongeerd] = 
	--(SELECT STRING_AGG(TMP.Stuknummer + ' ('+ TMP.[user id] + ')',  ';' +CHAR(10)) --within GROUP (ORDER BY 
	--FROM  ##stuknummer_incl_gebruiker AS TMP
	--WHERE TMP.eenheidnr = ##BasisRapportage.eenheidnr
	--AND TMP.klantnr = ##BasisRapportage.klantnr
	--AND TMP.elementnr = ##BasisRapportage.elementnr
	--)
	--;
	--SET @AantalRecords = @@rowcount

  --	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')


-----------------------------------------------------------------------------------
set @onderwerp = 'Vullen ##notitie en update [Info notitieveld contractregels]';
----------------------------------------------------------------------------------- 
	;WITH cte_volgnrs AS 
		(SELECT DISTINCT Eenheidnr, Klantnr, Elementnr, Contractvolgnr 
		FROM ##details_prolongatieposten)
		,cte_notitie
	AS (
		SELECT BASIS.Eenheidnr
			,BASIS.Klantnr
			,BASIS.Elementnr
			,BASIS.Contractvolgnr
			,ExtraInfo = FORMAT(ECL.[Date], 'yyyy-MM-dd - ') + ECL.[User ID]
			,Notitie = STRING_AGG(ECL.Comment,  ';' +CHAR(10))
		FROM cte_volgnrs AS BASIS
		JOIN empire_data.dbo.Staedion$Empire_Comment_Line AS ECL ON ECL.[Table Name] = 2
			AND ECL.[Sub no_] = BASIS.Eenheidnr
			AND ECL.[Seq No_] = BASIS.Contractvolgnr
			AND ECL.[Seq No_] <> 0
			GROUP BY Eenheidnr
			,BASIS.Klantnr
			,BASIS.Elementnr
	 		,Contractvolgnr
			,ECL.[Date]
			,ECL.[User ID])

		 SELECT Eenheidnr, Klantnr, Elementnr, Contractvolgnr, Notitie = ExtraInfo + ': ' + Notitie
		 INTO ##notitie
		 FROM cte_notitie
		;
	UPDATE [Elementen].[HuurkortingSamenvatting]
	SET [Info notitieveld contractregels geaggregeerd] = 
	(SELECT STRING_AGG(Notitie,  + ' - ' +CHAR(10))
	FROM  ##notitie AS TMP
	WHERE TMP.eenheidnr = [Elementen].[HuurkortingSamenvatting].eenheidnr
	AND TMP.klantnr = [Elementen].[HuurkortingSamenvatting].klantnr
	AND TMP.elementnr = [Elementen].[HuurkortingSamenvatting].elementnr
	GROUP BY TMP.eenheidnr, TMP.klantnr, TMP.elementnr
	)
	;
	UPDATE BASIS
	SET [Info notitieveld contractregels] = NOTIT.Notitie
	FROM [Elementen].[HuurkortingDetails] AS BASIS
	JOIN ##notitie AS NOTIT
	ON NOTIT.eenheidnr = BASIS.Eenheidnr
	AND NOTIT.klantnr = BASIS.Klantnr
	AND NOTIT.contractvolgnr = BASIS.[Volgnummer]
	;
	SET @AantalRecords = @@rowcount


  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

-----------------------------------------------------------------------------------
set @onderwerp = 'Update staedion_dm.elementen.HuurkortingDetails: [Gebruiker]';
----------------------------------------------------------------------------------- 
	UPDATE	BASIS
	SET		[Gebruiker] = TMP.[Ingevoerd door]
	FROM	staedion_dm.elementen.HuurkortingDetails AS BASIS
	JOIN	##details_prolongatieposten AS TMP
			ON TMP.eenheidnr = BASIS.Eenheidnr
			AND TMP.klantnr = BASIS.Klantnr
			AND TMP.contractvolgnr = BASIS.[Volgnummer]
	;
	SET @AantalRecords = @@rowcount
	;
	UPDATE	BASIS
	SET		[Gebruiker] = TMP.[User ID]
	FROM	staedion_dm.elementen.HuurkortingDetails AS BASIS
	JOIN	empire_data.dbo.staedion$Sales_Cr_Memo_Header AS TMP
			ON TMP.No_ = BASIS.Stuknummer
			WHERE BASIS.Volgnummer = 0
	;
	UPDATE	BASIS
	SET		[Gebruiker] = TMP.[User ID]
	FROM	staedion_dm.elementen.HuurkortingDetails AS BASIS
	JOIN	empire_data.dbo.staedion$Sales_Invoice_Header AS TMP
			ON TMP.No_ = BASIS.Stuknummer
			WHERE BASIS.Volgnummer = 0 AND BASIS.[Gebruiker] IS NULL
      ;
	UPDATE	BASIS
	SET		[Gebruiker] = TMP.[Ingevoerd door]
	FROM	staedion_dm.elementen.HuurkortingDetails AS BASIS
	JOIN	empire_data.dbo.staedion$verhuurmutatie AS TMP
			ON TMP.Eenheidnr_ = BASIS.Eenheidnr
			AND TMP.[Verhuurcontractvolgnr_] = BASIS.Volgnummer
			WHERE BASIS.[Gebruiker] IS NULL
			;

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')


-----------------------------------------------------------------------------------
set @onderwerp = 'Update ##BasisRapportage: [Info verhuurmutatie]';
----------------------------------------------------------------------------------- 

	UPDATE ##BasisRapportage
	SET [Info verhuurmutatie] = 
	(SELECT STRING_AGG(FORMAT(TMP.[Datum invoer],'yyyy-MM-dd ') + TMP.[Ingevoerd door] + ' fiat: '+ COALESCE(NULLIF(TMP.[Gefiatteerd door],''),'?'), ';' +CHAR(10))
	FROM  (SELECT DISTINCT [Datum invoer], [Ingevoerd door], [Gefiatteerd door], eenheidnr, klantnr, elementnr
			FROM ##details_prolongatieposten) AS TMP				-- anders meerdere regels met zelfde contractvolgnr: dan ook dubbele string_agg_elementen
	WHERE TMP.eenheidnr = ##BasisRapportage.eenheidnr
	AND TMP.klantnr = ##BasisRapportage.klantnr
	AND TMP.elementnr = ##BasisRapportage.elementnr
	GROUP BY TMP.eenheidnr, TMP.klantnr, TMP.elementnr
	)--WHERE Eenheidnr = 'OGEH-0001143'
	;
  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

-----------------------------------------------------------------------------------
set @onderwerp = 'Update [HuurkortingSamenvatting]: [Info verhuurmutatie geaggregeerd]';
----------------------------------------------------------------------------------- 
	UPDATE [Elementen].[HuurkortingSamenvatting]
	SET [Info verhuurmutatie geaggregeerd] = 
	(SELECT STRING_AGG(FORMAT(TMP.[Datum invoer],'yyyy-MM-dd ') + TMP.[Ingevoerd door] + ' fiat: '+ COALESCE(NULLIF(TMP.[Gefiatteerd door],''),'?'), ';' +CHAR(10))
			FROM  (SELECT DISTINCT [Datum invoer], [Ingevoerd door], [Gefiatteerd door], eenheidnr, klantnr, elementnr
					FROM ##details_prolongatieposten) AS TMP				-- anders meerdere regels met zelfde contractvolgnr: dan ook dubbele string_agg_elementen
			WHERE TMP.eenheidnr = [Elementen].[HuurkortingSamenvatting].eenheidnr
			AND TMP.klantnr = [Elementen].[HuurkortingSamenvatting].klantnr
			AND TMP.elementnr = [Elementen].[HuurkortingSamenvatting].elementnr
			GROUP BY TMP.eenheidnr, TMP.klantnr, TMP.elementnr
	)
	SET @AantalRecords = @@rowcount

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

-----------------------------------------------------------------------------------
set @onderwerp = 'Update [HuurkortingSamenvatting]: Herzieningsdatum';
----------------------------------------------------------------------------------- 

	;WITH cte_additioneel
		AS (SELECT [Customer No_] AS Klantnr,
				   [Eenheidnr_] AS Eenheidnr,
				   Herzieningsdatum,
				   ROW_NUMBER() OVER (PARTITION BY [Customer No_],
												   [Eenheidnr_]
									  ORDER BY Ingangsdatum DESC
									 ) AS Volgnr
				FROM empire_data.dbo.staedion$Additioneel AS ADDIT)		

		UPDATE BASIS
		SET Herzieningsdatum = CTE.Herzieningsdatum
		FROM staedion_dm.elementen.HuurkortingSamenvatting AS BASIS
		JOIN cte_additioneel AS CTE
		ON CTE.Eenheidnr = BASIS.Eenheidnr
		AND CTE.Klantnr = BASIS.Klantnr
		AND CTE.Volgnr = 1;

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

	set	@finish = CURRENT_TIMESTAMP

		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@Begintijd = @start
					,@Eindtijd = @finish
					,@DatabaseObject = @_Bron
					,@Variabelen = null
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = 1



END TRY
BEGIN CATCH

	set	@finish = CURRENT_TIMESTAMP
		DECLARE @_ErrorProcedure AS NVARCHAR(255) = ERROR_PROCEDURE()
		DECLARE @_ErrorLine AS INT = ERROR_LINE()
		DECLARE @_ErrorNumber AS INT = ERROR_NUMBER()
		DECLARE @_ErrorMessage AS NVARCHAR(255) = LEFT(ERROR_MESSAGE(),255)
    

		--insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],BeginTijd, Eindtijd,TijdMelding, ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
		--select	[Databaseobject] = @LogboekTekst
		--		,BeginTijd = @start	
		--		,Eindtijd = null	
		--		,TijdMelding = @finish
		--			,@DatabaseObject = @LogboekTekst -- @_Bron
		--		,ErrorProcedure = ERROR_PROCEDURE() 
		--		,ErrorNumber = ERROR_NUMBER()
		--		,ErrorLine = ERROR_LINE()
		--		,ErrorMessage = ERROR_MESSAGE() 

	EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@DatabaseObject = @_Bron
					, @Variabelen = null
					, @Begintijd = @start
					, @Eindtijd = @finish
					, @ErrorProcedure =  @_ErrorProcedure
					, @ErrorLine = @_ErrorLine
					, @ErrorNumber = @_ErrorNumber
					, @ErrorMessage = @_ErrorMessage

END CATCH

;




/* ##################################################################################################################

-----------------------------------------------------------------------------------------------------------------
TESTEN
-----------------------------------------------------------------------------------------------------------------
-- Unieke regel per klant, eenheid, element
select	eenheidnr, klantnr, elementnr,boekjaar, count(*)
-- select top 10 * 
from	staedion_dm.Elementen.Huurkorting
where eenheidnr = 'OGEH-0001143'
group by eenheidnr, klantnr, elementnr,boekjaar
having count(*)>1

-- Check consistentie met grootboek
SELECT  Boekdatum = GL.[Posting Date], Rekeningnr = GA.No_, Rekeningnaam = GA.[Name], Broncode = GL.[Source Code],Productboekingsgroep = GL.[Gen_ Prod_ Posting group] , Bedrag = CONVERT(FLOAT,SUM(Amount))
,[Soort-boekingen] = case GL.[Source Code] when 'DAEBRC' then 'Overig' when 'AFSLWVREK' then 'Overig' when 'EXT_Beheer' then 'Overig' else 'Saldo grootboek' end
FROM empire_data.dbo.staedion$g_l_entry AS GL
LEFT OUTER JOIN empire_data.dbo.staedion$G_L_account AS GA
ON GA.No_ = GL.[G_L Account No_]
WHERE [G_L Account No_] = 'A810400' AND YEAR([Posting Date]) >= 2020
GROUP BY  GL.[Posting Date], GA.No_,GA.[Name], GL.[Source Code], GL.[Gen_ Prod_ Posting group]
;


-----------------------------------------------------------------------------------------------------------------
TESTEN: Detailcheck
-----------------------------------------------------------------------------------------------------------------
DECLARE @HRD AS NVARCHAR(20) = 'HRDR-0011402'


SELECT TOP 10 ADDIT.* 
FROM empire.empire.dbo.[Staedion$Additioneel] AS ADDIT
where ADDIT.[Customer No_] = @HRD
;
-- looptijd
select ADDIT.Looptijd, BASIS.*
-- select	count(*)
from	staedion_dm.Elementen.Huurkorting as BASIS
left outer join empire_Data.dbo.[Staedion$Additioneel] AS ADDIT
on ADDIT.[Customer No_] = BASIS.Klantnr
and ADDIT.[Eenheidnr_] = BASIS.Eenheidnr
where nullif(Looptijd,'')  is not null;

SELECT TOP 10  *
FROM  empire.empire.dbo.[staedion$empire comment line]
WHERE [Seq No_] = 999999599
AND [Table Name] = 2
AND [Sub no_] = 'OGEH-0045402'


SELECT TOP 10 PP.*, ECL.* 
FROM empire.empire.dbo.[Staedion$Prolongatiepost] AS PP
LEFT OUTER JOIN empire.empire.dbo.[staedion$empire comment line] AS ECL
ON ECL. [Table Name] = 2
AND ECL.[Sub no_] = PP.Eenheidnr_
AND ECL.[Seq No_] = PP.Contractvolgnr_
WHERE Elementnr_ = '066'
AND Boekingsdatum  BETWEEN '20210901' AND '20211031'



SELECT TOP 10 EL.* 
FROM empire.empire.dbo.[Staedion$Contract] AS CO
LEFT OUTER JOIN empire.empire.dbo.[staedion$element] AS EL
ON CO.Eenheidnr_ = EL.Eenheidnr_ 
AND CO.Volgnr_ = EL.Volgnummer
WHERE EL.Nr_ = '066'
AND CO.Eenheidnr_ = 'OGEH-0038006'
-----------------------------------------------------------------------------------------------------------------
DDL
-----------------------------------------------------------------------------------------------------------------
USE staedion_dm
go
;
DROP TABLE IF EXISTS staedion_dm.[Elementen].[HuurkortingDetails]
GO
DROP TABLE IF EXISTS staedion_dm.PowerApps.[Bevindingen]
GO
DROP TABLE IF EXISTS staedion_dm.[Elementen].[HuurkortingSamenvatting]
GO
DROP VIEW IF EXISTS [Elementen].[vw_Huurkortingen]
GO

USE [staedion_dm]
GO
CREATE TABLE [Elementen].[HuurkortingSamenvatting](
	[Sleutel] VARCHAR(50) PRIMARY KEY,  -- referencing PowerApps.Bevindingen		[Huurkorting|OGEH-1234567|KLNT-1234567|999]		-- unieke sleutel per onderwerp nodig, dan ook 
	[Eenheidnr] [VARCHAR](20) NULL,
	[Klantnr] [VARCHAR](20) NULL,
	[Klantnaam] NVARCHAR(50) NULL,
	[Elementnr] [VARCHAR](10) NULL,
	[Elementnaam] [VARCHAR](50) NULL,
	[Adres] [NVARCHAR](92) NULL,
	[Thuisteam] [VARCHAR](50) NULL,
	[Info verhuurmutatie geaggregeerd]  NVARCHAR(2000),
	[Info notitieveld contractregels geaggregeerd] NVARCHAR(2000),
	Herzieningsdatum date
	)
GO

CREATE TABLE [Elementen].[HuurkortingDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Sleutel] VARCHAR(50) REFERENCES Elementen.HuurkortingSamenvatting(Sleutel) ON DELETE CASCADE,	-- referencing Huurkorting Samenvatting
	[Grootboekrekening] [VARCHAR](20) NULL,
	[Eenheidnr] [VARCHAR](20) NULL,
	[Klantnr] [VARCHAR](20) NULL,
	[Elementnr] [NVARCHAR](10) NULL,
	[Stuknummer] [VARCHAR](20) NULL,
	[Boekdatum]  DATE NULL,
	[Bedrag] Decimal(8,2) NULL,
	[Volgnummer] INT NULL,
	[Info notitieveld contractregels] NVARCHAR(2000),
	[Info verhuurmutatie] [NVARCHAR](1000) NULL,
	[Gebruiker] NVARCHAR(50) null
	)
GO
CREATE INDEX i1_HuurkortingDetails ON [Elementen].[HuurkortingDetails] (sleutel)


ALTER TABLE [PowerApps].[Bevindingen] ADD [Voorlopige einddatum] date 

CREATE TABLE [PowerApps].[Bevindingen](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Sleutel] VARCHAR(50),															-- REFERENCES Elementen.HuurkortingSamenvatting(Sleutel),	-- referencing Huurkorting Samenvatting, wordt via PowerApps automatisch gevuld, alleen werkt Truncate table dan niet meer
	[Gebruiker] [nvarchar](50) NULL,												-- wordt via PowerApps automatisch gevuld
	[Tijdstip] [datetime] NULL,														-- wordt via PowerApps automatisch gevuld
	[Onderwerp] [nvarchar](40) NULL,												-- wordt via PowerApps automatisch gevuld ?
	[Opmerking] [nvarchar](510) NULL,												-- door geautoriseerde gebruiker zelf in te vullen
	[Prioriteit] bit NULL DEFAULT 0
	)
GO
CREATE INDEX i1_Bevindingen ON [PowerApps].[Bevindingen] (sleutel)

USE [staedion_dm]
GO

create VIEW Elementen.vw_Huurkortingen												-- in PBI opnemen 
as
SELECT SAM.[Sleutel], -- In PBI labellen als primary key + In PowerApps meenemen
       SAM.[Eenheidnr],
       SAM.[Eenheidnr] + ': ' + SAM.[Adres] AS Eenheid,
       SAM.[Klantnr] + ': ' + SAM.[Klantnaam] AS Klant,
       SAM.[Klantnr],
       SAM.[Klantnaam],
       SAM.[Elementnr] + ': ' + SAM.[Elementnaam] AS Element,
       SAM.[Elementnr],
       SAM.[Elementnaam],
       SAM.[Adres],
       SAM.[Thuisteam],
       DET.[Grootboekrekening],
       DET.[Boekdatum],
       DET.[Stuknummer],
       DET.[Bedrag],
       DET.[Volgnummer],
       DET.[Info verhuurmutatie],
       BEV.Opmerking, -- In PowerApps opnemen
       BEV.Onderwerp, -- In PowerApps opnemen
       BEV.Tijdstip,
       BEV.Gebruiker,
       BEV.Prioriteit,
	   BEV.[Voorlopige einddatum],
	   IIF(NULLIF(DET.[Info notitieveld contractregels],'') IS NULL,null,1) AS [Teller info contractregel],
	   IIF(NULLIF(SAM.Herzieningsdatum,'17530101') IS NULL,'Niet ingevuld','Wel ingevuld') AS [Teller herzieningsdatum],
       DET.[Info notitieveld contractregels],
	   SAM.[Info notitieveld contractregels geaggregeerd],
       SAM.[Info verhuurmutatie geaggregeerd],
       NULLIF(SAM.Herzieningsdatum,'17530101') AS Herzieningsdatum,
	   DET.[Gebruiker] AS [Verwerkt door],
	   IIF(DET.[Volgnummer] <> 0, 'Contractregels', 'Aparte nota') AS [Bron],
	   '<a href="'+empire_staedion_data.empire.fnEmpireLink('Staedion', 11024012, 'Soort=1,Eenheidnr.='+SAM.[Eenheidnr]+'', 'view')+'">'+SAM.[Eenheidnr]+'</a>' AS [Hyperlink Empire]
FROM Elementen.HuurkortingSamenvatting AS SAM
    LEFT OUTER JOIN Elementen.HuurkortingDetails AS DET
        ON DET.Sleutel = SAM.Sleutel
    LEFT OUTER JOIN [PowerApps].[Bevindingen] AS BEV
        ON BEV.Sleutel = SAM.Sleutel
		--WHERE 1=0
		


################################################################################################################## */
GO
EXEC sp_addextendedproperty N'MS_Description', N'Procedure die de boekingen ophaalt van kortingselementen en verwerkt in de volgende tabellen:
	   staedion_dm.Elementen.HuurkortingSamenvatting
	   staedion_dm.Elementen.HuurkortingDetails
	   Deze twee datasets worden gebruikt door Power BI rapport Huurkortingen en zijn gekoppeld aan staedion_dm.PowerApps.Bevindingen (middels aparte sleutel)
	   Per 20-12-2021: A810400 = 061|062|063|065|066|067|070|071|418|419|537|903 (IC HKDOORS + IC HKHERST + IC HUURKRT)
	   ', 'SCHEMA', N'Elementen', 'PROCEDURE', N'sp_pbi_load_Huurkorting', NULL, NULL
GO
