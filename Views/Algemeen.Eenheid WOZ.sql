SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Algemeen].[Eenheid WOZ]
as
/* ###########################################################################################################################
------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Algemeen', 'Eenheid WOZ'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'Haalt de WOZ-waarde op van eenheden met een meest recente WOZ-peildatum als ook van die betreffende eenheid van de peildatum die daarvoor ligt.',   
@level0type = N'SCHEMA', @level0name = 'Algemeen',  
@level1type = N'VIEW',  @level1name = 'Eenheid WOZ'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Algemeen',  
@level1type = N'VIEW',  @level1name = 'Eenheid WOZ'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'-- Afwijking in jaar / peildatum
SELECT Eenheidnummer = DWH.bk_nr_
       ,Adres = replace(DWH.descr, DWH.bk_nr_ + '' '','''')
			 ,Cluster = DWH.da_complex
       ,[Tecchnisch type] = TT.descr
       ,[Corpodata type] = TT.fk_eenheid_type_corpodata_id
			 ,WOZ.[WOZ waarde]
			 ,WOZ.[WOZ-objectnr]
			 ,WOZ.[WOZ-peildatum]
			 ,WOZ.[Jaar vanaf]
			 ,WOZ.[Jaar tot]
			 ,WOZ.[WOZ waarde peildatum ervoor]
			 ,WOZ.[WOZ peildatum ervoor] 
FROM backup_empire_dwh.dbo.eenheid AS DWH
INNER JOIN backup_empire_dwh.dbo.technischtype AS TT
       ON TT.id = DWH.fk_technischtype_id
left outer join staedion_dm.[Algemeen].[Eenheid WOZ] as WOZ
on WOZ.[Sleutel eenheid] = DWH.id
WHERE DWH.da_bedrijf = ''Staedion''
       AND DWH.dt_in_exploitatie <= getdate()
       AND (
              DWH.dt_uit_exploitatie IS NULL
              OR DWH.dt_uit_exploitatie >= getdate()
              )
',   
@level0type = N'SCHEMA', @level0name = 'Algemeen',  
@level1type = N'VIEW',  @level1name = 'Eenheid WOZ'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Algemeen',  
@level1type = N'VIEW',  @level1name = 'Eenheid WOZ'
;  
------------------------------------------------------------------------------------------------------------------------------
CHECKS
------------------------------------------------------------------------------------------------------------------------------

-- Afwijking in jaar / peildatum
SELECT Eenheidnummer = DWH.bk_nr_
       ,Adres = replace(DWH.descr, DWH.bk_nr_ + ' ','')
			 ,Cluster = DWH.da_complex
       ,[Tecchnisch type] = TT.descr
       ,[Corpodata type] = TT.fk_eenheid_type_corpodata_id
			 ,WOZ.[WOZ waarde]
			 ,WOZ.[WOZ-objectnr]
			 ,WOZ.[WOZ-peildatum]
			 ,WOZ.[Jaar vanaf]
			 ,WOZ.[Jaar tot]
			 ,WOZ.[WOZ waarde peildatum ervoor]
			 ,WOZ.[WOZ peildatum ervoor] 
FROM backup_empire_dwh.dbo.eenheid AS DWH
INNER JOIN backup_empire_dwh.dbo.technischtype AS TT
       ON TT.id = DWH.fk_technischtype_id
left outer join staedion_dm.[Algemeen].[Eenheid WOZ] as WOZ
on WOZ.[Sleutel eenheid] = DWH.id
WHERE DWH.da_bedrijf = 'Staedion'
       AND DWH.dt_in_exploitatie <= getdate()
       AND (
              DWH.dt_uit_exploitatie IS NULL
              OR DWH.dt_uit_exploitatie >= getdate()
              )
       AND DWH.bk_nr_ IN (
              'OGEH-0054556'
              ,'OGEH-0054472'
              )

-- Afwijking in jaar / peildatum
SELECT [Eenheidnummer] = WOZ.Eenheidnr_
       ,[WOZ waarde] = WOZ.[WOZ-taxatiewaarde]
       ,[WOZ-objectnr] = WOZ.[WOZ-objectnr_]
       ,[WOZ-peildatum] = WOZ.[WOZ-peildatum]
       ,[Jaar vanaf] = WOZ.[Jaar vanaf]
       ,[Jaar tot] = WOZ.[Jaar tot]
-- select WOZ.*
FROM [empire_data].dbo.[Staedion$WOZgegevens] AS WOZ
where			([WOZ-peildatum] <> '20190101' 
and 			[Jaar vanaf]  = 2020)
or			([WOZ-peildatum] = '20190101' 
and 			[Jaar vanaf]  <> 2020)


########################################################################################################################### */   
WITH CTE_recentste_peildatum
AS (
       SELECT max([WOZ-peildatum]) AS Peildatum
       FROM [empire_data].dbo.[Staedion$WOZgegevens]
       )
       ,CTE_voorgaande_WOZ
AS (
       SELECT Eenheidnr_
              ,[WOZ-taxatiewaarde]
							,[WOZ-peildatum]
              ,Volgorde = row_number() OVER (
                     PARTITION BY Eenheidnr_ ORDER BY [WOZ-peildatum] DESC
                     )
       FROM [empire_data].dbo.[Staedion$WOZgegevens]
       JOIN CTE_recentste_peildatum AS CTE
              ON 1 = 1
       WHERE [WOZ-peildatum] < CTE.Peildatum
       )
SELECT [Sleutel eenheid] = DWH.id
			 ,[Eenheidnummer] = WOZ.Eenheidnr_
       ,[WOZ waarde] = floor(WOZ.[WOZ-taxatiewaarde])
       ,[WOZ-objectnr] = WOZ.[WOZ-objectnr_]
       ,[WOZ-peildatum] = WOZ.[WOZ-peildatum]
       ,[Jaar vanaf] = WOZ.[Jaar vanaf]
       ,[Jaar tot] = WOZ.[Jaar tot]
			 ,[WOZ waarde peildatum ervoor] = floor(WOZ_EERDER.[WOZ-taxatiewaarde])
			 ,[WOZ peildatum ervoor] = WOZ_EERDER.[WOZ-peildatum]
-- select WOZ.*
FROM [empire_data].dbo.[Staedion$WOZgegevens] AS WOZ
LEFT OUTER JOIN empire_dwh.dbo.eenheid AS DWH
       ON DWH.bk_nr_ = WOZ.Eenheidnr_
              AND DWH.da_bedrijf = 'Staedion'
JOIN CTE_recentste_peildatum as CTE on 1=1 
left outer join CTE_voorgaande_WOZ as WOZ_EERDER
on WOZ_EERDER.Eenheidnr_ = WOZ.Eenheidnr_
and WOZ_EERDER.Volgorde =1 
where WOZ.[WOZ-peildatum] = CTE.Peildatum

GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Algemeen', 'VIEW', N'Eenheid WOZ', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Algemeen', 'VIEW', N'Eenheid WOZ', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Haalt de WOZ-waarde op van eenheden met een meest recente WOZ-peildatum als ook van die betreffende eenheid van de peildatum die daarvoor ligt.', 'SCHEMA', N'Algemeen', 'VIEW', N'Eenheid WOZ', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'-- Afwijking in jaar / peildatum
SELECT Eenheidnummer = DWH.bk_nr_
       ,Adres = replace(DWH.descr, DWH.bk_nr_ + '' '','''')
			 ,Cluster = DWH.da_complex
       ,[Tecchnisch type] = TT.descr
       ,[Corpodata type] = TT.fk_eenheid_type_corpodata_id
			 ,WOZ.[WOZ waarde]
			 ,WOZ.[WOZ-objectnr]
			 ,WOZ.[WOZ-peildatum]
			 ,WOZ.[Jaar vanaf]
			 ,WOZ.[Jaar tot]
			 ,WOZ.[WOZ waarde peildatum ervoor]
			 ,WOZ.[WOZ peildatum ervoor] 
FROM backup_empire_dwh.dbo.eenheid AS DWH
INNER JOIN backup_empire_dwh.dbo.technischtype AS TT
       ON TT.id = DWH.fk_technischtype_id
left outer join staedion_dm.[Algemeen].[Eenheid WOZ] as WOZ
on WOZ.[Sleutel eenheid] = DWH.id
WHERE DWH.da_bedrijf = ''Staedion''
       AND DWH.dt_in_exploitatie <= getdate()
       AND (
              DWH.dt_uit_exploitatie IS NULL
              OR DWH.dt_uit_exploitatie >= getdate()
              )
', 'SCHEMA', N'Algemeen', 'VIEW', N'Eenheid WOZ', NULL, NULL
GO
