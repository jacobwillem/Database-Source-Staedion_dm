SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [Klanttevredenheid].[Enquete] as

select
  [Datum]                                                   = convert(date,kcm.ingevulddate),
  [Sleutel eenheid]                                         = oge.lt_id,
  [Voelt zich thuis]                                        = case when kcm.voelt_zich_thuis = 1 then 'Ja' else 'Nee' end,
  [Algemene ruimte aanwezig]                                = case when kcm.algemene_ruimten_aanwezig = 1 then 'Ja' else 'Nee' end,
  [Vragen overgeslagen]                                     = case when kcm.vragen_overgeslagen = 1 then 'Ja' else 'Nee' end,
  [Verhuizen binnen een jaar]                               = kcm.verhuizen_binnen_jaar_choice,
  [Gezinssamenstelling]                                     = kcm.gezinsamenstelling_choice,
  [Financiele situatie]                                     = kcm.financiele_situatie_choice,
  [Aantal personen inwonend]                                = kcm.aantal_personen_inwonend_choice,
  [Gezondheid]                                              = kcm.gezondheid_omschrijving_choice,
  [Hulpafhankelijk]                                         = kcm.hulp_afhankelijk_choice,
  [Toesteming voor contact]                                 = case when kcm.contact_toestemming = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = kcm.andere_suggestie_text,
  [Score thuisgevoel]                                       = kcm.thuisgevoel_score,
  [Score woningkwaliteit]                                   = kcm.woningkwaliteit_score,
  [Score staat keuken/badkamer/toilet]                      = kcm.staat_keukenbadkamertoilet_score,
  [Score energiezuinig]                                     = kcm.energiezuinig_score,
  [Score gehorig]                                           = kcm.gehorig_score,
  [Score gevoelstemperatuur]                                = kcm.gevoelstemperatuur_score,
  [Score prijskwaliteit]                                    = kcm.prijskwaliteit_score,
  [Score inbraakveilig]                                     = kcm.inbraakveilig_score,
  [Score algemene ruimten]                                  = kcm.algemene_ruimten_score,
  [Score algemene ruimten netheid]                          = kcm.algemene_ruimten_netheid_score,
  [Score algemene ruimten verlichting]                      = kcm.algemene_ruimten_verlichting_score,
  [Score algemene ruimten veilig]                           = kcm.algemene_ruimten_veilig_score,
  [Score buurt]                                             = kcm.buurt_score,
  [Score buurt overlast]                                    = kcm.buurt_overlast_score,
  [Score buurt netheid]                                     = kcm.buurt_netheid_score,
  [Score buurt veilig]                                      = kcm.buurt_veilig_score,
  [Score buurt contact]                                     = kcm.buurt_contact_score
from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
GO
