SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Eenheden].[ELS TEST]
AS
WITH cte_snapshots AS (
  SELECT
    MONTH(datum_gegenereerd) AS maand,
    YEAR(datum_gegenereerd) AS jaar,
    MAX(datum_gegenereerd) AS peildatum,
    'Ultimo maand' AS stand_van
  FROM [empire_staedion_data].[dbo].[ELS] AS els
  WHERE datum_gegenereerd >= '20200101' 
  GROUP BY
    MONTH(datum_gegenereerd),
    YEAR(datum_gegenereerd)
  UNION
  SELECT DISTINCT
    MONTH(datum_gegenereerd) AS maand,
    YEAR(datum_gegenereerd) AS jaar,
    datum_gegenereerd AS peildatum,
    'Primo maand' AS stand_van
  FROM [empire_staedion_data].[dbo].[ELS] AS els
  WHERE (DAY(datum_gegenereerd) = 1 AND MONTH(datum_gegenereerd) IN (1,7))
),
cte_ls AS (
  SELECT laatste = MAX(datum_gegenereerd) 
  FROM [empire_staedion_data].[dbo].[ELS]
)
SELECT
[Sleutel eenheid]                                    = els.[id],
[Datum]                                              = els.[datum_gegenereerd],
[Stand van]                                          = cs.stand_van,
[Meest recent]                                       = CASE 
                                                         WHEN els.datum_gegenereerd = cte_ls.laatste THEN 'Ja'
                                                         ELSE 'Nee' 
                                                       END,
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
/*
[BAG bouwjaar]										 = els.[BAG bouwjaar],
*/
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
-- kolommen die moeten worden vervangen door de nieuwe algemenere kolomnamen
	--[Leegwaarde 31-12-2018]                              = els.[Leegwaarde 31-12-2018],
	--[NettoMarktwaardeVerhuurdeStaat 31-12-2018]          = els.[NettoMarktwaardeVerhuurdeStaat 31-12-2018],
	--[Markthuur 31-12-2018]                               = els.[Markthuur 31-12-2018],
	--[Markthuur 31-12-2019]                               = els.[Markthuur 31-12-2019],
	--[NettoMarktwaardeVerhuurdeStaat 31-12-2019]          = els.[NettoMarktwaardeVerhuurdeStaat 31-12-2019],
	--[Leegwaarde 31-12-2019]                              = els.[Leegwaarde 31-12-2019],
--
[Leegstand]                                          = els.[Leegstand],
[VvE (code) Extern]                                  = els.[VvE (code) Extern],
[VvE-beheerder]                                      = els.[VvE-beheerder],
[In Exploitatie]                                     = els.[In Exploitatie],
[Huurbeleid]                                         = els.[Huurbeleid],
[Mutatie-huur]                                       = els.[Mutatie-huur],
[Toilet in badkamer]                                 = els.[Toilet in badkamer],
-- kolommen die moeten worden vervangen door de nieuwe algemenere kolomnamen
	--[Leegwaarde 31-12-2020]                              = els.[Leegwaarde 31-12-2020],
	--[Marktwaarde in verhuurde staat 31-12-2020]          = els.[Marktwaarde in verhuurde staat 31-12-2020],
	--[Markthuur (maand) 31-12-2020]                       = els.[Markthuur (maand) 31-12-2020],
	--[Beleidswaarde 31-12-2020]                           = els.[Beleidswaarde 31-12-2020],

--
[GO NEN2580 marktwaardering]                         = els.[GO NEN2580 marktwaardering],
[Adres]                                              = els.[Adres]
--/* Nog toe te voegen kolommen aan de view
,
[Gebruiksoppervlakte conform NTA 8800]				 = els.[Gebruiksoppervlakte conform NTA 8800],
[Energielabel conform NTA8800]						 = els.[Energielabel conform NTA8800],
[Gem. ruimte in berekening]							 = els.[Gem. ruimte in berekening],
[Oppervlakte berekend]								 = els.[Oppervlakte berekend],
[Punten oppervlakte]								 = els.[Punten oppervlakte],
[(Eigen) Verwarmde vertrekken]						 = els.[(Eigen) Verwarmde vertrekken],
[Punten oppervlakte verwarmd]						 = els.[Punten oppervlakte verwarmd],
[Thermonstatische regelknoppen]						 = els.[Thermonstatische regelknoppen],
[Punten thermonstatische regelknoppen]				 = els.[Punten thermonstatische regelknoppen],
[Gasaansluiting]									 = els.[Gasaansluiting],
[Punten gasaansluiting]								 = els.[Punten gasaansluiting],
[Gemeenschappelijke Keuken]							 = els.[Gemeenschappelijke Keuken],
[Punten gem. keuken]								 = els.[Punten gem. keuken],
[Gemeenschappelijke douche/bad]						 = els.[Gemeenschappelijke douche/bad],
[Punten gem. douche/bad]							 = els.[Punten gem. douche/bad],
[Gemeenschappelijke Wastafel]						 = els.[Gemeenschappelijke Wastafel],
[Punten gem. wastafel]								 = els.[Punten gem. wastafel],
[Gemeenschappelijk Toilet]							 = els.[Gemeenschappelijk Toilet],
[Punten gem. toilet]								 = els.[Punten gem. toilet],
[Gemeenschappelijke buitenruimte]					 = els.[Gemeenschappelijke buitenruimte],
[Punten gem. buitenruimte]							 = els.[Punten gem. buitenruimte],
[Fietsenberging]									 = els.[Fietsenberging],
[Punten fietsenberging]								 = els.[Punten fietsenberging],
[(Aftrek) Vloeropp <10 m²]							 = els.[(Aftrek) Vloeropp <10 m²],
[(Aftrek) Overlast]									 = els.[(Aftrek) Overlast],
[(Aftrek) Toilet indirect bereikbaar]				 = els.[(Aftrek) Toilet indirect bereikbaar],
[(Aftrek) Verdieping > 4 zonder lift]				 = els.[(Aftrek) Verdieping > 4 zonder lift],
[(Aftrek) Ramen <0,75 m²]							 = els.[(Aftrek) Ramen <0,75 m²],
[(Aftrek) Raam hoger 1,6 m]							 = els.[(Aftrek) Raam hoger 1,6 m],
[(Aftrek) Gevel <5 m]								 = els.[(Aftrek) Gevel <5 m],
[(Aftrek) Niet koken]								 = els.[(Aftrek) Niet koken],
-- nieuwe kolommen ter vervanging van de kolommen met namen waarin de peildatum is opgenomen
[Peildatum beleidswaarden]							 = els.[Peildatum beleidswaarden],
[Leegwaarde]										 = els.[Leegwaarde],
[Netto marktwaarde verhuurde staat]					 = els.[Netto marktwaarde verhuurde staat],
[Markthuur (maand)]									 = els.[Markthuur (maand)],
[Beleidswaarde]										 = els.[Beleidswaarde]

	,[Leegwaarde 31-12-2018]                              = TMS_2018.[Leegwaarde]
	,[Marktwaarde in verhuurde staat 31-12-2018]          = TMS_2018.[Netto marktwaarde]
	,[Markthuur (maand) 31-12-2018]                       = TMS_2018.[Markthuur per maand]
	,[Beleidswaarde 31-12-2018]                           = TMS_2018.[Beleidswaarde]

	,[Leegwaarde 31-12-2019]                              = TMS_2019.[Leegwaarde]
	,[Marktwaarde in verhuurde staat 31-12-2019]          = TMS_2019.[Netto marktwaarde]
	,[Markthuur (maand) 31-12-2019]                       = TMS_2019.[Markthuur per maand]
	,[Beleidswaarde 31-12-2019]                           = TMS_2019.[Beleidswaarde]

	,[Leegwaarde 31-12-2020]                              = TMS_2020.[Leegwaarde]
	,[Marktwaarde in verhuurde staat 31-12-2020]          = TMS_2020.[Netto marktwaarde]
	,[Markthuur (maand) 31-12-2020]                       = TMS_2020.[Markthuur per maand]
	,[Beleidswaarde 31-12-2020]                           = TMS_2020.[Beleidswaarde]

	,[Leegwaarde 31-12-2021]                              = TMS_2021.[Leegwaarde]
	,[Marktwaarde in verhuurde staat 31-12-2021]          = TMS_2021.[Netto marktwaarde]
	,[Markthuur (maand) 31-12-2021]                       = TMS_2021.[Markthuur per maand]
	,[Beleidswaarde 31-12-2021]                           = TMS_2021.[Beleidswaarde]

	,[Leegwaarde 31-12-2022]                              = TMS_2022.[Leegwaarde]
	,[Marktwaarde in verhuurde staat 31-12-2022]          = TMS_2022.[Netto marktwaarde]
	,[Markthuur (maand) 31-12-2022]                       = TMS_2022.[Markthuur per maand]
	,[Beleidswaarde 31-12-2022]                           = TMS_2022.[Beleidswaarde]


FROM [empire_staedion_data].[dbo].[ELS] AS els
JOIN cte_snapshots AS cs ON
  cs.peildatum = els.datum_gegenereerd
CROSS JOIN cte_ls
LEFT OUTER JOIN staedion_dm.tms.MarktwaardeHistorie  AS TMS_2018 ON TMS_2018.Eenheidnr = ELS.eenheidnr AND TMS_2018.peildatum = '20181231' AND YEAR(ELS.datum_gegenereerd) >= 2018
LEFT OUTER JOIN staedion_dm.tms.MarktwaardeHistorie  AS TMS_2019 ON TMS_2019.Eenheidnr = ELS.eenheidnr AND TMS_2019.peildatum = '20191231' AND YEAR(ELS.datum_gegenereerd) >= 2019
LEFT OUTER JOIN staedion_dm.tms.MarktwaardeHistorie  AS TMS_2020 ON TMS_2020.Eenheidnr = ELS.eenheidnr AND TMS_2020.peildatum = '20201231' AND YEAR(ELS.datum_gegenereerd) >= 2020
LEFT OUTER JOIN staedion_dm.tms.MarktwaardeHistorie  AS TMS_2021 ON TMS_2021.Eenheidnr = ELS.eenheidnr AND TMS_2021.peildatum = '20211231' AND YEAR(ELS.datum_gegenereerd) >= 2021
LEFT OUTER JOIN staedion_dm.tms.MarktwaardeHistorie  AS TMS_2022 ON TMS_2022.Eenheidnr = ELS.eenheidnr AND TMS_2022.peildatum = '20221231' AND YEAR(ELS.datum_gegenereerd) >= 2022
--WHERE datum_gegenereerd > '20220131'
GO
