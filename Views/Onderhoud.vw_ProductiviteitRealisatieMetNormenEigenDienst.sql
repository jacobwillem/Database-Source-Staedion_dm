SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Onderhoud].[vw_ProductiviteitRealisatieMetNormenEigenDienst] as 

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Gebruikmakend van datamart staedion_dm.onderhoud: improductiviteit ophalen uit de projectposten per resource en afzetten tegen norm zoals aanvullend is bepaald
Zie datamart staedion_dm.Onderhoud
zie aanvullende referentietabellen staedion_dm.Sharepoint
Historische achtergrond: dwex-pagina "5.06 S&R - % productieve uren eigen dienst voor Power BI
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoud'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_ProductiviteitRealisatieMetNormenEigenDienst';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220502 JvdW aangemaakt obv oude tabellen om verwijzing naar empire_dwh en extra ingelezen informatie aan te passen aan staedion_dm + sharepoint/referentie-tabellen

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */

WITH cte_tijd		-- 20220502 voorheen koppeling met empire_Dwh.dbo.tijd, nu is er nog geen bijgewerkte versie van in staedion_dm
AS (
	SELECT DISTINCT eomonth(T.datum) AS Datum
	FROM staedion_dm.Algemeen.Tijd AS T
	WHERE T.datum >= '20200101'
		AND T.datum <= eomonth(getdate())
	)
	,cte_projectposten
AS (
	SELECT eomonth(PP.Boekdatum) AS Datum
		,PP.[Onderhoudsorder/Projectnr] as [Code]
		,sum(PP.[Aantal (basis)]) AS [aantal_uren_geboekt]
		--select *
	FROM staedion_dm.onderhoud.Projectposten as PP
	WHERE PP.Projectsoort = 'Improductiviteit' 
	and PP.Boekdatum BETWEEN (
					SELECT min(Datum)
					FROM cte_tijd
					)
			AND (
					SELECT max(Datum)
					FROM cte_tijd
					)
	GROUP BY eomonth(PP.Boekdatum)
		,PP.[Onderhoudsorder/Projectnr]
	union
	SELECT eomonth(PP.Boekdatum) AS Datum
		,'Directe Uren' as Code -- verwijst naar Directe uren
		,sum(PP.[Aantal (basis)]) AS [aantal_uren_geboekt]
		-- select *
	FROM staedion_dm.onderhoud.Projectposten as PP
	WHERE PP.Projectsoort <> 'Improductiviteit' 
	and Regelsoort = 'Uren'
	and PP.Boekdatum BETWEEN (
					SELECT min(Datum)
					FROM cte_tijd
					)
			AND (
					SELECT max(Datum)
					FROM cte_tijd
					)
	GROUP BY eomonth(PP.Boekdatum)

	)
	,cte_normen
AS (
	SELECT eomonth(N.datum) AS Datum
		,coalesce(N.Code,'Directe Uren') as [Code]
		,sum(N.NormUren) AS Normuren
		-- select top 1000 * --fROM [empire_staedion_data].[dwh].[f_improductiviteits_normen] AS N
	from staedion_dm.Sharepoint.ImproductiviteitNormUrenPerMaand as N
	WHERE N.Datum BETWEEN (
					SELECT min(Datum)
					FROM cte_tijd
					)
			AND (
					SELECT max(Datum)
					FROM cte_tijd
					)
	GROUP BY eomonth(N.datum)
		,coalesce(N.Code,'Directe Uren')
	)

	,cte_details
AS (
	SELECT IMP.[Groepering improductiviteit] as Groepering
		,IMP.[Omschrijving improductiviteitscode rapportage] as staedion_omschrijving
		,IMP.Code
		,Peildatum = PP.Datum
		,[Norm uren] = sum(NORM.NormUren)
		,[Werkelijke uren] = sum(PP.[aantal_uren_geboekt])
	-- select * 
	from staedion_dm.sharepoint.ImproductiviteitsCodesEnGroepering as IMP
	JOIN cte_tijd AS T ON 1 = 1
	LEFT OUTER JOIN cte_projectposten AS PP ON IMP.[Code] = PP.[Code] and T.Datum = PP.Datum
	LEFT OUTER JOIN cte_normen AS NORM ON IMP.[Code] = NORM.[Code] and T.Datum = NORM.Datum
	GROUP BY IMP.[Groepering improductiviteit]
		,IMP.[Omschrijving improductiviteitscode rapportage]
		,IMP.Code
		,PP.Datum
		--,year(PP.Datum)
		--,month(PP.Datum)
	)
SELECT *
FROM cte_details
WHERE NOT (
		[Norm uren] IS NULL
		AND [Werkelijke uren] IS NULL
		)

UNION

SELECT Groepering = 'B. Aanwezige uren (Totaal uren - A)'
	,staedion_omschrijving = 'B. Aanwezige uren (Totaal uren - A)'
	,Code = NULL
	,Peildatum
	,[Norm uren] = sum(coalesce([Norm uren], 0))
	,[Werkelijke uren] = sum(coalesce([Werkelijke uren], 0))
FROM cte_details
WHERE groepering <> 'A. Afwezigheid (01 t/m 04)'
GROUP BY Code
	,Peildatum

UNION

SELECT Groepering = 'D. Beschikbare uren (B - C)'
	,staedion_omschrijving = 'D. Beschikbare uren (B - C)'
	,Code = NULL
	,Peildatum
	,[Norm uren] = sum(coalesce([Norm uren], 0))
	,[Werkelijke uren] = sum(coalesce([Werkelijke uren], 0))
FROM cte_details
WHERE groepering <> 'A. Afwezigheid (01 t/m 04)'
	AND groepering <> 'C. Improductieve uren (05 t/m 10)'
GROUP BY Code
	,Peildatum

UNION

SELECT Groepering = 'Totaal uren'
	,staedion_omschrijving = 'Totaal uren'
	,Code = NULL
	,Peildatum
	,[Norm uren] = sum(coalesce([Norm uren], 0))
	,[Werkelijke uren] = sum(coalesce([Werkelijke uren], 0))
FROM cte_details
GROUP BY Code
	,Peildatum
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gebruikmakend van datamart staedion_dm.onderhoud: improductiviteit ophalen uit de projectposten per resource en afzetten tegen norm zoals aanvullend is bepaald
Zie datamart staedion_dm.Onderhoud
zie aanvullende referentietabellen staedion_dm.Sharepoint
Historische achtergrond: dwex-pagina "5.06 S&R - % productieve uren eigen dienst voor Power BI
', 'SCHEMA', N'Onderhoud', 'VIEW', N'vw_ProductiviteitRealisatieMetNormenEigenDienst', NULL, NULL
GO
