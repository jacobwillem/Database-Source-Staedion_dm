SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Algemeen].[Vabi Energielabel eenheden]
as
-- JvdW 20200501: dubbele regels bij sommige eenheden per maand
With 
cte_vabi as(
  select oge,
         energie_index,
		 ep1_energiebehoefte,
		 ep2_fossielenergiegebruik,
		 co2_uitstoot,
         d.datum,
         afmelddatum,
		 opnamedatum = datefromparts(opnamejaar, opnamemaand, opnamedag),
		 status_label_1,
		 deelvoorraad,
		 volgnr = row_number() OVER (partition by vab.oge, d.datum order by vab.id desc) -- JvdW: om uit te sluiten dat er dubbele regels voorkomen 
	from TS_data.dbo.[dim_vabi_onroerend_eenheden]  as vab
  --from [A-BI-PROD.vault].[vault].[dimensions].[dim_vabi_onroerend_eenheden] as vab
  --join (select datum from empire_dwh.dbo.tijd d where datum between dateadd(mm,-24,getdate()) and EOMONTH(getdate())) d on
  join (select distinct datum from empire_dwh.dbo.d_bestand d where datum between dateadd(mm,-24,getdate()) and EOMONTH(getdate())) d on
  d.datum between vab.date_from and vab.date_to
--where day(dateadd(dd,1,d.datum)) = 1
and deelvoorraad in ('Staedion', 'Staedion (nieuwbouw)', 'Atriensis - Extern', 'Atriensis - Extern (nieuwbouw)', 'Breman - Extern', 'Breman - Extern (nieuwbouw)')
		-- MV 20200507: Staedion aangevuld met Atriensis en Breman nav overleg Jerry Lindenhof
		-- MV 20211104: Nieuwbouw varianten toegevoegd nav overleg Jana Grambow & Geert-Hein Bolder
  ),
cte_temp as(

select
  [Sleutel eenheid]                  = o.lt_id,
  [Eenheidnummer]                    = o.nr_,      
  [Datum]                            = vab.datum,
  [Energieindex]                     = vab.energie_index,
  [EP1 energiebehoefte]				 = vab.ep1_energiebehoefte,
  [EP2 fossielenergiegebruik]		 = vab.ep2_fossielenergiegebruik,
  [CO2 uitstoot]					 = vab.co2_uitstoot,
  [Afmeld data]                      = vab.afmelddatum,
  [Opname data]						 = vab.opnamedatum,
  [Status label]					 = vab.status_label_1,
  [Deelvoorraad]					 = vab.deelvoorraad
  ,vab.volgnr
  ,o.mg_bedrijf
from empire_data.dbo.vw_lt_mg_oge as o
left join cte_vabi as vab on vab.oge = o.Nr_
AND vab.volgnr = 1
where o.mg_bedrijf = 'Staedion' -- JvdW: toegevoegd - soms oge's in meerdere bedrijven
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
  [Energieindex]                      = ct.Energieindex,
  [EPA kleurlabel]                    = ccl.epa_label_report,
  [Kleursortering]                    = ccl.sort,
  [Indexkleur]                        = ccl.Indexkleur,
  [EP1 energiebehoefte]				  = ct.[EP1 energiebehoefte],
  [EP2 fossielenergiegebruik]		  = ct.[EP2 fossielenergiegebruik],
  [CO2 uitstoot]					  = ct.[CO2 uitstoot],
  [Afmeld data],
  [Opname data],
  [Afgemeld]						  = iif(format([Datum], 'yyyyMM') = format([Afmeld data], 'yyyyMM'), 1, 0),
  [Status label],
  [Deelvoorraad],
  ct.mg_bedrijf,
  ct.volgnr
from cte_temp as ct
left join cte_categorielabel as ccl on ccl.epa_index = ct.Energieindex



GO
