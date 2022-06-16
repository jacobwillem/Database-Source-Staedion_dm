SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Contracten].[vw_NieuwsteContractRegels] as
/* #########################################################################################
JvdW tbv PBI Service-abonnementen

select * from [Contracten].[ActueleContractRegels] where [Afwijking standaardprijs] is not null
;
select * from [Contracten].[NieuwsteContractRegels] where Elementnr = '404' and Bedrag = 0
;
######################################################################################### */    
WITH cte_staedion_brede_elementen
     AS (SELECT Element = '404', 
                Was = 6.40, 
                Wordt = 6.40 -- Servicecontract

         UNION
         SELECT Element = '413', 
                Was = -0.97, 
                Wordt = -0.97 -- Woonduurkorting 10 jaar

         UNION
         SELECT Element = '415', 
                Was = -1.95, 
                Wordt = -1.95 -- woonduurkorting 20 jaar 
     ),
     CTE_Peildatum
     AS (SELECT datum
         FROM empire_dwh.dbo.tijd
         WHERE last_loading_day = 1),
     cte_laatste_regels
     AS (SELECT Eenheidnr = C.[Eenheidnr_], 
                Volgnummer = C.Volgnr_, 
                Sorteersleutel = ROW_NUMBER() OVER(PARTITION BY C.[Eenheidnr_]
                ORDER BY C.Volgnr_ ASC)
         FROM empire_data.dbo.[Staedion$Contract] AS C
         WHERE [Dummy Contract] = 0)
     SELECT Eenheidnr = C.[Eenheidnr_], 
            Huurdernr = C.[Customer No_], 
            Huurdernaam = C.Naam, 
            Volgnummer = C.Volgnr_, 
            Elementnr = E.[Nr_], 
            Bedrag = E.[Bedrag (LV)], 
            Eenmalig = E.Eenmalig, 
            [Afwijking standaardprijs] = IIF(CTE_ST.Wordt <> E.[Bedrag (LV)], 'Afwijking', NULL), 
            [Status contractregel] = CASE
                                         WHEN C.[Status] = 0
                                         THEN 'Nieuw'
                                         ELSE CASE
                                                  WHEN C.[Status] = 1
                                                  THEN 'Huidig'
                                                  ELSE 'Oud'
                                              END
                                     END,
			Ingangsdatum = C.Ingangsdatum
     FROM empire_data.dbo.[Staedion$Contract] AS C
          INNER JOIN cte_laatste_regels AS BRON ON BRON.Eenheidnr = C.Eenheidnr_
                                                   AND BRON.Volgnummer = C.Volgnr_
												   AND BRON.Sorteersleutel = 1
          INNER JOIN empire_data.dbo.[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
                                                                AND C.[Volgnr_] = E.[Volgnummer]
          INNER JOIN empire_data.dbo.[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
          LEFT OUTER JOIN cte_staedion_brede_elementen AS CTE_ST ON CTE_ST.Element = E.Nr_;
GO
