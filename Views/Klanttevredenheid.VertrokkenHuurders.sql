SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Klanttevredenheid].[VertrokkenHuurders] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'VertrokkenHuurders'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'View die uit A-BI-PROD de enqueteresultaten haalt van betreffende enquete (wordt dagelijks bijgewerkt)',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'SELECT avg(score*1.00) , count(*)
FROM staedion_dm.[Klanttevredenheid].[VertrokkenHuurders] 
WHERE year(Datum) = 2020 and month(Datum) = 1',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders'
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [ingevulddate]',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders',
@level2type = N'Column',@level2name = 'Datum';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [ingevuldtimestamp]',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders',
@level2type = N'Column',@level2name = 'Tijdstip';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [postcode]',    
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'VertrokkenHuurders',
@level2type = N'Column',@level2name = 'Postcode';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [eenheid] maar dan vertaald naar interne nummer dwh-id',    
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Sleutel eenheid',
@level2type = N'Column',@level2name = 'Sleutel eenheid';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [eenheid]',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'Eenheidnr';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [clusternr] maar dan vertaald naar interne nummer dwh-id',    
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = ''Sleutel cluster';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: KCM-csv-bestand - kolom [Verhuurcluster]',    
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel',
@level2type = N'Column',@level2name = 'Verhuurcluster';
;  
######################################################################################### */    
SELECT
  [Datum]                                                   = convert(date,kcm.ingevulddate),
  [Tijdstip]												= kcm.[ingevuldtimestamp],
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
	[Verhuurcluster]										= kcm.verhuurcluster,
  [Score]													= kcm.algemene_tevredenheid

-- select * 
FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt410] AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr

GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View die uit A-BI-PROD de enqueteresultaten haalt van betreffende enquete (wordt dagelijks bijgewerkt)', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT avg(score*1.00) , count(*)
FROM staedion_dm.[Klanttevredenheid].[VertrokkenHuurders] 
WHERE year(Datum) = 2020 and month(Datum) = 1', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [ingevulddate]', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Datum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [eenheid]', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Eenheidnr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [postcode]', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Postcode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [algemene_tevredenheid]', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Score'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [clusternr] maar dan vertaald naar interne nummer dwh-id', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Sleutel cluster'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [eenheid] maar dan vertaald naar interne nummer dwh-id', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Sleutel eenheid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [ingevuldtimestamp]', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Tijdstip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: KCM-csv-bestand - kolom [Verhuurcluster]', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders', 'COLUMN', N'Verhuurcluster'
GO
