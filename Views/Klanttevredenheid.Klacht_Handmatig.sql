SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Klanttevredenheid].[Klacht_Handmatig] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Klacht'

20210607 JvdW
> bronbestand was
+ select * from empire_staedion_data.[kcm].[STN417_Ingevulde_gegevens]
> bronbestand nu opgebouwd uit:
+ select * from empire_staedion_data.[kcm].[STN417_Ingevulde_gegevens_Online]
+ select * from empire_staedion_data.[kcm].[STN417_Ingevulde_gegevens_Telefonisch]

select count(*),avg(Score) from staedion_dm.[Klanttevredenheid].[Klacht_Handmatig] where year(Datum) = 2021

######################################################################################### */    
SELECT [Datum] = convert(DATE, kcm.[INGEVULDE GEGEVENS])
	,[Tijdstip] = convert(TIME, kcm.[INGEVULDE GEGEVENS])
	,[Postcode] = kcm.postcode
	,[Sleutel eenheid] = oge.lt_id
	,[Eenheidnr] = kcm.eenheidnr
	,[Sleutel cluster] = cluster.lt_id
	,Thuisteam = kcm.divisie
	,[Score] = kcm.[Welk rapportcijfer geeft u Staedion voor de behandeling van uw k]
	,Klachtnummer = KCM.klachtnummer
-- select * 
FROM empire_staedion_data.kcm.STN417_Ingevulde_gegevens_Online AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON oge.mg_bedrijf = 'Staedion'
	AND oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON oge.mg_bedrijf = 'Staedion'
	AND cluster.Nr_ = kcm.clusternr

UNION


SELECT [Datum] = convert(DATE, kcm.[INGEVULDE GEGEVENS])
	,[Tijdstip] = convert(TIME, kcm.[INGEVULDE GEGEVENS])
	,[Postcode] = kcm.postcode
	,[Sleutel eenheid] = oge.lt_id
	,[Eenheidnr] = kcm.eenheidnr
	,[Sleutel cluster] = cluster.lt_id
	,Thuisteam = kcm.divisie
	,[Score] = kcm.[Welk rapportcijfer geeft u Staedion voor de behandeling van uw k]
	,Klachtnummer = KCM.klachtnummer
-- select * 
FROM empire_staedion_data.kcm.[STN417_Ingevulde_gegevens_Telefonisch] AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON oge.mg_bedrijf = 'Staedion'
	AND oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON oge.mg_bedrijf = 'Staedion'
	AND cluster.Nr_ = kcm.clusternr

UNION


SELECT [Datum] = convert(DATE, kcm.[INGEVULDE GEGEVENS])
	,[Tijdstip] = convert(TIME, kcm.[INGEVULDE GEGEVENS])
	,[Postcode] = kcm.postcode
	,[Sleutel eenheid] = oge.lt_id
	,[Eenheidnr] = kcm.eenheidnr
	,[Sleutel cluster] = cluster.lt_id
	,Thuisteam = kcm.divisie
	,[Score] = kcm.[Welk rapportcijfer geeft u Staedion voor de behandeling van uw k]
	,Klachtnummer = KCM.klachtnummer
-- select * 
FROM empire_staedion_data.kcm.[STN417_Ingevulde_gegevens_2019] AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON oge.mg_bedrijf = 'Staedion'
	AND oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON oge.mg_bedrijf = 'Staedion'
	AND cluster.Nr_ = kcm.clusternr


GO
