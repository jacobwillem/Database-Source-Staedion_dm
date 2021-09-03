SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Klanttevredenheid].[DagelijksOnderhoud] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'DagelijksOnderhoud'

######################################################################################### */    
SELECT
  [Datum]                                                   = convert(date,kcm.ingevulddate),
  [Tijdstip]																								= kcm.[ingevuldtimestamp],
  [Postcode]																								= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]																								= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
  [Score]																								    = kcm.algemene_tevredenheid,
  [Suggesties]                                              = kcm.suggestie_string,
  [Aantal benodigde bezoeken volgens klant]                 = kcm.aantal_benodigde_bezoeken_string,
  [Verbetersuggestie]																				= kcm.suggestie_string,
  [Medewerker]																							= kcm.geplande_resource,
  Reparatieverzoeknr																				= kcm.reparatieverzoeknr,
  [Omschrijving onderhoudssjabloon]		                      = kcm.omschrijving,
  Onderhoudssjabloon		                                    = kcm.onderhoudssjabloon,
	Leveranciersnr																						= 'Eigen dienst',
	Leverancier																								= 'Eigen dienst',
	Bron																											= 'fac_kcm_snt411 - intern'
-- select * 
FROM [A-bI-PROD].datamart.[kcm].fac_kcm_snt411 AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr

UNION

SELECT
  [Datum]                                                   = convert(date,kcm.ingevulddate),
  [Tijdstip]																								= kcm.[ingevuldtimestamp],
  [Postcode]																								= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]																								= kcm.eenheidnr,
  [Sleutel cluster] 																				= cluster.lt_id,
  [Score]																								    = kcm.algemene_tevredenheid,
  [Suggesties]                                              = kcm.suggestie_string,
  [Aantal benodigde bezoeken volgens klant]                 = kcm.aantal_benodigde_bezoeken_string,
  [Verbetersuggestie]																				= kcm.suggestie_string,
  [Medewerker]																							= kcm.geplande_resource,
  Reparatieverzoeknr																				= kcm.reparatieverzoeknr,
  [Omschrijving onderhoudssjabloon]		                      = kcm.omschrijving,
  Onderhoudssjabloon		                                    = kcm.onderhoudssjabloon,
	Leveranciersnr																						= kcm.leveranciersnr,
	Leverancier																								= kcm.leveranciersnaam,
	Bron																											= 'fac_kcm_snt459 - extern'
-- select * 
FROM [A-bI-PROD].datamart.[kcm].fac_kcm_snt459 AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr


GO
