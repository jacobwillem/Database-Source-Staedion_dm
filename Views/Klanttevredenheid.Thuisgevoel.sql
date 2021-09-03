SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Klanttevredenheid].[Thuisgevoel] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Thuisgevoel'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'View die uit A-BI-PROD de enqueteresultaten haalt van betreffende enquete (wordt dagelijks bijgewerkt)',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'SELECT avg(woningkwaliteit_score*1.00) 
FROM staedion_dm.[Klanttevredenheid].[Thuisgevoel] 
WHERE year(ingevulddate) = 2019',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel'
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'KOLOM';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'KOLOM';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'KOLOM';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'KOLOM';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'KOLOM';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'KOLOM';
;  

######################################################################################### */    
SELECT
  [Datum]                                                   = convert(date,kcm.ingevulddate),
  [Tijdstip]												= kcm.[ingevuldtimestamp],
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  [Voelt zich thuis]                                        = case when kcm.voelt_zich_thuis = 1 then 'Ja' else 'Nee' end,
  [Indicator Voelt zich thuis]                              = kcm.voelt_zich_thuis ,
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
-- select * 
FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt409] AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr

GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View die uit A-BI-PROD de enqueteresultaten haalt van betreffende enquete (wordt dagelijks bijgewerkt)', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT avg([Indicator Voelt zich thuis]*1.00)   FROM staedion_dm.[Klanttevredenheid].[Thuisgevoel]   WHERE year(datum) = 2019', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel', NULL, NULL
GO
