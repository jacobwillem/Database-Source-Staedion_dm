SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE     PROCEDURE [Grootboek].[sp_load_specificatie_grootboekposten_jur_eig] (
	@_DatumVanaf DATE = NULL,
	@_DatumTotenMet DATE = NULL, 
	@Eigenaar NVARCHAR(100) =  'Staedion VG Holding BV',
	@Testversie BIT = 0
)
AS
/* #################################################################################################################
VAN			Jaco
BETREFT		Ophalen grootboekposten dan wel toegerekende posten die betrekking hebben op bepaalde juridisch eigenaar + voorbereiden memoriaalboeking
ZIE			21 06 581 Automatiseren waar mogelijk - afrekening exploitatie WOM en SVGH
NB			Omwille van diverse stappen/controles: stored procedure
----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210825 JvdW Script aangemaakt
20210831 JvdW Uitbreidingen
				> Datum begin jaar en einde huidige 
20210902 JvdW Memoriaal boeking toevoegen
				use staedion_dm
				go
				create table rapport.Memoriaal_Jur_Eig 
				(
				Boekdatum			date,
				[Documentnr.]		nvarchar(20),
				Rekeningsoort		nvarchar(50) default 'Grootboekrekening',
				[Rekeningnr.]		nvarchar(20),
				Kostencode			nvarchar(20) default '', 
				Omschrijving		nvarchar(50) default 'Afrekening',
				Bedrag				decimal(12,2),
				[Kostenplaats code] nvarchar(20) default '', 
				[Clusternr.]		nvarchar(20) default '', 
				[Eenheidnr.]		nvarchar(20),
				Opmerking			nvarchar(50)
				)
20211026 JvdW 
> 1 bestand voor WOM en VG Holding + evt toevoegen 
> Toegerekende posten loopt nu standaard mee
> Performance issue mbt minder relevante velden uitgeschakeld
> Eenheden waarvan Empire niet meer weet dat ze in het verleden waren van Vastgoed Holding (door deze informatie te wissen ipv met datum te beeindigen): handmatig toegevoegd + signalering
EVT NOG DOEN: als Snapshot ELS niet beschikbaar is per @Datum-variabele, dan gaat het mis


----------------------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------------------
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig]
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig] @_DatumVanaf = '20210101',@_DatumTotenMet = '20210831' , @Eigenaar = 'Staedion VG Holding BV', @Testversie = 0
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig] @Testversie = 1
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig] @Eigenaar = 'WOM'

select top 100 * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
----------------------------------------------------------------------------------------------------------------
PERFORMANCE
----------------------------------------------------------------------------------------------------------------
Missing Index Details from SQLQuery5.sql - s-dwh2012-db.staedion_dm (STAEDION\JVDW)
The Query Processor estimates that implementing the following index could improve the query cost by 69.8558%.
USE [staedion_dm]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Grootboek].[Grootboekposten] ([Boekdatum])
INCLUDE ([Volgnummer],[Rekening_id],[Document nr],[Dimensiewaarde 1_id],[Productboekingsgroep_id]
,[Btwproductboekingsgroep_id],[Bedrag incl. verplichting],[Btw bedrag incl. verplichting],[Gebruiker],[Bron_id],[Eenheidnr])
GO

----------------------------------------------------------------------------------------------------------------
Detailcheck
----------------------------------------------------------------------------------------------------------------
DECLARE @Nr AS BIGINT = 126290315
;
select * from ##posten1 where Volgnummer = @Nr;
select * from ##posten2 where Volgnummer = @Nr
;

with cte_eenheden_juridisch as 
(select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
	from staedion_dm.eenheden.Meetwaarden as MW
     JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
	 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
	 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
	where peildatum = '20210831' 
	and [Juridisch eigenaar] =  'Staedion VG Holding BV'
	union
select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
	from staedion_dm.eenheden.Meetwaarden as MW
     JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
	 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
	 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
	where peildatum = '20201231' 
	and [Juridisch eigenaar] =  'Staedion VG Holding BV'
	)

select POST.*
FROM staedion_dm.Grootboek.[Toegerekende grootboekposten HANDM]  AS POST
JOIN staedion_dm.Grootboek.Rekening AS REK ON REK.Rekening_id = POST.Rekening_id
--left outer join staedion_dm.Grootboek.Dimensiewaarden1 as DIM on DIM.[Dimensiewaarde 1_id] = POST.[Dimensiewaarde 1_id]
--left outer join staedion_dm.Grootboek.Btwproductboekingsgroep as BTW on BTW.Btwproductboekingsgroep_id = POST.Btwproductboekingsgroep_id
--left outer join staedion_dm.Grootboek.Productboekingsgroep as PROD on PROD.Productboekingsgroep_id = POST.Productboekingsgroep_id
--left outer join staedion_dm.Grootboek.Bronnen as BR on BR.Bron_id = POST.Bron_id
left outer join cte_eenheden_juridisch as CTE on CTE.Eenheidnr = POST.Eenheidnr
OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(POST.Eenheidnr) AS CL
--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](POST.Eenheidnr, GETDATE()) KENM
WHERE 	 POST.Boekdatum BETWEEN '20210101' and '20211231'
	and POST.Regeltype = 'Toerekening'
and [Volgnummer grootboekpost] = @Nr
;
SELECT [G_L Entry No_]
	,[G_L Account No_]
	,[Entry Type]
	,Amount
	,[Allocated Amount]
FROM empire_data.dbo.Staedion$Allocated_G_L_Entries
WHERE [G_L Entry No_] = @Nr
;
SELECT [Entry No_]
	,[G_L Account No_]
	,sum(Amount)
FROM empire_data.dbo.Staedion$G_L_Entry
WHERE [Entry No_] = @Nr
GROUP BY [Entry No_]
	,[G_L Account No_]
;
SELECT [G_L Entry No_]
	,[G_L Account No_]
	,[Entry Type]
	,Amount = sum(Amount)
	,[Allocated Amount] = sum([Allocated Amount])
FROM empire_data.dbo.Staedion$Allocated_G_L_Entries
WHERE [G_L Entry No_] = @Nr
GROUP BY [G_L Entry No_]
	,[G_L Account No_]
	,[Entry Type]
;

################################################################################################################# */


-- In SSRS werden velden vreemd genoeg niet herkend, door d
 DECLARE @FMTONLY BIT;  
  
 IF 1 = 0  
 BEGIN  
  SET @FMTONLY = 1;  
  SET FMTONLY OFF;  
 END  


--NB Transaction/Try Catch kreeg ik niet werkend in combinatie met SSRS + dataset in 1 transactie verwerken (ipv parallel datasets verwerken), vandaar uitgecommentarieerd
--SET NOCOUNT, XACT_ABORT ON;

--TBV SSRS snel herkennen velden bijv
	IF @Testversie = 1 
		GOTO _Label_Select_Test

--BEGIN TRY
--BEGIN TRANSACTION;

	-- Diverse variabelen
	DECLARE @DatumVanaf DATE
	DECLARE @DatumTotenMet DATE
	declare @start as datetime
	declare @finish as datetime
	DECLARE @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: ';
	DECLARE @VersieNr NVARCHAR(80) = ' - JvdW Versie 5 20211019'	;
	SET @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
    DECLARE @Bericht NVARCHAR(255);
    DECLARE @Onderwerp NVARCHAR(100);
	DECLARE @AantalRecords DECIMAL(12, 0);

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN (periode: ' + format(@DatumVanaf, 'dd-MM-yyyy') + ' - '+ format(@DatumTotenMet, 'dd-MM-yyyy' + ')');

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Variabelen';
	----------------------------------------------------------------------------------- 
	set	@start = current_timestamp

	If @_DatumVanaf is null 
		set @DatumVanaf = datefromparts(year(getdate()),1,1)
	If @_DatumVanaf is NOT NULL 
		SET @DatumVanaf = @_DatumVanaf

	If @_DatumTotEnMet is null 
		set @DatumTotEnMet =  eomonth(getdate());
	If @_DatumTotEnMet is NOT NULL 
		SET @DatumTotEnMet = @_DatumTotEnMet

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Eenheden opvoeren, incl evt gewist in Empire - handmatig toevoegen !!';
	----------------------------------------------------------------------------------- 
		Truncate table staedion_dm.rapport.Eenheden_Jur_Eig
		;

		;WITH cte_eenheden
		AS (
			SELECT eenheidnr
				,straat
				,huisnummer
				,toevoegsel
				,[Juridisch eigenaar]
				,clusternummer
				,clusternaam
				,corpodata_type
				,datum_in_exploitatie =  datum_in_exploitatie 
				,datum_uit_exploitatie =   datum_uit_exploitatie 
				,[In Exploitatie]
			-- select distinct clusternummer
			FROM empire_staedion_data.dbo.els
			WHERE datum_gegenereerd = (
					SELECT max(datum_gegenereerd)
					FROM empire_staedion_data.dbo.els
					)
				AND clusternummer IN (
					SELECT DISTINCT clusternummer
					FROM empire_staedion_data.dbo.els
					WHERE datum_gegenereerd = (
							SELECT max(datum_gegenereerd)
							FROM empire_staedion_data.dbo.els
							)
						AND [Juridisch eigenaar] LIKE '%'+ @Eigenaar + '%'
					)
			)
		SELECT *, Eigenaar = @Eigenaar
		INTO #cte_eenheden
		FROM cte_eenheden;
		
			SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Eenheden opvoeren - vervolg';
	----------------------------------------------------------------------------------- 
		INSERT INTO staedion_dm.rapport.Eenheden_Jur_Eig (
			[eenheidnr]
			,[straat]
			,[huisnummer]
			,[toevoegsel]
			,[Juridisch eigenaar]
			,[clusternummer]
			,[clusternaam]
			,[corpodata_type]
			,[datum_in_exploitatie]
			,[datum_uit_exploitatie]
			,[In Exploitatie]
			,[Begindatum juridisch eigenaar]
			,[Einddatum juridisch eigenaar]
			,[Begindatum juridisch eigenaar ELS]
			,[Einddatum juridisch eigenaar ELS]
			,[Saldo_Huur_Binnen_Periode]
			,[Saldo_Overig_Binnen_Periode]
			,[Saldo_Buiten_Periode]
			,[Aanvullende opmerking 1]
			,[Classificatie]
			,[Opmerking]
			,[Betreft]
			)
		SELECT eenheidnr
			,straat
			,huisnummer
			,toevoegsel
			,[Juridisch eigenaar]
			,clusternummer
			,clusternaam
			,corpodata_type
			,datum_in_exploitatie =   datum_in_exploitatie 
			,datum_uit_exploitatie =   datum_uit_exploitatie 
			,[In Exploitatie]
			,[Begindatum juridisch eigenaar] = convert(DATE, NULL)
			,[Einddatum juridisch eigenaar] = convert(DATE, NULL)
			,[Begindatum juridisch eigenaar ELS] = convert(DATE, NULL)
			,[Einddatum juridisch eigenaar ELS] = convert(DATE, NULL)
			,Saldo_Huur_Binnen_Periode = convert(DECIMAL(12, 2), NULL)
			,Saldo_Overig_Binnen_Periode = convert(DECIMAL(12, 2), NULL)
			,Saldo_Buiten_Periode = convert(DECIMAL(12, 2), NULL)
			,[Aanvullende opmerking 1] = convert(NVARCHAR(40), NULL)
			,Classificatie = convert(NVARCHAR(100), NULL)
			,Opmerking = iif(1 < (
					SELECT count(DISTINCT [Juridisch eigenaar])
					FROM #cte_eenheden AS TWEE
					WHERE EEN.clusternummer = TWEE.clusternummer
					), 'Let op: gesplitst cluster', '')
			,@Eigenaar
		FROM #cte_eenheden as EEN
		ORDER BY Eigenaar
			,clusternummer
			,[Juridisch eigenaar];

		SELECT Eenheidnr = BEH.[Realty Object No_]
			,[Begindatum] = BEH.[Start Date]
			--,BEH.[Owner]
			,Eigenaar = CONT.[Name]
			,Einddatum = coalesce(dateadd(d, - 1, lead(BEH.[Start Date]) OVER (
						PARTITION BY BEH.[Realty Object No_] ORDER BY [Start Date] ASC
						)), '20991231')
			,_Volgnr = row_number() OVER (
				PARTITION BY BEH.[Realty Object No_] ORDER BY [Start Date] ASC
				)
			,_hierna = lead(CONT.[Name]) OVER (
				PARTITION BY BEH.[Realty Object No_] ORDER BY [Start Date] ASC
				)
		INTO #JurEig
		FROM empire_data.dbo.[Staedion$Realty_Object_Owner_Supervisor] AS BEH
		--FROM empire.empire.dbo.[Staedion$Realty Object Owner_Supervisor] AS BEH WITH (NOLOCK)
		JOIN empire_data.dbo.[Contact] AS CONT ON CONT.No_ = BEH.[Owner]
		WHERE BEH.[Realty Object No_] IN (
				SELECT eenheidnr
				FROM staedion_dm.rapport.Eenheden_Jur_Eig
				);

		UPDATE staedion_dm.rapport.Eenheden_Jur_Eig
		SET [Begindatum juridisch eigenaar] = JUR.[Begindatum]
			,[Einddatum juridisch eigenaar] = JUR.Einddatum
		FROM staedion_dm.rapport.Eenheden_Jur_Eig AS BASIS
		JOIN #JurEig AS JUR ON JUR.Eenheidnr = BASIS.Eenheidnr
			AND JUR.Eigenaar LIKE '%' + @Eigenaar + '%';

		UPDATE staedion_dm.rapport.Eenheden_Jur_Eig
		SET [Begindatum juridisch eigenaar ELS] = (
				SELECT min(datum_gegenereerd)
				FROM empire_staedion_data.dbo.els AS ELS
				WHERE ELS.[Juridisch eigenaar] LIKE '%' + @Eigenaar + '%'
					AND ELS.Eenheidnr = staedion_dm.rapport.Eenheden_Jur_Eig.Eenheidnr
				);


		UPDATE staedion_dm.rapport.Eenheden_Jur_Eig
		SET [Einddatum juridisch eigenaar ELS] = (
				SELECT max(datum_gegenereerd)
				FROM empire_staedion_data.dbo.els AS ELS
				WHERE ELS.[Juridisch eigenaar] LIKE '%' + @Eigenaar + '%'
					AND ELS.Eenheidnr = staedion_dm.rapport.Eenheden_Jur_Eig.Eenheidnr
				);

		UPDATE staedion_dm.rapport.Eenheden_Jur_Eig
		SET [Einddatum juridisch eigenaar ELS] = '20991231'
		WHERE [Einddatum juridisch eigenaar ELS] = (
				SELECT max(datum_gegenereerd)
				FROM empire_staedion_data.dbo.els AS ELS
				);

		DECLARE @BegindatumJur AS DATE = '20200101';
		DECLARE @EinddatumJur AS DATE = '20210624';
		DECLARE @Opmerking AS NVARCHAR(100) = 'Ontbrekende info Empire-obv mail Brenda';
		DECLARE @JuridischEigenaar AS NVARCHAR(50) = 'Staedion VG Holding BV';

		Drop TABLE IF EXISTS #HandmatigUpdateOfInsert;

		CREATE TABLE #HandmatigUpdateOfInsert
		(Eenheidnr NVARCHAR(20));

		INSERT INTO #HandmatigUpdateOfInsert (Eenheidnr) 
		VALUES ('OGEH-0057264'),('OGEH-0057477'),('OGEH-0057446'),('OGEH-0057356'),('OGEH-0057479'),('OGEH-0057499'),
					('OGEH-0057355'),('OGEH-0057354'),('OGEH-0057448'),('OGEH-0057521'),('OGEH-0057478'),('OGEH-0057514'),('OGEH-0057527'),('OGEH-0057333'),
					('OGEH-0057491'),('OGEH-0057451'),('OGEH-0057437'),('OGEH-0057481'),('OGEH-0057515'),('OGEH-0057528'),('OGEH-0061278'),('OGEH-0057438'),
					('OGEH-0057334'),('OGEH-0057353'),('OGEH-0057480'),('OGEH-0057449'),('OGEH-0057493'),('OGEH-0057351'),('OGEH-0057500'),('OGEH-0057492'),
					('OGEH-0057352'),('OGEH-0057450'),('OGEH-0057482'),('OGEH-0061104'),('OGEH-0061261'),('OGEH-0057436'),('OGEH-0057447'),('OGEH-0057516'),
					('OGEH-0057445'),('OGEH-0057335')

		
		update staedion_dm.rapport.Eenheden_Jur_Eig 
		set [Begindatum juridisch eigenaar] = '20200101'
			,[Einddatum juridisch eigenaar] = '20210624'
			,[Aanvullende opmerking 1] = 'Ontbrekende info Empire-obv mail Brenda'
			,[Juridisch eigenaar] = 'Staedion VG Holding BV'
		where [Begindatum juridisch eigenaar] is null 
		and [Einddatum juridisch eigenaar] is NULL
		and Eenheidnr in (SELECT Eenheidnr FROM #HandmatigUpdateOfInsert)
		;
		INSERT INTO staedion_dm.rapport.Eenheden_Jur_Eig (
				[eenheidnr]
				,[straat]
				,[huisnummer]
				,[toevoegsel]
				,[datum_in_exploitatie]
				,[datum_uit_exploitatie]
				,[Begindatum juridisch eigenaar]
				,[Einddatum juridisch eigenaar]
				,[Aanvullende opmerking 1]
				,[Juridisch eigenaar]
				)
			SELECT TMP.eenheidnr
				,OGE.straatnaam
				,OGE.huisnr_
				,OGE.toevoegsel
				,datum_in_exploitatie =  oge.[begin exploitatie] 
				,datum_uit_exploitatie =  COALESCE(NULLIF(oge.[einde exploitatie],'17530101'),'20991231') 
				,[Begindatum juridisch eigenaar] = @BegindatumJur
				,[Einddatum juridisch eigenaar] = @EinddatumJur
				,[Aanvullende opmerking 1] = @Opmerking
				,@JuridischEigenaar
			FROM #HandmatigUpdateOfInsert AS TMP
			JOIN empire_data.dbo.Staedion$oge AS OGE
			ON OGE.Nr_ = TMP.Eenheidnr
			WHERE TMP.Eenheidnr NOT IN (SELECT eenheidnr FROM staedion_dm.rapport.Eenheden_Jur_Eig)
			;
			SET @AantalRecords = @@rowcount
			;
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Aanpassen eiddatum juridisch eigenaar - einddatum exploitatie eenheid';
	----------------------------------------------------------------------------------- 
		-- UPDATE [Einddatum juridisch eigenaar]
		UPDATE BASIS
		SET [Einddatum juridisch eigenaar] = BASIS.datum_uit_exploitatie,
			Opmerking = 'NB eindedatum jur. = uit exploitatiedatum'
		FROM staedion_dm.Rapport.Eenheden_Jur_Eig AS BASIS
		WHERE [Juridisch eigenaar] LIKE '%' + @Eigenaar + '%'
			  AND COALESCE(NULLIF(BASIS.datum_uit_exploitatie, ''), '20991231') < BASIS.[Einddatum juridisch eigenaar]
			  ;

			SET @AantalRecords = @@rowcount
			;
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;


	-----------------------------------------------------------------------------------
	set @Onderwerp = 'BEGIN (periode: ' + format(@DatumVanaf, 'dd-MM-yyyy') + ' - '+ format(@DatumTotenMet, 'dd-MM-yyyy' + ') - overhalen toegerekende posten (gemakshalve hierin opgenomen)');
	----------------------------------------------------------------------------------- 
	Truncate table staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig;
	
	DROP TABLE IF exists ##Posten1; -- voor grootboekposten
	DROP TABLE IF exists ##Posten2; -- voor toegerende posten
	DROP TABLE IF EXISTS #JurEig;
	DROP TABLE IF EXISTS #cte_eenheden;

				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-------------------------------------------------------------------------------------
	set @Onderwerp = 'Alle regels uit grootboekposten: ##Posten1';
	------------------------------------------------------------------------------------- 
	-- 1: alle regels uit grootboekposten
	with cte_eenheden_juridisch as 
		(SELECT Eenheidnr FROM staedion_dm.rapport.Eenheden_Jur_Eig)
	SELECT Rekeningnr = REK.Rekeningnr
		,Rekeningnaam = REK.Grootboekrekening
		,Bedrag = CONVERT(FLOAT, POST.[Bedrag incl. verplichting])
		,Eenheidnr = POST.Eenheidnr
		,Documentnr = POST.[Document nr]
		,Boekdatum = POST.Boekdatum
		,Omschrijving = POST.Omschrijving
		,Kostenplaats = DIM.Code + ' '+ DIM.Dimensiewaarde
		,Volgnummer = POST.Volgnummer
		,[Productboekingsgroep ] = PROD.Productboekingsgroep
		,[Broncode] = BR.[Code]
		,[BTW-poductboekingsgroep] = BTW.Btwproductboekingsgroep
		,[BTW-bedrag] = convert(float,POST.[Btw bedrag incl. verplichting])
	--	,KENM.[Corpodata type]
		--,CTE.[Corpodata type]
		,Cluster = CL.Clusternr
	--	,KENM.[Administratief eigenaar]
		--,CTE.[Administratief eigenaar]
	--	,KENM.[Juridisch eigenaar]
		--,CTE.[Juridisch eigenaar]
		,[Gebruikers-id] = POST.Gebruiker
		,Eigenaar = @Eigenaar
	into ##Posten1
	FROM staedion_dm.Grootboek.Grootboekposten AS POST
	JOIN staedion_dm.Grootboek.Rekening AS REK ON REK.Rekening_id = POST.Rekening_id
	left outer join staedion_dm.Grootboek.Dimensiewaarden1 as DIM on DIM.[Dimensiewaarde 1_id] = POST.[Dimensiewaarde 1_id]
	left outer join staedion_dm.Grootboek.Btwproductboekingsgroep as BTW on BTW.Btwproductboekingsgroep_id = POST.Btwproductboekingsgroep_id
	left outer join staedion_dm.Grootboek.Productboekingsgroep as PROD on PROD.Productboekingsgroep_id = POST.Productboekingsgroep_id
	left outer join staedion_dm.Grootboek.Bronnen as BR on BR.Bron_id = POST.Bron_id
	left outer join cte_eenheden_juridisch as CTE on CTE.Eenheidnr = POST.Eenheidnr
	OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(POST.Eenheidnr) AS CL
	--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](POST.Eenheidnr, GETDATE()) KENM
	WHERE 	(	CTE.Eenheidnr is not null
					OR (DIM.Code IN (
						'1001'
						,'1002'
						,'1005'
						,'1006'
						,'1007'
						,'1019'
						,'1037'
						,'1173'
						,'1187'
						,'1253'
						,'1257'
						,'1303'
						,'1318'
						,'1636'
						,'1638'
						,'1639'
						,'1642'
						,'1643'
						,'1644'
						,'1645'
						,'1646'
						,'1675'
						,'1684'
						) and  @Eigenaar = 'Staedion VG Holding BV')
					)
		AND POST.Boekdatum BETWEEN @DatumVanaf and @DatumTotenMet
		;
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	---------------------------------------------------------------------------------
	set @Onderwerp = 'Alle regels uit toegerekende posten: ##Posten2';
	----------------------------------------------------------------------------------- 
	;with cte_eenheden_juridisch as 
		(SELECT Eenheidnr FROM staedion_dm.rapport.Eenheden_Jur_Eig)
	SELECT Rekeningnr = REK.Rekeningnr
		,Rekeningnaam = REK.Grootboekrekening
		,[Toegerekend bedrag] = CONVERT(FLOAT, POST.[Toegerekend bedrag])
		,Eenheidnr = POST.Eenheidnr
		,Documentnr = POST.[Document nr]
		,Boekdatum = POST.Boekdatum
		,Volgnummer = POST.[Volgnummer grootboekpost]
		--,CTE.[Corpodata type]
		,Cluster = CL.Clusternr
		--,CTE.[Administratief eigenaar]
		--,CTE.[Juridisch eigenaar]
		,Eigenaar = @Eigenaar
	into ##Posten2
	FROM staedion_dm.Grootboek.[Toegerekende grootboekposten]  AS POST
	JOIN staedion_dm.Grootboek.Rekening AS REK ON REK.Rekening_id = POST.Rekening_id
	left outer join cte_eenheden_juridisch as CTE on CTE.Eenheidnr = POST.Eenheidnr
	OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(POST.Eenheidnr) AS CL
	WHERE 	POST.Boekdatum BETWEEN @DatumVanaf and @DatumTotenMet
		and POST.Regeltype = 'Toerekening'
		and POST.[Volgnummer grootboekpost] in (select Volgnummer from ##Posten1)
	;

				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Updates ##Posten1';
	----------------------------------------------------------------------------------- 

	-- update tabel om duidelijk te maken waar toerekening volledig is
	alter table ##posten1 add [Toegerekende post] nvarchar(10)
	alter table ##posten1 add [Toegerekende post bedrag] decimal(12,2)
	alter table ##posten1 add [Toegerekende post ok] bit
	;

	update ##posten1 
	set [Toegerekende post] = 'Ja'
	where exists (select 1 from ##posten2 as TOE where TOE.Volgnummer = ##posten1.Volgnummer)
	;
	update ##posten1 
	set [Toegerekende post bedrag] = 
	(select sum([Toegerekend bedrag]) 
	from ##posten2 as TOE where TOE.Volgnummer = ##posten1.Volgnummer)
	where 1=1
	;
	update ##posten1 
	set [Toegerekende post ok] = 1
	where [Toegerekende post bedrag] is not null and [Toegerekende post bedrag] = bedrag
	;
	update ##posten1 
	set [Toegerekende post ok] = 0
	where [Toegerekende post bedrag] is not null and [Toegerekende post bedrag] <> bedrag
	;

				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig- zonder toegerekende posten';
	----------------------------------------------------------------------------------- 
	INSERT INTO staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig
			([Rekeningnr], [Rekeningnaam], [Bedrag], [Eenheidnr], [Documentnr], [Boekdatum], [Omschrijving], [Kostenplaats], [Volgnummer], [Productboekingsgroep ]
			, [Broncode], [BTW-poductboekingsgroep], [BTW-bedrag], [Gebruikers-id], [Bron], [Periode]
			, [Toegerekende post], [Toegerekende post bedrag], [Toegerekende post ok]
			, Eigenaar)
	select  Rekeningnr
			,Rekeningnaam
			,[Bedrag] 
			,Eenheidnr
			,Documentnr
			,Boekdatum
			,Omschrijving
			,Kostenplaats
			,Volgnummer 
			,[Productboekingsgroep ]
			,[Broncode]
			,[BTW-poductboekingsgroep]
			,[BTW-bedrag]
			,[Gebruikers-id]
			,Bron = 'Grootboekposten'
			,[Periode] = 'Van '
						+ convert(nvarchar(20),@DatumVanaf,105) 
						+ ' tm '
						+ convert(nvarchar(20),@DatumTotenMet,105) 
						+ ' verversdatum: '
						+ CONVERT(NVARCHAR(20), GETDATE(), 105)
			, coalesce([Toegerekende post], 'Nee') 
			, [Toegerekende post bedrag]
			, [Toegerekende post ok]
			,Eigenaar = @Eigenaar
	-- select count(*) --30.940 vs 27.457
	from	##posten1
	where	[Toegerekende post ok] is NULL
	or		[Toegerekende post ok] = 0
	;

				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig- met toegerekende posten';
	----------------------------------------------------------------------------------- 
	INSERT INTO staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig
			([Rekeningnr], [Rekeningnaam], [Bedrag], [Eenheidnr], [Documentnr], [Boekdatum], [Omschrijving], [Kostenplaats], [Volgnummer], [Productboekingsgroep ]
			, [Broncode], [BTW-poductboekingsgroep], [BTW-bedrag], [Gebruikers-id], [Bron], [Periode]
			, [Toegerekende post], [Toegerekende post bedrag], [Toegerekende post ok]
			, Eigenaar)		
	select  POST.Rekeningnr
			,POST.Rekeningnaam
			,TOE.[Toegerekend bedrag] 
			,TOE.Eenheidnr
			,POST.Documentnr
			,POST.Boekdatum
			,POST.[Omschrijving]
			,POST.Kostenplaats
			,POST.Volgnummer 
			,POST.[Productboekingsgroep]
			,POST.[Broncode]
			,POST.[BTW-poductboekingsgroep]
			,POST.[BTW-bedrag]
			,POST.[Gebruikers-id]
			,Bron = 'Toegerekende grootboekposten'
			,[Periode] = 'Van '
						+ convert(nvarchar(20),@DatumVanaf,105) 
						+ ' tm '
						+ convert(nvarchar(20),@DatumTotenMet,105) 
						+ ' verversdatum: '
						+ CONVERT(NVARCHAR(20), GETDATE(), 105)
			, [Toegerekende post]
			, [Toegerekende post bedrag]
			, [Toegerekende post ok]
			, Eigenaar = @Eigenaar
	-- select count(*) --30.940 vs 27.457
	-- select count(distinct POST.Volgnummer) -- 3.483 + 27.457 = 30.940
	from	##posten1 as POST
	inner join ##posten2 as TOE
	on		TOE.Volgnummer = POST.Volgnummer
	--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](TOE.Eenheidnr, GETDATE()) as KENM
	where	coalesce(POST.[Toegerekende post ok],0) = 1
	;
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Update kenmerken Corpodatatype + Cluster + Adm Eigenaar + Jur Eigenaar - UITGEZET DUURT TE LANG';
	----------------------------------------------------------------------------------- 
	--update  BASIS
	--set		[Corpodata type] = KENM.[Corpodata type]
	--		,[Cluster] = KENM.[FT clusternr]
	--		,[Administratief eigenaar] = KENM.[Administratief eigenaar]
	--		,[Juridisch eigenaar] = KENM.[Juridisch eigenaar]
	--from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as BASIS
	--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](BASIS.Eenheidnr, GETDATE()) as KENM
	--where	BASIS.[Juridisch eigenaar] is null
	--;
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------					
	set @Onderwerp = 'staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig- met toegerekende posten';
	-----------------------------------------------------------------------------------

		update	staedion_dm.rapport.Eenheden_Jur_Eig
		set		Saldo_Overig_Binnen_Periode = 
		(select sum (GRB.[Bedrag])
		from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
		where	staedion_dm.rapport.Eenheden_Jur_Eig.Eenheidnr = GRB.eenheidnr
		and 	GRB.[Rekeningnr] not like 'A81%'
		and		GRB.[Rekeningnr] like 'A8%'
		and		GRB.[Boekdatum] >= staedion_dm.rapport.Eenheden_Jur_Eig.[Begindatum juridisch eigenaar] 
		and		GRB.[Boekdatum] <= staedion_dm.rapport.Eenheden_Jur_Eig.[Einddatum juridisch eigenaar] 
		and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
		) ;
		update	staedion_dm.rapport.Eenheden_Jur_Eig
		set		Saldo_Buiten_Periode = 
		(select sum (GRB.[Bedrag])
		from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
		where	staedion_dm.rapport.Eenheden_Jur_Eig.Eenheidnr = GRB.eenheidnr
		and 	GRB.[Rekeningnr] like 'A8%'
		and		NOT(GRB.[Boekdatum] >= staedion_dm.rapport.Eenheden_Jur_Eig.[Begindatum juridisch eigenaar] 
		and		GRB.[Boekdatum] <= staedion_dm.rapport.Eenheden_Jur_Eig.[Einddatum juridisch eigenaar] )
		and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
		)
		;
		update	staedion_dm.rapport.Eenheden_Jur_Eig
		set		Saldo_Huur_Binnen_Periode = 
		(select sum (GRB.[Bedrag])
		from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
		where	staedion_dm.rapport.Eenheden_Jur_Eig.Eenheidnr = GRB.eenheidnr
		and 	GRB.[Rekeningnr] like 'A81%'
		and		GRB.[Boekdatum] >= staedion_dm.rapport.Eenheden_Jur_Eig.[Begindatum juridisch eigenaar] 
		and		GRB.[Boekdatum] <= staedion_dm.rapport.Eenheden_Jur_Eig.[Einddatum juridisch eigenaar] 
		and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
		)
		;

			SET @AantalRecords = @@rowcount
			;
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Kenmerk meegeven aan details - classificatie - welke meenemen en welke niet';
	----------------------------------------------------------------------------------- 
	update	GRB
	set		Classificatie = 'Saldo_Huur_Binnen_Periode'
	from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
	join	staedion_dm.rapport.Eenheden_Jur_Eig as EENH
	on		EENH.Eenheidnr = GRB.eenheidnr
	where	GRB.[Rekeningnr] like 'A81%'
	and		GRB.[Boekdatum] >= EENH.[Begindatum juridisch eigenaar] 
	and		GRB.[Boekdatum] <= EENH.[Einddatum juridisch eigenaar] 
	and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
	;
	update	GRB
	set		Classificatie = 'Saldo_Overig_Binnen_Periode'
	from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
	join	staedion_dm.rapport.Eenheden_Jur_Eig as EENH
	on		EENH.Eenheidnr = GRB.eenheidnr
	where	GRB.[Rekeningnr] not like 'A81%'
	and		GRB.[Rekeningnr] like 'A8%'
	and		GRB.[Boekdatum] >= EENH.[Begindatum juridisch eigenaar] 
	and		GRB.[Boekdatum] <= EENH.[Einddatum juridisch eigenaar] 
	and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
	;
	update	GRB
	set		Classificatie = 'Saldo_Buiten_Periode'
	from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
	join	staedion_dm.rapport.Eenheden_Jur_Eig as EENH
	on		EENH.Eenheidnr = GRB.eenheidnr
	where	GRB.[Rekeningnr] like 'A8%'
	and		NOT(GRB.[Boekdatum] >= EENH.[Begindatum juridisch eigenaar] 
	and		GRB.[Boekdatum] <= EENH.[Einddatum juridisch eigenaar] )
	and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
	;
	update	GRB
	set		Classificatie = 'Eenheid staat op naam van Staedion'
	from	staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig as GRB
	join	staedion_dm.rapport.Eenheden_Jur_Eig as EENH
	on		EENH.Eenheidnr = GRB.eenheidnr
	where	GRB.[Rekeningnr] like 'A8%'
	and		GRB.[Boekdatum] >= coalesce(EENH.[Begindatum juridisch eigenaar],'20010101') 
	and		GRB.[Boekdatum] <= coalesce(EENH.[Einddatum juridisch eigenaar],'20990101' )
	and     [EENH].[Juridisch eigenaar] = 'Staedion'
	and		GRB.Broncode not in ('EXTBEHEER','DAEBRC','DAEBVERD')
	;

				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Memoriaal genereren';
	----------------------------------------------------------------------------------- 
		truncate table staedion_dm.rapport.Memoriaal_Jur_Eig 

		INSERT INTO staedion_dm.rapport.Memoriaal_Jur_Eig (
			[Boekdatum]
			,[Rekeningnr.]
			,[Bedrag]
			,[Eenheidnr.]
			)
		SELECT Boekdatum = eomonth((
					SELECT max(Boekdatum)
					FROM staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig
					))
				,Rekeningnr
				,sum(Bedrag)*-1
				,Eenheidnr
		FROM staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig
		WHERE Rekeningnr LIKE 'A8%'
			AND Broncode NOT IN (
				'DAEBRC'
				,'DAEBVERD'
				,'EXTBEHEER'
				)
			AND nullif(Eenheidnr,'') is not null 
			and Classificatie IS not NULL
			and Classificatie in ('Saldo_Huur_Binnen_Periode','Saldo_Overig_Binnen_Periode')
		group by Rekeningnr,Eenheidnr
		order by Rekeningnr,Eenheidnr
		;
		update staedion_dm.rapport.Memoriaal_Jur_Eig
		set Omschrijving = 'Afrekening '
								+ @Eigenaar
								+ ' ' 
								+ format(@DatumVanaf,'MM') 
								+ ' t/m '
								+ format(@DatumTotEnMet,'MM-yyyy') 
	;
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Check';
	----------------------------------------------------------------------------------- 
	set	@finish = current_timestamp
	
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding, Begintijd,Eindtijd)
		select object_name(@@procid),getdate(),  @start, @finish

	DROP TABLE IF exists ##Posten1; -- voor grootboekposten
	DROP TABLE IF exists ##Posten2; -- voor toegerende posten
	DROP TABLE IF EXISTS #JurEig;
	DROP TABLE IF EXISTS #cte_eenheden;
	
	SELECT BASIS.[Rekeningnr]
		,BASIS.[Rekeningnaam]
		,BASIS.[Bedrag]
		,BASIS.[Eenheidnr]
		,EIG.Adres
		,BASIS.[Documentnr]
		,BASIS.[Boekdatum]
		,BASIS.[Kostenplaats]
		,BASIS.[Volgnummer]
		,BASIS.[Productboekingsgroep ]
		,BASIS.[Broncode]
		,BASIS.[BTW-poductboekingsgroep]
		,BASIS.[BTW-bedrag]
		,BASIS.[Corpodata type]
		,BASIS.[Cluster]
		,BASIS.[Administratief eigenaar]
		,BASIS.[Juridisch eigenaar]
		,BASIS.[Gebruikers-id]
		,BASIS.[Bron]
		,BASIS.[Periode]
		,BASIS.[Toegerekende post]
		,BASIS.[Toegerekende post bedrag]
		,BASIS.[Toegerekende post ok]
		,BASIS.[Omschrijving]
		,BASIS.Eigenaar
	FROM staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig AS BASIS
	LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG ON EIG.Eenheidnr = BASIS.Eenheidnr
		AND EIG.Einddatum IS NULL
	WHERE BASIS.Rekeningnr LIKE 'A8%'
		OR BASIS.Rekeningnr LIKE 'A9%'
	ORDER BY BASIS.Rekeningnr
		,BASIS.Volgnummer


--	COMMIT TRANSACTION;

--END TRY
 --   BEGIN CATCH 

       --IF @@TRANCOUNT > 0
       --BEGIN
       --   ROLLBACK TRANSACTION
       --END;

	 --   SELECT ERROR_PROCEDURE(), GETDATE(), ERROR_PROCEDURE(), ERROR_NUMBER(), ERROR_LINE(), ERROR_MESSAGE() , @start, @finish

		--SET	@finish = CURRENT_TIMESTAMP
		--	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage, Begintijd, Eindtijd)
		--	SELECT ERROR_PROCEDURE(), GETDATE(), ERROR_PROCEDURE(), ERROR_NUMBER(), ERROR_LINE(), ERROR_MESSAGE() , @start, @finish

  --  END CATCH;

	-- Alleen uit te voeren bij parameter @Testversie = 1
	IF @Testversie = 1
	BEGIN 
		_Label_Select_Test:
		SELECT BASIS.[Rekeningnr]
			,BASIS.[Rekeningnaam]
			,BASIS.[Bedrag]
			,BASIS.[Eenheidnr]
			,EIG.Adres
			,BASIS.[Documentnr]
			,BASIS.[Boekdatum]
			,BASIS.[Kostenplaats]
			,BASIS.[Volgnummer]
			,BASIS.[Productboekingsgroep ]
			,BASIS.[Broncode]
			,BASIS.[BTW-poductboekingsgroep]
			,BASIS.[BTW-bedrag]
			,BASIS.[Corpodata type]
			,BASIS.[Cluster]
			,BASIS.[Administratief eigenaar]
			,BASIS.[Juridisch eigenaar]
			,BASIS.[Gebruikers-id]
			,BASIS.[Bron]
			,BASIS.[Periode]
			,BASIS.[Toegerekende post]
			,BASIS.[Toegerekende post bedrag]
			,BASIS.[Toegerekende post ok]
			,BASIS.[Omschrijving]
			,BASIS.Eigenaar
		FROM staedion_dm.Rapport.Specificatie_Grootboekposten_Jur_Eig AS BASIS
		LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG ON EIG.Eenheidnr = BASIS.Eenheidnr
			AND EIG.Einddatum IS NULL
		WHERE BASIS.Rekeningnr LIKE 'A8%'
			OR BASIS.Rekeningnr LIKE 'A9%'
		ORDER BY BASIS.Rekeningnr
			,BASIS.Volgnummer
	END

--SET NOCOUNT, XACT_ABORT OFF;

GO
GRANT EXECUTE ON  [Grootboek].[sp_load_specificatie_grootboekposten_jur_eig] TO [public]
GO
