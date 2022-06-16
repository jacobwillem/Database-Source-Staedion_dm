SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE view [Algemeen].[Vabi Energielabel eenheden]
as
-- JvdW 20200501: dubbele regels bij sommige eenheden per maand
With 
cte_vabi as(
  select 
    oge = vhe,
    energie_index_afgemeld as energie_index,
		ep1_energiebehoefte,
		ep2_fossielenergiegebruik,
    energie_index_ep2_emg_forfaitair,
    nettowarmtebehoefte, 
    standaard_nettowarmtebehoefte,
    gasverbruik_m3_jaar,
		co2_uitstoot,
    d.datum,
    afmelddatum,
    energielabel_afgemeld,
		opnamedatum = datefromparts(opnamejaar, opnamemaand, opnamedag),
		status_label_1,
		deelvoorraad,
    pre_label,
		volgnr = row_number() OVER (partition by vab.vhe, d.datum order by vab.date_from desc) -- JvdW: om uit te sluiten dat er dubbele regels voorkomen 
	from TS_data.dbo.[vabi_onroerendgoed_energie_waardering]  as vab
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
  [Sleutel eenheid]                   = o.lt_id,
  [Eenheidnummer]                     = o.nr_,      
  [Datum]                             = vab.datum,
  [Energieindex]                      = vab.energie_index,
  [EP1 energiebehoefte]				        = vab.ep1_energiebehoefte,
  [EP2 fossielenergiegebruik]		      = vab.ep2_fossielenergiegebruik,
  [EP2 EMG Forfaitair]                = vab.energie_index_ep2_emg_forfaitair,
  [Nettowarmtebehoefte]               = vab.nettowarmtebehoefte,
  [Nettowarmtebehoefte standaard]     = vab.standaard_nettowarmtebehoefte,
  [Gasverbruik m3 per jaar]           = vab.gasverbruik_m3_jaar,
  [CO2 uitstoot]					            = vab.co2_uitstoot,
  [Afmeld data]                       = vab.afmelddatum,
  [Opname data]						            = vab.opnamedatum,
  [Status label]					            = vab.status_label_1,
  [Deelvoorraad]					            = vab.deelvoorraad,
  [EPA Energielabel afgemeld]         = vab.energielabel_afgemeld,
  pre_label,
  vab.volgnr,
  o.mg_bedrijf
from empire_data.dbo.vw_lt_mg_oge as o
left join cte_vabi as vab on vab.oge = o.Nr_
AND vab.volgnr = 1
where o.mg_bedrijf = 'Staedion' -- JvdW: toegevoegd - soms oge's in meerdere bedrijven
),
cte_categorielabel
as (
		select 
      epa_index, 
      epa_label, 
      convert(int,left(categorie_report, 2)) as sort,
      substring(categorie_report, 5,50) as Indexkleur
	from empire_staedion_data.dbo.epa
	group by 
    epa_index, 
    epa_label, 
    categorie_report
),
cte_kleur as (
select distinct  
  epa_label, 
  substring(categorie_report, 5,50) as Indexkleur
from empire_staedion_data.dbo.epa
)
select 
  [Sleutel eenheid],
  [Eenheidnummer],            
  [Datum],                    
  [EPA Energielabel]                  = coalesce([EPA Energielabel afgemeld], ep2.label, ei.label),                 
  [EPA Energielabel afgemeld],
  [EPA Energielabel Pre]              = pre_label,
  [EPA Energielabel sortering]        = case coalesce([EPA Energielabel afgemeld],ep2.label, ei.label)
                                          when 'A++++' then 1
                                          when 'A+++' then 2
                                          when 'A++' then 3
                                          when 'A+' then 4
                                          when 'A' then 5
                                          when 'B' then 6
                                          when 'C' then 7
                                          when 'D' then 8
                                          when 'E' then 9
                                          when 'F' then 10
                                          when 'G' then 11
                                          else 12
                                        end,                 
  [Energieindex]                      = ct.Energieindex,
  [EPA Energielabel obv energieindex] = ei.label,
  [EPA kleurlabel]                    = ccl.epa_label,
  [Kleursortering]                    = ccl.sort,
  [Indexkleur]                        = cc.Indexkleur,
  [EP1 energiebehoefte]				        = ct.[EP1 energiebehoefte],
  [EP2 fossielenergiegebruik]		      = ct.[EP2 fossielenergiegebruik],
  [EP2 EMG Forfaitair]                = ct.[EP2 EMG Forfaitair],
  [Nettowarmtebehoefte]               = ct.Nettowarmtebehoefte,
  [Nettowarmtebehoefte standaard]     = ct.[Nettowarmtebehoefte standaard],
  [Gasverbruik m3 per jaar]           = ct.[Gasverbruik m3 per jaar],
  [EPA Energielabel obv EP2]          = ep2.label,
  [CO2 uitstoot]					            = ct.[CO2 uitstoot],
  [Afmeld data],
  [Opname data],
  [Afgemeld]						              = iif(format([Datum], 'yyyyMM') = format([Afmeld data], 'yyyyMM'), 1, 0),
  [Status label],
  [Deelvoorraad],
  ct.mg_bedrijf,
  ct.volgnr
from cte_temp as ct
left join cte_categorielabel as ccl on ccl.epa_index = ct.Energieindex
left join Energie.EP2_naar_label as ep2 on
  ep2.ep2_van < ct.[EP2 fossielenergiegebruik] and
  ep2.ep2_tm >= ct.[EP2 fossielenergiegebruik]
left join Energie.ei_naar_label as ei on
  ei.ei_van <= ct.Energieindex and
  ei.ei_tm >= ct.energieindex
left join cte_kleur as cc on cc.epa_label = coalesce([EPA Energielabel afgemeld],ep2.label, ei.label)



GO
