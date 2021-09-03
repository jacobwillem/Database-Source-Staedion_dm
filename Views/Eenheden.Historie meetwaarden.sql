SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [Eenheden].[Historie meetwaarden] as 

/* #####################################################################################################################################
JVDW 20210317 
[Totaal punten] zit nu niet meer in Meetwaarden, maar in Woningwaardering
Maar daar zitten nu nog teveel regels in - om dubbelen te voorkomen cte toegevoegd

-- Check dubbele ?
SELECT [Peildatum], COUNT(*), COUNT(DISTINCT eenheidnr) 
FROM staedion_dm.[Eenheden].[Historie meetwaarden] -- 711265
GROUP BY [Peildatum]

20210519 Toegevoegd: MW.[Percentage max. redelijke huur]
20210701 Versie 4 Nav opmerking Margot bleek totaal punten niet altijd opgehaald te worden - Volgnr in cte gewijzigd + join met cte gewijzigd

select * from [Eenheden].[Historie meetwaarden]  where Eenheidnr = 'OGEH-0000392'

	SELECT WW.Bedrijf_id
		,WW.Eenheidnr
		,WW.Ingangsdatum
		,WW.Einddatum
		,Ww.[Totaal punten]
		,Volgnr = ROW_NUMBER() OVER (
			PARTITION BY WW.Bedrijf_id
			,WW.Eenheidnr, WW.Ingangsdatum ORDER BY WW.Volgnummer DESC
			)
	FROM staedion_dm.[Eenheden].[Woningwaardering] AS WW
	where Eenheidnr = 'OGEH-0000392'
##################################################################################################################################### */

WITH cte_wwd
AS (
	SELECT WW.Bedrijf_id
		,WW.Eenheidnr
		,WW.Ingangsdatum
		,WW.Einddatum
		,Ww.[Totaal punten]
		,Volgnr = ROW_NUMBER() OVER (
			PARTITION BY WW.Bedrijf_id
			,WW.Eenheidnr, WW.Ingangsdatum ORDER BY WW.Volgnummer DESC
			)
	FROM staedion_dm.[Eenheden].[Woningwaardering] AS WW
	)
SELECT MW.Eenheidnr
	,o.lt_id [Sleutel eenheid]
	,KENM_NU.[FT clusternr]
	,KENM_NU.[FT clusternaam]
	,KENM_NU.Assetmanager
	,KENM_NU.[Verhuurteam]
	,EOMONTH(MW.Peildatum) AS [Peildatum]
	,cty.[Code] [Corpodata type]
	,MW.[Kale huur]
	,[Totaal punten] = WW.[Totaal punten] --MW.[Totaal punten]
	,MW.[Maximaal toegestane huur]
	,MW.[Markthuur]
	,KENM_NU.[Doelgroep]
	,MW.[Aftopgrens]
	,KENM_NU.[Huurbeleid]
	--,MW.[Mutatiehuur]
	,Mutatiehuur = COALESCE(MW.mutatiehuur,MW.markthuur)            -- JVDW 20210407 coalesce toegevoegd na opmerking Ruben over consistentie met algemeen.[eenheid meetwaarden]
	,[Subsidiabele servicekosten totaal] = MW.[Subsidiabel deel]
	,MW.[Subsidiabele energiekosten]
	,MW.[Subsidiabele energiekosten afgetopt]
	,MW.[Subsidiabele schoonmaakkosten]
	,MW.[Subsidiabele schoonmaakkosten afgetopt]
	,MW.[Subsidiabele huismeesterkosten]
	,MW.[Subsidiabele huismeesterkosten afgetopt]
	,MW.[Percentage max. redelijke huur]
-- select count(*) -- 4373816
FROM staedion_dm.eenheden.Meetwaarden AS MW
JOIN empire_logic.dbo.lt_mg_oge AS o ON o.Nr_ = MW.Eenheidnr
	AND o.mg_bedrijf = 'Staedion'
JOIN staedion_dm.eenheden.Eigenschappen AS KENM_NU ON MW.Eenheidnr = KENM_NU.Eenheidnr
	AND KENM_NU.Einddatum IS NULL
JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty
on KENM_NU.[Corpodatatype_id] = cty.[Corpodatatype_id]
JOIN staedion_dm.Eenheden.Exploitatiestatus AS ES ON ES.id = MW.Exploitatiestatus_id
LEFT OUTER JOIN cte_wwd AS WW ON WW.Bedrijf_id = MW.Bedrijf_id
	AND WW.Eenheidnr = MW.Eenheidnr
	AND WW.Ingangsdatum <= MW.Peildatum
	AND WW.Einddatum >= MW.Peildatum
	AND WW.Volgnr = 1
WHERE ES.[exploitatiestatus] = 'In exploitatie';
GO
