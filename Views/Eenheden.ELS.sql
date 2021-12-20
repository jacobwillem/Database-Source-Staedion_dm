SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Eenheden].[ELS]
as
with cte_snapshots as (
  select
    MONTH(datum_gegenereerd) as maand,
    YEAR(datum_gegenereerd) as jaar,
    MAX(datum_gegenereerd) as peildatum,
    'Ultimo maand' as stand_van
  FROM [empire_staedion_data].[dbo].[ELS] as els
  where datum_gegenereerd >= '20200101' 
  group by
    MONTH(datum_gegenereerd),
    YEAR(datum_gegenereerd)
  union
  select distinct
    MONTH(datum_gegenereerd) as maand,
    YEAR(datum_gegenereerd) as jaar,
    datum_gegenereerd as peildatum,
    'Primo maand' as stand_van
  FROM [empire_staedion_data].[dbo].[ELS] as els
  where (DAY(datum_gegenereerd) = 1 and MONTH(datum_gegenereerd) in (1,7))
),
cte_ls as (
  select laatste = MAX(datum_gegenereerd) 
  from [empire_staedion_data].[dbo].[ELS]
)
select
[Sleutel eenheid]                                    = els.[id],
[Datum]                                              = els.[datum_gegenereerd],
[Stand van]                                          = cs.stand_van,
[Meest recent]                                       = case 
                                                         when els.datum_gegenereerd = cte_ls.laatste then 'Ja'
                                                         else 'Nee' 
                                                       end,
[Bedrijf]                                            = els.[da_bedrijf],
[Eenheidnr]                                          = els.[eenheidnr],
[Postcode]                                           = els.[postcode],
[Huisnummer]                                         = els.[huisnummer],
[Straat]                                             = els.[straat],
[Toevoegsel]                                         = els.[toevoegsel],
[Doelgroep]                                          = els.[doelgroep],
[Bouwjaar]                                           = els.[bouwjaar],
[Renovatiejaar]                                      = els.[renovatiejaar],
[Assetmanager]                                       = els.[assetmanager],
[Datum in exploitatie]                               = els.[datum_in_exploitatie],
[Huidige labelconditie]                              = els.[huidige labelconditie],
[Datum uit exploitatie]                              = els.[datum_uit_exploitatie],
[Omschrijving technischtype]                         = els.[omschrijving_technischtype],
[Da staedion groep technischtype]                    = els.[da_staedion_groep_technischtype],
[Corpodata type]                                     = els.[corpodata_type],
[Buurt]                                              = els.[buurt],
[Wijk]                                               = els.[wijk],
[Da plaats]                                          = els.[da_plaats],
[Gemeente]                                           = els.[gemeente],
[Oppervlakte BAG]                                    = els.[oppervlakte_BAG],
[Oppervlakte BVO]                                    = els.[oppervlakte_BVO],
[Oppervlakte VVO]                                    = els.[oppervlakte_VVO],
[Lift]                                               = els.[lift],
[Aantal kamers]                                      = els.[aantal_kamers],
[Seniorenlabel]                                      = els.[seniorenlabel],
[Woonruimte]                                         = els.[woonruimte],
[Aantal sterren toegankelijkheid]                    = els.[Aantal_sterren_toegankelijkheid],
[Verdieping WBS]                                     = els.[verdieping_WBS],
[Betreft]                                            = els.[betreft],
[Administratieve eigenaar]                           = els.[administratieve eigenaar],
[Beheerder]                                          = els.[beheerder],
[Pnt totaal na afronding]                            = els.[pnt_totaal_na_afronding],
[Pnt oppervlakte vertrekken]                         = els.[pnt_oppervlakte_vertrekken],
[Pnt oppervlakte overig]                             = els.[pnt_oppervlakte_overig],
[Pnt verwarming]                                     = els.[pnt_verwarming],
[Pnt keuken]                                         = els.[pnt_keuken],
[Pnt sanitair]                                       = els.[pnt_sanitair],
[Pnt prive buitenruimten]                            = els.[pnt_prive_buitenruimten],
[Pnt bijzondere voorziening]                         = els.[pnt_bijzondere_voorziening],
[Pnt monument]                                       = els.[pnt_monument],
[OppWoonkamer]                                       = els.[oppWoonkamer],
[Oppervlakte Badkamer]                               = els.[oppervlakte Badkamer],
[Oppervlakte Keuken]                                 = els.[oppervlakte Keuken],
[Oppervlakte Overig]                                 = els.[oppervlakte Overig],
[OppSlaapkamer1]                                     = els.[oppSlaapkamer1],
[OppSlaapkamer2]                                     = els.[oppSlaapkamer2],
[OppSlaapkamer3]                                     = els.[oppSlaapkamer3],
[OppSlaapkamer4]                                     = els.[oppSlaapkamer4],
[OppSlaapkamer5]                                     = els.[oppSlaapkamer5],
[OppSlaapkamer6]                                     = els.[oppSlaapkamer6],
[Verwarming]                                         = els.[Verwarming],
[Keuken]                                             = els.[Keuken],
[Zolder]                                             = els.[Zolder],
[Eigen parkeervoorziening aanwezig]                  = els.[Eigen_parkeervoorziening_aanwezig],
[Met fietsenstalling]                                = els.[Met fietsenstalling],
[Met berging]                                        = els.[Met berging],
[Kalehuur]                                           = els.[kalehuur],
[Nettohuur]                                          = els.[nettohuur],
[Brutohuur]                                          = els.[brutohuur],
[Subsidiabelehuur]                                   = els.[subsidiabelehuur],
[Streefhuur]                                         = els.[streefhuur],
[Maximale huur]                                      = els.[maximale_huur],
[Servicekosten]                                      = els.[servicekosten],
[Verbruikskosten incl btw]                           = els.[verbruikskosten_incl_btw],
[Water incl btw]                                     = els.[water_incl_btw],
[Totale servicekosten]                               = els.[totale_servicekosten],
[Huurkorting incl btw]                               = els.[huurkorting_incl_btw],
[Btw compensatie incl btw]                           = els.[btw_compensatie_incl_btw],
[Contactpersoon CB VHTEAM]                           = els.[contactpersoon_CB_VHTEAM],
[Epa-label]                                          = els.[epa-label],
[BAG nr]                                             = els.[BAG_nr],
[BAG straatnaam]                                     = els.[BAG_straatnaam],
[BAG huisnr]                                         = els.[BAG_huisnr],
[BAG huisnr toev]                                    = els.[BAG_huisnr_toev],
[BAG huis letter]                                    = els.[BAG_huis_letter],
[BAG postcode]                                       = els.[BAG_postcode],
[BAG plaats]                                         = els.[BAG_plaats],
[Type monument]                                      = els.[type monument],
[Beschermd stadsgezicht]                             = els.[beschermd stadsgezicht],
[Studentenwoning]                                    = els.[Studentenwoning],
[Clusternummer]                                      = els.[clusternummer],
[Clusternaam]                                        = els.[clusternaam],
[Clustenr oud]                                       = els.[clustenr_oud],
[Clusternaam oud]                                    = els.[clusternaam_oud],
[Bouwbloknummer]                                     = els.[bouwbloknummer],
[Bouwbloknaam]                                       = els.[bouwbloknaam],
[VVE-cluster]                                        = els.[VVE-cluster],
[VVE-clusternaam]                                    = els.[VVE-clusternaam],
[Status VVE]                                         = els.[Status VVE],
[Punten woz]                                         = els.[punten_woz],
[Pnt gemeenschap vertr]                              = els.[pnt_gemeenschap_vertr],
[Pnt gemeenschap ruimtes]                            = els.[pnt_gemeenschap_ruimtes],
[Pnt epa]                                            = els.[pnt_epa],
[Monument]                                           = els.[monument],
[Energiewaardering]                                  = els.[energiewaardering],
[Energieindex]                                       = els.[energieindex],
[Oppervlakte vertrekken]                             = els.[oppervlakte_vertrekken],
[Opp vertr ov ruimte]                                = els.[opp_vertr_ov_ruimte],
[WOZ peil]                                           = els.[WOZ_peil],
[WOZ waarde]                                         = els.[WOZ_waarde],
[Markthuur]                                          = els.[Markthuur],
[Aantal slaapkamers]                                 = els.[aantal_slaapkamers],
[Opmerking]                                          = els.[opmerking],
[Uitgebreide opmerking]                              = els.[uitgebreide_opmerking],
[Reden in exploitatie]                               = els.[Reden in exploitatie],
[Reden uit exploitatie]                              = els.[Reden uit exploitatie],
[Oppervlakte]                                        = els.[oppervlakte],
[Oge type]                                           = els.[oge_type],
[Complex-type]                                       = els.[complex-type],
[Geliberaliseerd]                                    = els.[geliberaliseerd],
[Status eenheidskaart]                               = els.[status_eenheidskaart],
[Vve contactpersoon]                                 = els.[vve_contactpersoon],
[Datum ingang leegstand]                             = els.[datum_ingang_leegstand],
[Datum ingang contract]                              = els.[datum_ingang_contract],
[Juridisch eigenaar]                                 = els.[Juridisch eigenaar],
[VvE vertegenwoordiger]                              = els.[VvE vertegenwoordiger],
[Thuisteam]                                          = els.[Thuisteam],
[Leegwaarde 31-12-2018]                              = els.[Leegwaarde 31-12-2018],
[NettoMarktwaardeVerhuurdeStaat 31-12-2018]          = els.[NettoMarktwaardeVerhuurdeStaat 31-12-2018],
[Markthuur 31-12-2018]                               = els.[Markthuur 31-12-2018],
[Markthuur 31-12-2019]                               = els.[Markthuur 31-12-2019],
[NettoMarktwaardeVerhuurdeStaat 31-12-2019]          = els.[NettoMarktwaardeVerhuurdeStaat 31-12-2019],
[Leegwaarde 31-12-2019]                              = els.[Leegwaarde 31-12-2019],
[Leegstand]                                          = els.[Leegstand],
[VvE (code) Extern]                                  = els.[VvE (code) Extern],
[VvE-beheerder]                                      = els.[VvE-beheerder],
[In Exploitatie]                                     = els.[In Exploitatie],
[Huurbeleid]                                         = els.[Huurbeleid],
[Mutatie-huur]                                       = els.[Mutatie-huur],
[Toilet in badkamer]                                 = els.[Toilet in badkamer],
[Leegwaarde 31-12-2020]                              = els.[Leegwaarde 31-12-2020],
[Marktwaarde in verhuurde staat 31-12-2020]          = els.[Marktwaarde in verhuurde staat 31-12-2020],
[Markthuur (maand) 31-12-2020]                       = els.[Markthuur (maand) 31-12-2020],
[Beleidswaarde 31-12-2020]                           = els.[Beleidswaarde 31-12-2020],
[GO NEN2580 marktwaardering]                         = els.[GO NEN2580 marktwaardering],
[Adres]                                              = els.[Adres]
FROM [empire_staedion_data].[dbo].[ELS] as els
join cte_snapshots as cs on
  cs.peildatum = els.datum_gegenereerd
cross join cte_ls

GO
