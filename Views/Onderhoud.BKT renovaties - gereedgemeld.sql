SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Onderhoud].[BKT renovaties - gereedgemeld]
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
		,[BKT groep] = 'Keuken'
		,[Sjablooncode taak] = 'R7309'
		,StandaardPrijs = null --	Keukenvervanging inclusief tegelwerk en CV	
		
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

select CTE.[BKT groep]
	,CTE.[Sjablooncode taak]
	,CTE.StandaardPrijs
	,DWH.[Sleutel eenheid]
	,Eenheidnr = EENH.bk_nr_
	,Adres = EENH.straatnaam + coalesce(' '+ EENH.da_postcode, '') + coalesce(' ' + EENH.da_plaats,'')
	,Datum = [REP-OrderGereed]
	,Aantal = [Hulpkolom bkt]
	,Kosten = DWH.[Kosten order]
	,Opmerking = iif(DWH.[Kosten order] - CTE.StandaardPrijs > 0.10 * CTE.StandaardPrijs, 'Let op: meer dan 10% hoger dan standaardprijs', '')
	,Onderhoudsverzoek = [REP-verzoeknr]
	,[Hulpkolom bkt]
	,[REP-TaakSjablooncode], staedion_standaardtaakcode 
	,[REP-OrderStatus]
	,[REP-verzoekstatus]
 -- select top 10 *
from empire_dwh.dbo.tmv_npo_verzoek_uitvoering as DWH
left outer JOIN cte_bkt_codes AS CTE ON CTE.[Sjablooncode taak] = DWH.[REP-TaakSjablooncode]
	AND CTE.Jaar = year(DWH.[REP-OrderGereed])
join empire_dwh.dbo.eenheid as EENH
on EENH.id = DWH.[Sleutel eenheid]
where [REP-TaakSjablooncode] in ( 'R7412', 'R7302','R7303','R7309','R7304', 'R7422')
--and EENH.bk_nr_ = 'OGEH-0039117'









GO
