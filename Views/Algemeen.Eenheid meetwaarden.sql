SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [Algemeen].[Eenheid meetwaarden]
as
with cte_kv as (
  select
    Eenheidnr,
    Peildatum = EOMONTH(peildatum),
    kernvoorraad,
    opmerking,
    prio = ROW_NUMBER() over (partition by eenheidnr, peildatum order by eenheidnr, peildatum)
  from Eenheden.Kernvoorraad 
),
--cte_mutatiehuur as (
--  select 
--    e.id, 
--    streefhuur_oud as mutatiehuur,
--    bbm.id as fk_bbshklasse_id   
--  from empire_dwh.dbo.eenheid as e
--  outer apply empire_staedion_data.[dbo].[ITVfnHuurprijs](e.bk_nr_, GETDATE()) as hpr
--  left join empire_dwh.dbo.bbshklasse bbm on
--	  getdate() between bbm.vanaf and bbm.tot and
--	  hpr.streefhuur_oud between bbm.minimum and bbm.maximum 
--),
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
cte_woz as (
  select
    mg_bedrijf,
    eenheidnr_,
    [WOZ-taxatiewaarde] as woz,
    [woz-peildatum] as peildatum,
    prio = ROW_NUMBER() over (partition by mg_bedrijf, eenheidnr_ order by [woz-peildatum] desc)
  from empire_data.dbo.vw_lt_mg_wozgegevens wz
)
select
  [Datum]                           = db.datum,
  [Sleutel eenheid]                 = db.fk_eenheid_id,
  [Sleutel huurklasse]              = db.fk_bbshklasse_id_eenheid,
  [Sleutel huurklasse obv kaal]     = db.fk_bbshklasse_obv_kale_id,
  [Sleutel huurklasse obv streef]   = db.fk_bbshklasse_obv_streef_id,
  [Sleutel huurklasse obv mutatie]  = bbm.id,
  [Is kernvoorraad]                 = case when ehk.Kernvoorraad = 1 then 'Ja' else 'Nee' end,
  [Opmerking kernvoorraad]          = ehk.Opmerking,
  [Datum in exploitatie]            = e.dt_in_exploitatie,
  [Datum uit exploitatie]           = e.dt_uit_exploitatie,
  [Eenheidsnummer]                  = e.bk_nr_,
  [Nettohuur]                       = db.nettohuur,
  [Streefhuur]                      = db.streefhuur,
  [Maximale huur]                   = db.maxredelijkehuur,
  [Markthuur]                       = ae.markthuur,
  [Mutatiehuur]                     = COALESCE(HPR.mutatiehuur,ae.markthuur),			-- JVDW 20210311 coalesce toegevoegd
  [Marktwaarde]                     = ae.Marktwaarde,
  [Leegwaarde]                      = ae.leegwaarde,
  [Beleidswaarde]                   = ae.beleidswaarde,
  [WOZ-waarde]                      = woz.woz,
  [WOZ-peildatum]                   = woz.peildatum,
  [DAEB]                            = case 
                                        when daeb.id in (1,3) then 'DAEB'
                                        when daeb.id in (2,4) then 'Niet-DAEB'
                                        else 'Onbekend, nvt' 
                                      end,
  [DAEB-indicator]                  = daeb.descr,
  [EPA Energielabel]                = ccl.epa_label_report,                  
  [Energieindex]                    = isnull(nullif([Energieindex],0), cli.epa_gemiddelde_index),
  [EPA kleurlabel]                  = cli.epa_label,
  [Kleursortering]                  = ccl.sort,
  [Indexkleur]                      = ccl.Indexkleur
from empire_dwh.dbo.d_bestand as db
join Algemeen.eenheid as ae on
  ae.Sleutel = db.fk_eenheid_id and
  ae.[Datum in exploitatie] <= db.datum and
  ae.[Einde exploitatie] > db.datum
left join empire_dwh.dbo.eenheid as e on 
  e.id = db.fk_eenheid_id
left join empire_dwh.dbo.eenheidspunt as ep on
  ep.id = db.fk_eenheidspunt_id_eenheid
left join empire_dwh.dbo.epa_energielabel as epa on
  epa.id = db.fk_epa_energielabel_id_eenheid
left join cte_label_index as cli on cli.epa_label = epa.bk_code
left join cte_categorielabel as ccl on ccl.epa_index = isnull(nullif([Energieindex],0), cli.epa_gemiddelde_index)
left join cte_kv as ehk on
  ehk.Eenheidnr = e.bk_nr_ and
  eomonth(ehk.Peildatum) = eomonth(db.datum) and
  ehk.prio = 1
left join empire_dwh..daebindicator as daeb on
  daeb.id = db.fk_daebindicator_id_eenheid
left join cte_woz as woz on 
  woz.Eenheidnr_ = e.bk_nr_ and
  woz.mg_bedrijf = e.da_bedrijf and
  woz.prio = 1
left join algemeen.mutatiehuur as hpr on 
  hpr.Eenheidnr = e.bk_nr_ and
  hpr.datum = db.datum and
  e.da_bedrijf = 'Staedion'
left join empire_dwh.dbo.bbshklasse bbm on
	db.datum between bbm.vanaf and bbm.tot and
	hpr.Mutatiehuur between bbm.minimum and bbm.maximum 
--left join cte_mutatiehuur as cm on
--  cm.id = e.id
where db.datum > dateadd(yy,-3,getdate())
and e.da_soorteenheid = 'vhe'
GO
