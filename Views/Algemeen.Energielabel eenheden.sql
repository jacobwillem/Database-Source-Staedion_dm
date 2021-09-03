SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Algemeen].[Energielabel eenheden]
as


With cte_temp as(

select
  [Sleutel eenheid]                   = o.lt_id,
  [Eenheidnummer]                     = o.nr_,      
  [Datum]                             = d.datum,
  [EPA Energielabel]                  = pve.[EPA-label],
  [Energieindex]                     = convert(numeric(16,2),nullif(pve.[Energy Index], 0)),
  [Afmeld data]                      = pve.[date certificate granted]
  
from empire_data.dbo.vw_lt_mg_oge as o
left join empire_data.dbo.vw_lt_mg_property_valuation as pve on  
  o.mg_bedrijf = pve.mg_bedrijf and 
  o.nr_ = pve.eenheidnr_
join (select distinct datum from empire_dwh.dbo.d_bestand d where datum between dateadd(mm,-24,getdate()) and EOMONTH(getdate())) d on
--join (select datum from empire_dwh.dbo.tijd d where datum between dateadd(mm,-24,getdate()) and EOMONTH(getdate())) d on
  d.datum between pve.ingangsdatum and pve.einddatum
),
cte_label_index as (
	select 
    epa_label, 
    epa_gemiddelde_index
	from empire_staedion_data.dbo.epa
	group by 
    epa_label, 
    epa_gemiddelde_index
),

cte_categorielabel
as (
		select 
      epa_index, 
      epa_label_report, 
      convert(int,left(categorie_report, 2)) as sort,
      substring(categorie_report, 5,50) as Indexkleur
	from empire_staedion_data.dbo.epa
	group by 
    epa_index, 
    epa_label_report, 
    categorie_report
) 

select 
  [Sleutel eenheid],
  [Eenheidnummer],            
  [Datum],                    
  [EPA Energielabel]                  = ccl.epa_label_report,                  
  [Energieindex]                      = isnull(nullif([Energieindex],0), cli.epa_gemiddelde_index),
  [EPA kleurlabel]                    = cli.epa_label,
  [Kleursortering]                    = ccl.sort,
  [Indexkleur]                        = ccl.Indexkleur,
  [Afmeld data]

from cte_temp as ct
left join cte_label_index as cli on cli.epa_label = ct.[EPA Energielabel]
left join cte_categorielabel as ccl on ccl.epa_index = isnull(nullif([Energieindex],0), cli.epa_gemiddelde_index)


GO
