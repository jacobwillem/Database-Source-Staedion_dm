SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Klanttevredenheid].[Planmatig_Handmatig] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Planmatig_Handmatig'


######################################################################################### */    

SELECT [Datum] = convert(DATE, kcm.[INGEVULDE GEGEVENS])
       ,[Tijdstip] = convert(TIME, kcm.[INGEVULDE GEGEVENS])
       ,[Sleutel eenheid] = oge.lt_id
       ,[Eenheidnr] = kcm.eenheid
       ,[Sleutel cluster] = cluster.lt_id
       ,[Score] = kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion ]
       ,[Suggesties 1] = convert(NVARCHAR(1024), kcm.[Uw tip(s):])
       ,[Suggesties 2] = convert(NVARCHAR(1024), kcm.[Welke van deze onderdelen moeten wij volgens u als eerste verbet])
       ,[Suggesties 3] = convert(NVARCHAR(1024), kcm.[Heeft u nog tips over hoe we onze dienstverlening bij het uitvoe])
       ,[PLO nummer project]
       ,[Projectnaam]
       ,[Projectleider]
       ,[Projectopzichter]
       ,[Leverancier]
       ,[Clusternr]
       ,[Datum gereed]
       ,[Startdatum]
       ,[Omschrijving Werkzaamheden]
       ,[Bouwbloknr]
       ,[Bouwbloknaam]
       ,[CBSbuurtcode]
-- select * 
FROM [empire_staedion_data].[kcm].[STN418_Ingevulde_gegevens] AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge
       ON oge.mg_bedrijf = 'Staedion'
              AND oge.Nr_ = kcm.eenheid
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster
       ON oge.mg_bedrijf = 'Staedion'
              AND cluster.Nr_ = kcm.clusternr
WHERE year(kcm.[INGEVULDE GEGEVENS]) > 2019

UNION

SELECT [Datum] = convert(DATE, kcm.[INGEVULDE GEGEVENS])
       ,[Tijdstip] = convert(TIME, kcm.[INGEVULDE GEGEVENS])
       ,[Sleutel eenheid] = oge.lt_id
       ,[Eenheidnr] = kcm.eenheid
       ,[Sleutel cluster] = cluster.lt_id
       ,[Score] = kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion ]
       ,[Suggesties 1] = convert(NVARCHAR(1024), kcm.[Uw tip(s):])
       ,[Suggesties 2] = convert(NVARCHAR(1024), kcm.[Welke van deze onderdelen moeten wij volgens u als eerste verbet])
       ,[Suggesties 3] = convert(NVARCHAR(1024), kcm.[Heeft u nog tips over hoe we onze dienstverlening bij het uitvoe])
       ,[PLO nummer project]
       ,[Projectnaam]
       ,[Projectleider]
       ,[Projectopzichter]
       ,[Leverancier]
       ,[Clusternr]
       ,[Datum gereed]
       ,[Startdatum]
       ,[Omschrijving Werkzaamheden]
       ,[Bouwbloknr]
       ,[Bouwbloknaam]
       ,[CBSbuurtcode]
-- select * 
FROM [empire_staedion_data].[kcm].STN418_Ingevulde_gegevens_2019 AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge
       ON oge.mg_bedrijf = 'Staedion'
              AND oge.Nr_ = kcm.eenheid
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster
       ON oge.mg_bedrijf = 'Staedion'
              AND cluster.Nr_ = kcm.clusternr
WHERE year(kcm.[INGEVULDE GEGEVENS]) <= 2019
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Planmatig_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Planmatig_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View die uit handmatig ingelezen dump csv de enqueteresultaten haalt van betreffende enquete (STN418 vanaf 2020)', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Planmatig_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT avg(score*1.00) 
FROM staedion_dm.[Klanttevredenheid].[Planmatig_Handmatig] 
WHERE year(Datum) = 2020', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Planmatig_Handmatig', NULL, NULL
GO
