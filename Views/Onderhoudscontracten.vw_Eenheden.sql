SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW		[Onderhoudscontracten].[vw_Eenheden]
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

WITH cte_opmerkingen (No_, [Opmerkingen Empire])
AS (SELECT No_,
           [Opmerkingen Empire] = STRING_AGG(Comment, ' ')WITHIN GROUP(ORDER BY [Line No_])
    FROM empire_data.dbo.[Staedion$Empire_Project_Comment_Line]
    GROUP BY No_)
SELECT CON.[No_] AS Onderhoudscontractnr,
       CON.[Description] AS Omschrijving,
       CON.[Type] AS Soort,
       [Status] = CASE CON.[Status]
                      WHEN 0 THEN
                          'Geen'
                      WHEN 1 THEN
                          'Initiatie'
                      WHEN 2 THEN
                          'Lopend'
                      WHEN 3 THEN
                          'Vervallen'
                      WHEN 4 THEN
                          'Afgehandeld'
                      ELSE
                          CONVERT(NVARCHAR(20), CON.[Status])
                  END,
       CON.[Blocked] AS Geblokkeerd,
       CON.[Start Date] AS Startdatum,
       CON.[Period] AS Looptijd,
       CON.[End Date] AS Einddatum,
       CON.[Total Budget] AS [Totaal budget],
       CON.[Approval Status] AS Fiatteringsstatus,
       CON.[Prolong Until] AS [Geprolongeerd t/m],
       CON.[Term of Notice] AS [Opzegtermijn],
       CON.[Reason Ending] AS [Reden beëindiging],
       CON.[No_ Series] AS [Nr.-reeks],
       CON.[Order Status ready] AS [Gereedmelden orders],
       CON.[Vendor No_] AS Leveranciersnr,
       VEN.[Name] AS [Leveranciersnaam],
       CON.[Continue] AS [Stilzwijgende verlenging],
       CTE.[Opmerkingen Empire],
       [Aangemaakt door] = '',
       AangemaaktDoor =
       (
           SELECT TOP (1)
                  [User ID]
           FROM empire_staedion_data.empire.vwICLMcontractenLog
           WHERE [type actie] = 'Aangemaakt'
                 AND [Nieuwe waarde] <> ''
                 AND [Oude waarde] = ''
                 AND [contractnr] = CON.[No_]
       ),
       MDB.[Cluster No_] AS Clusternr,
       MDB.[Work Type] AS [Werksoort],
       MDB.[Work Type Description] AS [Werksoortomschrijving],
       MDRO.[Realty Object No_] AS Eenheidnr,
       MDRO.[Realty Object Address] AS Eenheidadres,
       MDRO.[Prolong] AS Prolongeren,
       CASE MDRO.[Status]
           WHEN 0 THEN
               'Leegstand'
           WHEN 1 THEN
               'Uit beheer'
           WHEN 2 THEN
               'Renovatie'
           WHEN 3 THEN
               'Verhuurd'
           WHEN 4 THEN
               'Administratief'
           WHEN 5 THEN
               'Verkocht'
           WHEN 6 THEN
               'In ontwikkeling'
           ELSE
               CONCAT(MDRO.[Status], '?')
       END AS [Status eenheid],
       T.[Analysis Group Code] AS [Corpodata type],
	   IIF(OGE.[Common Area]= 1,'Collectief object','Eenheid') AS [Soort eenheid]
FROM empire_data.[dbo].[Staedion$Maintenance_Contract] AS CON
    LEFT JOIN empire_data.[dbo].[Vendor] AS VEN
        ON CON.[Vendor No_] = VEN.[No_]
    LEFT OUTER JOIN cte_opmerkingen AS CTE
        ON CTE.[No_] = CON.[No_]
    LEFT OUTER JOIN empire_data.dbo.staedion$Mutation_Data_Budget AS MDB
        ON MDB.[Maintenance Contract No_] = CON.[No_]
    LEFT OUTER JOIN empire_data.dbo.staedion$Mutation_Data_Realty_Object AS MDRO
        ON MDRO.[Maintenance Contract No_] = CON.[No_]
           AND MDRO.[Entry No_] = MDB.[Entry No_]
           AND MDRO.[MDB Line No_] = MDB.[Line No_]
    LEFT OUTER JOIN empire_data.dbo.staedion$OGE AS OGE
        ON OGE.Nr_ = MDRO.[Realty Object No_]
    LEFT OUTER JOIN empire_data.dbo.staedion$Type AS T
        ON OGE.[Type] = T.[Code]
           AND
           (
               (
                   T.Soort = 2
                   AND OGE.[Common Area] = 1
               )
               OR
               (
                   T.Soort <> 2
                   AND OGE.[Common Area] = 0
               )
           )
WHERE CON.[No_] LIKE 'COOH-2_____'
      AND MDRO.[Prolong] = 1;
--AND CON.No_ = 'COOH-210020'
--OR  CON.[No_] LIKE 'COOH-20____'



GO
