SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Prolongatie].[Posten] as
/* #########################################################################################
JvdW tbv PBI Service-abonnementen

######################################################################################### */    
SELECT Boekingsdatum = PP.Boekingsdatum
       ,Bedrag = PP.Bedrag
       ,Elementnr = PP.Elementnr_
			 ,Eenheidnr = PP.Eenheidnr_
			 ,Huurdernr = PP.[Customer No_]
-- select top 10 * 
--FROM empire_Data.dbo.[Staedion$Prolongatiepost]
FROM empire_Data.dbo.[Staedion$Prolongatiepost] AS PP
where year(PP.Boekingsdatum) >= 2018




GO
