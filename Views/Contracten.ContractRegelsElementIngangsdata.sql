SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Contracten].[ContractRegelsElementIngangsdata] as
/* #########################################################################################
JvdW tbv PBI Service-abonnementen

select * from [Contracten].[ActueleContractRegels] where [Afwijking standaardprijs] is not null
;
-- 20201214 CTE_Peildatum weggehaald omwille van performance
######################################################################################### */    
--WITH CTE_Peildatum
--AS (
--       SELECT datum
--       FROM empire_dwh.dbo.tijd
--       WHERE last_loading_day = 1
--       )
SELECT Eenheidnr = C.[Eenheidnr_]
       ,Huurdernr = C.[Customer No_]
			 ,Huurdernaam = C.Naam
       ,Volgnummer = C.Volgnr_
       ,Elementnr = E.[Nr_]
       ,Bedrag = E.[Bedrag (LV)]
       ,Eenmalig = E.Eenmalig
       ,[Ingangsdatum element] = (select min(C2.Ingangsdatum) from empire_data.dbo.[Staedion$Contract] AS C2
																			INNER JOIN empire_data.dbo.[Staedion$Element] AS E2
																				ON C2.[Eenheidnr_] = E2.[Eenheidnr_]
																				 AND C2.[Volgnr_] = E2.[Volgnummer]
																				 AND C2.[Eenheidnr_] = C.[Eenheidnr_]
																				 and C2.[Customer No_] = C.[Customer No_]
																				 and E2.[Nr_] = E.[Nr_])

FROM empire_data.dbo.[Staedion$Contract] AS C
INNER JOIN empire_data.dbo.[Staedion$Element] AS E
       ON C.[Eenheidnr_] = E.[Eenheidnr_]
              AND C.[Volgnr_] = E.[Volgnummer]
INNER JOIN empire_data.dbo.[Staedion$Oge] AS O
       ON C.Eenheidnr_ = O.[Nr_]
WHERE C.[Ingangsdatum] <= getdate()
--(SELECT datum FROM CTE_Peildatum )
       AND (
              C.[Einddatum] = '1753-01-01'
              OR C.[Einddatum] >= getdate()
-- (SELECT datum FROM CTE_Peildatum )
              )
       AND C.[Dummy Contract] = 0 -- JvdW 20200526 toegevoegd
--			 and E.Nr_ in ('263','253','264','254')




GO
