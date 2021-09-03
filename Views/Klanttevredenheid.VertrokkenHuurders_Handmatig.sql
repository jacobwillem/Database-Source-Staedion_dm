SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE view [Klanttevredenheid].[VertrokkenHuurders_Handmatig] as
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
  [Datum]                           = convert(date,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= convert(time,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                 = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 								= cluster.lt_id,
	[Verhuurcluster]									= kcm.verhuurcluster,
	[clusternr]											= kcm.clusternr,
  [Score]														= kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion]
-- select * 
FROM empire_Staedion_Data.kcm.STN410_Ingevulde_gegevens as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr

union

SELECT
  [Datum]                           = convert(date,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= convert(time,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                 = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 								= cluster.lt_id,
	[Verhuurcluster]									= kcm.verhuurcluster,
	[clusternr]											= kcm.clusternr,
  [Score]														= kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion]
-- select * 
FROM empire_Staedion_Data.kcm.STN410_Ingevulde_gegevens_2019 as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr

GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View die uit A-BI-PROD de enqueteresultaten haalt van betreffende enquete (wordt dagelijks bijgewerkt)', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT avg(score*1.00) , count(*)
FROM staedion_dm.[Klanttevredenheid].[VertrokkenHuurders_Handmatig] 
WHERE year(Datum) = 2020 and month(Datum) = 1', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'VertrokkenHuurders_Handmatig', NULL, NULL
GO
