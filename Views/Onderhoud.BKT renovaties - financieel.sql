SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Onderhoud].[BKT renovaties - financieel]
as
WITH cte_bkt_codes
AS (
	SELECT Jaar = 2020
		,[BKT groep] = 'Keuken'
		,[Sjablooncode taak] = 'R7302'
		,StandaardPrijs = 3146 -- Keukenvervanging inclusief tegelwerk
	
	UNION
	
	SELECT Jaar = 2020
		,[BKT groep] = 'Keuken'
		,[Sjablooncode taak] = 'R7303'
		,StandaardPrijs = 1660 -- Keukenvervanging exclusief tegelwerk
	
	UNION
	
	SELECT Jaar = 2020
		,[BKT groep] = 'Keuken'
		,[Sjablooncode taak] = 'R7304'
		,StandaardPrijs = 3596 --	Keukenvervanging inclusief tegelwerk en CV	
	
	UNION
	
	SELECT Jaar = 2020
		,[BKT groep] = 'Toilet'
		,[Sjablooncode taak] = 'R7422'
		,StandaardPrijs = 2146 -- Toiletrenovatie
	
	UNION
	
	SELECT Jaar = 2020
		,[BKT groep] = 'Badkamer'
		,[Sjablooncode taak] = 'R7412'
		,StandaardPrijs = 7228 -- Badkamerrenovatie
	)
SELECT CTE.[BKT groep]
	,CTE.[Sjablooncode taak]
	,CTE.StandaardPrijs
	,DWH.Sleutel_eenheid
	,Eenheidnr = EENH.bk_nr_
	,Adres = DWH.Adres + coalesce(' '+ EENH.da_postcode, '') + coalesce(' ' + EENH.da_plaats,'')
	,Datum = max(DWH.datum)
	,Aantal = count(DISTINCT DWH.Sleutel_eenheid)
	,Kosten = sum(DWH.Kosten)
	,Opmerking = iif(sum(DWH.Kosten) - CTE.StandaardPrijs > 0.10 * CTE.StandaardPrijs, 'Let op: meer dan 10% hoger dan standaardprijs', '')
	,Onderhoudsverzoek = NPO_V.bk_no_
FROM empire_dwh.dbo.tmv_npo_projectpost AS DWH
JOIN cte_bkt_codes AS CTE ON CTE.[Sjablooncode taak] = DWH.[Sjablooncode taak]
	AND CTE.Jaar = year(DWH.Datum)
join empire_dwh.dbo.eenheid as EENH
on EENH.id = DWH.Sleutel_eenheid
join empire_Dwh.dbo.npo_Verzoek as NPO_V
on NPO_V.id = DWH.[Sleutel_verzoek]
WHERE year(DWH.Datum) >= 2020
	AND DWH.[Rekeningnr geboekt] = 'A815340'
GROUP BY CTE.Jaar
	,CTE.[BKT groep]
	,CTE.[Sjablooncode taak]
	,CTE.StandaardPrijs
	,DWH.Sleutel_eenheid
	,DWH.Adres + coalesce(' '+ EENH.da_postcode, '') + coalesce(' ' + EENH.da_plaats,'')
	,CTE.StandaardPrijs
	,EENH.bk_nr_
	,NPO_V.bk_no_


GO
