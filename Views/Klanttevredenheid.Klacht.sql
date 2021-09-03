SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Klanttevredenheid].[Klacht] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Klacht'
######################################################################################### */    
SELECT
  [Datum]                                                   = convert(date,kcm.ingevulddate),
  [Tijdstip]																								= kcm.[ingevuldtimestamp],
  [Postcode]																								= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]																								= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
	Thuisteam																									= kcm.divisie,
  [Score]																										= kcm.algemene_tevredenheid,
	Klachtnummer																							= KCM.klachtnummer

-- select * 
FROM [A-bI-PROD].datamart.[kcm].[fac_kcm_snt417] AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr


GO
