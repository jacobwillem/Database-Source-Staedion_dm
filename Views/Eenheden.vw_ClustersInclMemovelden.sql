SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Eenheden].[vw_ClustersInclMemovelden] 
AS 
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Overzicht van FT-clusters en eventuele gevulde notitievelden. Deze velden zijn alleen leesbaar (blob-velden) mbv speciale functie
STATUS: test
ZIE: 22 01 891 Nieuwe lijst met opmerkingen per cluster (notitieveld Empire)'   
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Eenheden'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_ClustersInclMemovelden';
GO
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
JvdW 20220318 Aangemaakt nav verzoek Edith - 22 01 891 FW: Nieuwe lijst met opmerkingen per cluster (notitieveld Empire)

################################################################################################################################## */   

WITH cte_ftcluster_verhuurteam_alles AS 
(SELECT CO.Clusternr_ AS Clusternr,
       C.[Name] AS Verhuurteam,
       COUNT(*) AS Aantal
FROM empire_data.dbo.Staedion$Cluster_OGE AS CO
    LEFT OUTER JOIN empire_data.dbo.[staedion$Eenheid_Contactpersoon] AS CP
        ON CP.eenheidnr_ = CO.Eenheidnr_
           AND CP.functie = 'CB-VHTEAM'
    LEFT OUTER JOIN empire_data.dbo.[Contact] AS C
        ON C.No_ = CP.Contactnr_
WHERE CO.Clusternr_ LIKE 'FT%'
GROUP BY CO.Clusternr_,
         C.[Name]
		 ), cte_ftecluster_verhuurteam_pivoted AS 
(SELECT Clusternr, STRING_AGG(Verhuurteam + ' ('+FORMAT(Aantal, 'N0')+ 'x)', ' | ') WITHIN GROUP (ORDER BY Aantal DESC) AS [Verhuurteam(s)]
from cte_ftcluster_verhuurteam_alles
GROUP BY Clusternr)
, cte_ftcluster_notities AS (
SELECT Aanmaakdatum = RL.[Created]
      ,Medewerker = RL.[User ID]
      ,Notitie = convert(NVARCHAR(2000), empire_staedion_logic.[dbo].BlobToNVarChar(RL.[Note]))
      ,[Omschrijving] = RL.[Description]
      ,[Hyperlink] = RL.URL1
	  ,UPPER(SUBSTRING(RL.[Description],PATINDEX('%FT-%',RL.[Description]),7)) AS hulpClusternr
	  ,RL.[Link ID]
	  ,RL.[To User ID]
	  ,VolgnrNotitie = ROW_NUMBER() OVER (PARTITION BY UPPER(SUBSTRING(RL.[Description],PATINDEX('%FT-%',RL.[Description]),7)) ORDER BY RL.[Created] DESC)
FROM	empire.empire.dbo.[Record Link] AS RL
WHERE	[Description ] LIKE '%FT-[19]%'
AND CONVERT(NVARCHAR(2000), empire_staedion_logic.[dbo].BlobToNVarChar(RL.[Note])) IS NOT null
) 
SELECT	CLUST.Nr_ AS Clusternr
		,CLUST.[Naam] AS Clusternaam
		,VHT.[Verhuurteam(s)] 
		,CTE_1.Aanmaakdatum AS [Aanmaakdatum 1ste notitie]
		,CTE_1.Medewerker AS [Medewerker 1ste notitie]
		,CTE_1.Notitie AS [Notitie 1ste notitie]
		,CTE_2.Aanmaakdatum AS [Aanmaakdatum 2de notitie]
		,CTE_2.Medewerker AS [Medewerker 2de notitie]
		,CTE_2.Notitie AS [Notitie 2de notitie]
		,CTE_3.Aanmaakdatum AS [Aanmaakdatum 3de notitie]
		,CTE_3.Medewerker AS [Medewerker 3de notitie]
		,CTE_3.Notitie AS [Notitie 3de notitie]
		,CTE_4.Aanmaakdatum AS [Aanmaakdatum 4de notitie]
		,CTE_4.Medewerker AS [Medewerker 4de notitie]
		,CTE_4.Notitie AS [Notitie 4de notitie]
		,CTE_5.Aanmaakdatum AS [Aanmaakdatum 5de notitie]
		,CTE_5.Medewerker AS [Medewerker 5de notitie]
		,CTE_5.Notitie AS [Notitie 5de notitie]
		,Opmerking = IIF(CTE_6.Aanmaakdatum IS NOT NULL, 'Er zijn nog meer notitievelden maar die worden hier niet weergegeven', '')
		,CAST(GETDATE() AS DATE) AS Gegenereerd
		-- select * from empire_Data.dbo.[Staedion$Cluster_contactpersoon]
FROM		empire_data.dbo.staedion$Cluster AS CLUST 
LEFT OUTER JOIN cte_ftecluster_verhuurteam_pivoted AS VHT
ON  VHT.Clusternr = CLUST.Nr_
LEFT OUTER JOIN cte_ftcluster_notities AS CTE_1 ON CTE_1.hulpClusternr = CLUST.Nr_ AND CTE_1.hulpClusternr IS NOT NULL AND CTE_1.VolgnrNotitie = 1
LEFT OUTER JOIN cte_ftcluster_notities AS CTE_2 ON CTE_2.hulpClusternr = CLUST.Nr_ AND CTE_2.hulpClusternr IS NOT NULL AND CTE_2.VolgnrNotitie = 2
LEFT OUTER JOIN cte_ftcluster_notities AS CTE_3 ON CTE_3.hulpClusternr = CLUST.Nr_ AND CTE_3.hulpClusternr IS NOT NULL AND CTE_3.VolgnrNotitie = 3
LEFT OUTER JOIN cte_ftcluster_notities AS CTE_4 ON CTE_4.hulpClusternr = CLUST.Nr_ AND CTE_4.hulpClusternr IS NOT NULL AND CTE_4.VolgnrNotitie = 4
LEFT OUTER JOIN cte_ftcluster_notities AS CTE_5 ON CTE_5.hulpClusternr = CLUST.Nr_ AND CTE_5.hulpClusternr IS NOT NULL AND CTE_5.VolgnrNotitie = 5
LEFT OUTER JOIN cte_ftcluster_notities AS CTE_6 ON CTE_6.hulpClusternr = CLUST.Nr_ AND CTE_6.hulpClusternr IS NOT NULL AND CTE_6.VolgnrNotitie = 6
WHERE CLUST.Clustersoort = 'FTCLUSTER'
--where CLUST.Nr_ = 'FT-1541'
--ORDER BY 2 desc
;

GO
