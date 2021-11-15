SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Elementen].[sp_pbi_load_Huurkorting]
	(@Peildatum DATE = null) AS

/* ########################################################################################################################################
BETREFT:	

ZIE: 21 10 225 Controle-rapportage Kortingen.sql
061|062|063|064|065|066|067|069|070|071|413|415|417|418|419|480|482|497
A810400 = 061|062|063|065|066|067|070|071|418|419|537|903

IC HKDOORS
IC HKHERST
IC HUURKRT

-----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
-----------------------------------------------------------------------------------------------------------------
20211115 JvdW aangemaakt

-----------------------------------------------------------------------------------------------------------------
TESTEN updaten van details in voorzieningen rapport
-----------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Elementen].[sp_pbi_load_Huurkorting]

-----------------------------------------------------------------------------------------------------------------
TESTEN: Check consistentie met grootboek
-----------------------------------------------------------------------------------------------------------------
SELECT  Boekdatum = GL.[Posting Date], Rekeningnr = GA.No_, Rekeningnaam = GA.[Name], Broncode = GL.[Source Code],Productboekingsgroep = GL.[Gen_ Prod_ Posting group] , Bedrag = CONVERT(FLOAT,SUM(Amount))
,[Soort-boekingen] = case GL.[Source Code] when 'DAEBRC' then 'Overig' when 'AFSLWVREK' then 'Overig' when 'EXT_Beheer' then 'Overig' else 'Saldo grootboek' end
FROM empire_data.dbo.staedion$g_l_entry AS GL
LEFT OUTER JOIN empire_data.dbo.staedion$G_L_account AS GA
ON GA.No_ = GL.[G_L Account No_]
WHERE [G_L Account No_] = 'A810400' AND YEAR([Posting Date]) >= 2020
GROUP BY  GL.[Posting Date], GA.No_,GA.[Name], GL.[Source Code], GL.[Gen_ Prod_ Posting group]



-----------------------------------------------------------------------------------------------------------------
TESTEN: Detailcheck
-----------------------------------------------------------------------------------------------------------------
DECLARE @HRD AS NVARCHAR(20) = 'KLNT-0057656'


######################################################################################################################################## */



BEGIN TRY

	IF @Peildatum IS NULL	
		SET @Peildatum = DATEFROMPARTS(YEAR(GETDATE())-1,1,1);

	-- Stap 1: vullen details: #details_prolongatieposten
	DROP TABLE IF EXISTS #details_prolongatieposten;
	DROP TABLE IF EXISTS #BasisRapportage;
	DROP TABLE IF EXISTS #notitie;

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
			,[Jan] = IIF(MONTH(Boekingsdatum) = 1, CONVERT(FLOAT,bedrag), NULL)
			,[Feb] = IIF(MONTH(Boekingsdatum) = 2, CONVERT(FLOAT,bedrag), NULL)
			,[Mrt] = IIF(MONTH(Boekingsdatum) = 3, CONVERT(FLOAT,bedrag), NULL)
			,[Apr] = IIF(MONTH(Boekingsdatum) = 4, CONVERT(FLOAT,bedrag), NULL)
			,[Mei] = IIF(MONTH(Boekingsdatum) = 5, CONVERT(FLOAT,bedrag), NULL)
			,[Jun] = IIF(MONTH(Boekingsdatum) = 6, CONVERT(FLOAT,bedrag), NULL)
			,[Jul] = IIF(MONTH(Boekingsdatum) = 7, CONVERT(FLOAT,bedrag), NULL)
			,[Aug] = IIF(MONTH(Boekingsdatum) = 8, CONVERT(FLOAT,bedrag), NULL)
			,[Sep] = IIF(MONTH(Boekingsdatum) = 9, CONVERT(FLOAT,bedrag), NULL)
			,[Okt] = IIF(MONTH(Boekingsdatum) = 10, CONVERT(FLOAT,bedrag), NULL)
			,[Nov] = IIF(MONTH(Boekingsdatum) = 11, CONVERT(FLOAT,bedrag), NULL)
			,[Dec] = IIF(MONTH(Boekingsdatum) = 12, CONVERT(FLOAT,bedrag), NULL)
			,Bron = Iif(PP.Contractvolgnr_ <> 0, 'Contractregels', 'Aparte nota')
			,VHM.[Ingevoerd door], VHM.[Datum invoer], VHM.[Gefiatteerd door]
		INTO #details_prolongatieposten
		FROM empire_data.dbo.Staedion$Prolongatiepost AS PP
		LEFT OUTER JOIN empire_data.dbo.[Staedion$Verhuurmutatie] AS VHM ON VHM.Eenheidnr_ = PP.Eenheidnr_
		AND VHM.Verhuurcontractvolgnr_ = PP.Contractvolgnr_
		WHERE PP.Elementnr_ IN (SELECT Elementnr FROM cte_element)
			AND YEAR(Boekingsdatum) >= 2020
	;
	--  STAP 2: ophalen grootboeknr + vullen basistabel 
	WITH cte_grootboek
	AS (
		SELECT GL.[G_L Account No_]
			,CTE.[G_L Entry No_]
		FROM #details_prolongatieposten AS CTE
		JOIN empire_data.dbo.staedion$g_l_entry AS GL ON CTE.[G_L Entry No_] = GL.[Entry No_]
		)
	SELECT Grootboekrekening = GRB.[G_L Account No_]
			,BASIS.Eenheidnr
			,BASIS.Klantnr
			,Elementnr = BASIS.Elementnr
			,Elementnaam = (SELECT omschrijving FROM empire_data.dbo.staedion$element WHERE TABeL = 0 AND Nr_ = BASIS.Elementnr)
			,TotaalBedrag = CONVERT(FLOAT,SUM(bedrag))
			,[Jan] = CONVERT(FLOAT,SUM([Jan]))
			,[Feb] = CONVERT(FLOAT,SUM([Feb]))
			,[Mrt] = CONVERT(FLOAT,SUM([Mrt]))
			,[Apr] = CONVERT(FLOAT,SUM([Apr]))
			,[Mei] = CONVERT(FLOAT,SUM([Mei]))
			,[Jun] = CONVERT(FLOAT,SUM([Jun]))
			,[Jul] = CONVERT(FLOAT,SUM([Jul]))
			,[Aug] = CONVERT(FLOAT,SUM([Aug]))
			,[Sep] = CONVERT(FLOAT,SUM([Sep]))
			,[Okt] = CONVERT(FLOAT,SUM([Okt]))
			,[Nov] = CONVERT(FLOAT,SUM([Nov]))
			,[Dec] = CONVERT(FLOAT,SUM([Dec]))
			,[Bedrag buiten contractregels om geprolongeerd] = CONVERT(FLOAT,NULL)
			,[Facturen buiten contractregels om geprolongeerd] = CONVERT(NVARCHAR(1000),NULL)
			,[Info verhuurmutatie] = CONVERT(NVARCHAR(1000),NULL)
			,[Info notitieveld contractregels] = CONVERT(NVARCHAR(1000),NULL)
			,Boekjaar = YEAR(BASIS.Boekingsdatum)
	INTO #BasisRapportage
	FROM #details_prolongatieposten AS BASIS
	LEFT OUTER JOIN cte_grootboek AS GRB ON GRB.[G_L Entry No_] = BASIS.[G_L Entry No_]
		--WHERE BASIS.Eenheidnr = 'OGEH-0014039'
		GROUP BY  GRB.[G_L Account No_]
		,BASIS.Eenheidnr
		,BASIS.Klantnr
		,BASIS.Elementnr
		,YEAR(BASIS.Boekingsdatum)

	-- STAP 3: vullen details: #details_prolongatieposten
	UPDATE #BasisRapportage
	SET [Bedrag buiten contractregels om geprolongeerd] = 
	(SELECT SUM(Bedrag)
	FROM  #details_prolongatieposten AS TMP
	WHERE TMP.eenheidnr = #BasisRapportage.eenheidnr
	AND TMP.klantnr = #BasisRapportage.klantnr
	AND TMP.elementnr = #BasisRapportage.elementnr
	AND TMP.Contractvolgnr = 0
	)
	;
	UPDATE #BasisRapportage
	SET [Facturen buiten contractregels om geprolongeerd] = 
	(SELECT STRING_AGG(TMP.Stuknummer, '|')
	FROM  #details_prolongatieposten AS TMP
	WHERE TMP.eenheidnr = #BasisRapportage.eenheidnr
	AND TMP.klantnr = #BasisRapportage.klantnr
	AND TMP.elementnr = #BasisRapportage.elementnr
	AND TMP.Contractvolgnr = 0
	)
	;

	WITH cte_volgnrs AS 
		(SELECT DISTINCT Eenheidnr, Klantnr, Elementnr, Contractvolgnr FROM #details_prolongatieposten)
		,cte_notitie
	AS (
		SELECT BASIS.Eenheidnr
			,BASIS.Klantnr
			,BASIS.Elementnr
			,BASIS.Contractvolgnr
			,ExtraInfo = FORMAT(ECL.[Date], 'dd-MM-yy - ') + ECL.[User ID]
			,Notitie = STRING_AGG(ECL.Comment, '|')
		FROM cte_volgnrs AS BASIS
		JOIN empire_data.dbo.Staedion$Empire_Comment_Line AS ECL ON ECL.[Table Name] = 2
			AND ECL.[Sub no_] = BASIS.Eenheidnr
			AND ECL.[Seq No_] = BASIS.Contractvolgnr
			AND ECL.[Seq No_]  <> 0
			GROUP BY Eenheidnr
			,BASIS.Klantnr
			,BASIS.Elementnr
	 		,Contractvolgnr
			,ECL.[Date]
			,ECL.[User ID])

		 SELECT Eenheidnr, Klantnr, Elementnr, Contractvolgnr, Notitie = ExtraInfo + ': ' + Notitie
		 INTO #notitie
		 FROM cte_notitie
		;

	-- STAP 4: vullen details: notitie-info
	UPDATE #BasisRapportage
	SET [Info notitieveld contractregels] = 
	(SELECT STRING_AGG(Notitie,' | ')
	FROM  #notitie AS TMP
	WHERE TMP.eenheidnr = #BasisRapportage.eenheidnr
	AND TMP.klantnr = #BasisRapportage.klantnr
	AND TMP.elementnr = #BasisRapportage.elementnr
	GROUP BY TMP.eenheidnr, TMP.klantnr, TMP.elementnr
	)
	;

	-- STAP 4: vullen details: notitie-info
	UPDATE #BasisRapportage
	SET [Info verhuurmutatie] = 
	(SELECT STRING_AGG(FORMAT(TMP.[Datum invoer],'dd-MM-yy ') + TMP.[Ingevoerd door] + ' fiat: '+ COALESCE(NULLIF(TMP.[Gefiatteerd door],''),'?'),' | ')
	FROM  #details_prolongatieposten AS TMP
	WHERE TMP.eenheidnr = #BasisRapportage.eenheidnr
	AND TMP.klantnr = #BasisRapportage.klantnr
	AND TMP.elementnr = #BasisRapportage.elementnr
	GROUP BY TMP.eenheidnr, TMP.klantnr, TMP.elementnr
	)
	;

	SELECT * FROM #BasisRapportage 
	;

END TRY
BEGIN CATCH

	SELECT ERROR_LINE(), ERROR_NUMBER(),ERROR_MESSAGE()

END CATCH

;
GO
