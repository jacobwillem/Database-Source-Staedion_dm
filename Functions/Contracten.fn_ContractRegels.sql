SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   FUNCTION [Contracten].[fn_ContractRegels] (@Eenheidnr NVARCHAR(20), @Elementnr NVARCHAR(1000), @Peildatum date)  
/* #########################################################################################
JvdW tbv PBI Service-abonnementen

select * from [Contracten].[ActueleContractRegels] where [Afwijking standaardprijs] is not null
;
######################################################################################### */   

returns table 
as
/* ###################################################################################################

################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
	SELECT coalesce(@Peildatum, datum) AS Laaddatum
	FROM empire_dwh.dbo.tijd
	WHERE [last_loading_day] = 1
	), cte_elementen AS (SELECT CONVERT(NVARCHAR(3),value) AS Elementnr 
							FROM STRING_SPLIT (@Elementnr, ',')
							)


SELECT Eenheidnr = C.[Eenheidnr_]
       ,Huurdernr = C.[Customer No_]
	   ,Huurdernaam = C.Naam
       ,Volgnummer = C.Volgnr_
       ,Elementnr = E.[Nr_]
       ,Bedrag = E.[Bedrag (LV)]
       ,Eenmalig = E.Eenmalig
	   ,C.Ingangsdatum
	   ,C.Einddatum
	   ,C.[Aangemaakt op]
       --,[Afwijking standaardprijs] = IIF(CTE_ST.Wordt <> E.[Bedrag (LV)],'Afwijking',NULL )
	   ,[Status contractregel] = CASE WHEN C.[Status] = 0 THEN 'Nieuw' ELSE CASE WHEN   C.[Status] = 1 THEN 'Huidig' ELSE 'Oud' END END
-- select top 10 * 
FROM empire_data.dbo.[Staedion$Contract] AS C
INNER JOIN empire_data.dbo.[Staedion$Element] AS E
       ON C.[Eenheidnr_] = E.[Eenheidnr_]
              AND C.[Volgnr_] = E.[Volgnummer]
INNER JOIN empire_data.dbo.[Staedion$Oge] AS O
       ON C.Eenheidnr_ = O.[Nr_]
JOIN CTE_peildata AS P ON 1 = 1
WHERE C.[Ingangsdatum] <= (
		SELECT Laaddatum
		FROM CTE_peildata
		)
       AND (C.[Einddatum] = '1753-01-01'
              OR C.[Einddatum] >= (
			SELECT Laaddatum
			FROM CTE_peildata
			)
              )
       AND C.[Dummy Contract] = 0 -- JvdW 20200526 toegevoegd
	   AND (C.Eenheidnr_ = @Eenheidnr OR @Eenheidnr IS NULL)
	   AND (E.[Nr_] IN  (SELECT Elementnr FROM cte_elementen) OR @Elementnr IS NULL)
GO
