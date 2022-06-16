SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE  VIEW		[Onderhoudscontracten].[vw_ContactenInclLog]
AS 
/* ###################################################################################################

-----------------------------------------------------------------------------------
WIJZIGINGEN
-----------------------------------------------------------------------------------
20220222 JvdW 
-----------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] empire_staedion_data, 'empire', 'vwICLMcontractenLog'

-- extended property toevoegen op object-niveau
USE empire_staedion_data;  
GO  
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'View op de module Onderhoudscontracten Empire (beginnend met COOH-2), aangevuld met de gebruikerscode van degenene die volgens het wijzigingslogboek het contract heeft aangemaakt',   
@level0type = N'SCHEMA', @level0name = 'empire',  
@level1type = N'VIEW',  @level1name = 'vwICLMcontracten'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'Said Boulaayoun',   
@level0type = N'SCHEMA', @level0name = 'empire',  
@level1type = N'VIEW',  @level1name = 'vwICLMcontracten'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from empire_staedion_data.empire.vwICLMcontracten',   
@level0type = N'SCHEMA', @level0name = 'empire',  
@level1type = N'VIEW',  @level1name = 'vwICLMcontracten'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'empire',  
@level1type = N'VIEW',  @level1name = 'vwICLMcontracten'
;  

################################################################################################### */	


WITH cte_opmerkingen (No_, [Opmerkingen Empire] ) AS 
(SELECT No_, [Opmerkingen Empire] = STRING_AGG(Comment, ' ') 
			 WITHIN GROUP (ORDER BY [Line No_])
FROM empire_Data.dbo.[Staedion$Empire_Project_Comment_Line]
GROUP BY No_
)



SELECT CON.[No_] AS Onderhoudscontractnr
       ,CON.[Description] AS Omschrijving
       ,CON.[Type] AS Soort
       ,[Status] = CASE CON.[Status]
              WHEN 0
                     THEN 'Geen'
              WHEN 1
                     THEN 'Initiatie'
              WHEN 2
                     THEN 'Lopend'
              WHEN 3
                     THEN 'Vervallen'
              WHEN 4
                     THEN 'Afgehandeld'
              ELSE CONVERT(NVARCHAR(20), CON.[Status])
              END
       ,CON.[Blocked] AS Geblokkeerd
       ,CON.[Start Date] AS Startdatum
       ,CON.[Period] AS Looptijd
       ,CON.[End Date] AS Einddatum
       ,CON.[Total Budget] AS [Totaal budget]
       ,CON.[Approval Status] AS Fiatteringsstatus 
       ,CON.[Prolong Until] AS [Geprolongeerd t/m]
       ,CON.[Term of Notice] AS [Opzegtermijn]
       ,CON.[Reason Ending] AS [Reden beëindiging]
       ,CON.[No_ Series] AS [Nr.-reeks]
       ,CON.[Order Status ready] AS [Gereedmelden orders]
       ,CON.[Vendor No_] AS Leveranciersnr
	   ,VEN.[Name] AS [Leveranciersnaam]
       ,CON.[Continue] AS [Stilzwijgende verlenging]
	   ,CTE.[Opmerkingen Empire]
       ,[Aangemaakt door] = ''
       ,AangemaaktDoor = (
              SELECT TOP (1) [User ID]
              FROM empire_staedion_data.empire.vwICLMcontractenLog
              WHERE [type actie] = 'Aangemaakt'
                     AND [Nieuwe waarde] <> ''
                     AND [Oude waarde] = ''
                     AND [contractnr] = CON.[No_]
              )
FROM empire_data.[dbo].[Staedion$Maintenance_Contract] AS CON
LEFT JOIN  empire_Data.[dbo].[Vendor] AS VEN ON CON.[Vendor No_] = VEN.[No_]
LEFT OUTER JOIN cte_opmerkingen AS CTE ON CTE.[No_] = CON.[No_]
WHERE CON.[No_] LIKE 'COOH-2_____'
--OR  CON.[No_] LIKE 'COOH-20____'




GO
