SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE VIEW [Klanttevredenheid].[BKT_Handmatig] AS
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
  [Datum]                                                   = CONVERT(DATE,kcm.[Ingevulde gegevens]),
  [Tijdstip]												= CONVERT(TIME,kcm.[Ingevulde gegevens]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                        = oge.lt_id,
  [Eenheidnr]																		= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
	[Sleutel leverancier]																			= kcm.[Leveranciersnr],
	[Leveranciersnaam]												= kcm.[leveranciersnaam],
  [Score]													= kcm.[Wat vond u van de manier waarop de aannemer de verbouwing heeft ]
-- 20220117 [Welk rapportcijfer geeft u voor de dienstverlening van Staedion]
-- FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt407] AS kcm
FROM empire_Staedion_Data.kcm.STN647_Ingevulde_gegevens AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON 
  oge.mg_bedrijf = 'Staedion' AND
  oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON 
  oge.mg_bedrijf = 'Staedion' AND
  cluster.Nr_ = kcm.clusternr

UNION

SELECT
  [Datum]                                                   = CONVERT(DATE,kcm.[Ingevulde gegevens]),
  [Tijdstip]																								= CONVERT(TIME,kcm.[Ingevulde gegevens]),
  [Postcode]																								= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]																								= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
	[Sleutel leverancier]																			= kcm.[Leveranciersnr],
	[Leveranciersnaam]																				= kcm.[leveranciersnaam],
  [Score]																										= kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion]
-- FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt407] AS kcm
FROM empire_Staedion_Data.kcm.STN647_Ingevulde_gegevens_2019 AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON 
  oge.mg_bedrijf = 'Staedion' AND
  oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON 
  oge.mg_bedrijf = 'Staedion' AND
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
