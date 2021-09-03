SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Algemeen].[Laaddatum]
as
/* ###################################################################################################
VAN			Jaco van der Wel
BETREFT		View standaard meeladen in PBI om te zien van wanneer de data is
TEST		select * from [backup_empire_dwh].[dbo].[tmv_laaddatum]	
-----------------------------------------------------------------------------------
WIJZIGINGEN		
20210413 Versie 1, afgeleid van empire_Dwh.dbo.tmv_laaddatum
> te vervangen door andere bron later, maar dan kunnen database-objecten in staedion_dm hier alvast naar verwijzen
							
-----------------------------------------------------------------------------------					
			 
################################################################################################### */	
SELECT Laaddatum = T.datum
       ,[Toegerekende posten bijgewerkt tot] = (
              SELECT max([Posting Date])
              FROM empire_data.dbo.[Staedion$Allocated_G_L_Entries]
              )
FROM  empire_dwh.dbo.tijd as T
WHERE T.last_loading_day = 1



GO
