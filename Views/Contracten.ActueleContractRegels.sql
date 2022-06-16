SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   view [Contracten].[ActueleContractRegels]  as
/* #########################################################################################
JvdW tbv PBI Service-abonnementen

select * from [Contracten].[ActueleContractRegels] where [Afwijking standaardprijs] is not null
;
######################################################################################### */    
WITH cte_staedion_brede_elementen
AS (
       SELECT Element = '404'
              ,Was = 6.40
              ,Wordt = 6.40 -- Servicecontract
       
       UNION
       
       SELECT Element = '413'
              ,Was = - 0.97
              ,Wordt = - 0.97 -- Woonduurkorting 10 jaar
       
       UNION
       
       SELECT Element = '415'
              ,Was = - 1.95
              ,Wordt = - 1.95 -- woonduurkorting 20 jaar 
       )
SELECT Eenheidnr = C.[Eenheidnr_]
       ,Huurdernr = C.[Customer No_]
	     ,Huurdernaam = C.Naam
       ,Volgnummer = C.Volgnr_
       ,Elementnr = E.[Nr_]
       ,Bedrag = E.[Bedrag (LV)]
       ,Eenmalig = E.Eenmalig
       ,[Afwijking standaardprijs] = iif(CTE_ST.Wordt <> E.[Bedrag (LV)],'Afwijking',null )
	     ,[status contractregel] = case when (c.[einddatum] = '1753-01-01' or c.[einddatum] >= getdate()) then 'Huidig' else 'Oud' end
FROM empire_data.dbo.[Staedion$Contract] AS C
INNER JOIN empire_data.dbo.[Staedion$Element] AS E
       ON C.[Eenheidnr_] = E.[Eenheidnr_]
              AND C.[Volgnr_] = E.[Volgnummer]
INNER JOIN empire_data.dbo.[Staedion$Oge] AS O
       ON C.Eenheidnr_ = O.[Nr_]
LEFT OUTER JOIN cte_staedion_brede_elementen AS CTE_ST
       ON CTE_ST.Element = E.Nr_
WHERE C.[Ingangsdatum] <= getdate()
       AND (C.[Einddatum] = '1753-01-01'
              OR C.[Einddatum] >=  getdate()
              )
       AND C.[Dummy Contract] = 0 -- JvdW 20200526 toegevoegd

GO
