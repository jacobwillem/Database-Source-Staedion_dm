SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [Klanttevredenheid].[BKT_Handmatig] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'BKT_Handmatig'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'View die uit handmatig ingelezen dump csv de enqueteresultaten haalt van betreffende enquete',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'BKT_Handmatig'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'BKT_Handmatig'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'SELECT avg(score*1.00) 
FROM staedion_dm.[Klanttevredenheid].[BKT_Handmatig] 
WHERE year(Datum) = 2020',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'BKT_Handmatig'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'BKT_Handmatig'
;  

;  
######################################################################################### */    
SELECT
  [Datum]                                                   = convert(date,kcm.[Ingevulde gegevens]),
  [Tijdstip]																								= convert(time,kcm.[Ingevulde gegevens]),
  [Postcode]																								= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]																								= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
	[Sleutel leverancier]																			= kcm.[Leveranciersnr],
	[Leveranciersnaam]																				= kcm.[leveranciersnaam],
  [Score]																										= kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion]
-- FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt407] AS kcm
FROM empire_Staedion_Data.kcm.STN647_Ingevulde_gegevens as kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr

UNION

SELECT
  [Datum]                                                   = convert(date,kcm.[Ingevulde gegevens]),
  [Tijdstip]																								= convert(time,kcm.[Ingevulde gegevens]),
  [Postcode]																								= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]																								= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
	[Sleutel leverancier]																			= kcm.[Leveranciersnr],
	[Leveranciersnaam]																				= kcm.[leveranciersnaam],
  [Score]																										= kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion]
-- FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt407] AS kcm
FROM empire_Staedion_Data.kcm.STN647_Ingevulde_gegevens_2019 as kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr



GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'BKT_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'BKT_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View die uit handmatig ingelezen dump csv de enqueteresultaten haalt van betreffende enquete', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'BKT_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT avg(score*1.00) 
FROM staedion_dm.[Klanttevredenheid].[BKT_Handmatig] 
WHERE year(Datum) = 2020', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'BKT_Handmatig', NULL, NULL
GO
