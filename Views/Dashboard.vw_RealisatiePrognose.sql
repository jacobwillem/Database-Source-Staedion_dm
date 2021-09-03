SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [Dashboard].[vw_RealisatiePrognose]
AS
SELECT
	 R.[id]
	,R.[Datum]
	,R.[Waarde]
	,R.[Laaddatum]
	,R.[Omschrijving]
	,R.[fk_indicator_id]
	,R.[fk_eenheid_id]
	,R.[fk_contract_id]
	,R.[fk_klant_id]
	,R.[Teller]
	,R.[Noemer]
	,R.[Clusternummer]
	,[Prognose] = 0
	,[Detail.01] = null
	,[Detail.02] = null
	,[Detail.03] = null
	,[Detail.04] = null
	,[Detail.05] = null
	,[Detail.06] = null
	,[Detail.07] = null
	,[Detail.08] = null
	,[Detail.09] = null
	,[Detail.10] = null
	,[Detail.11] = null
	,[Detail.12] = null
FROM [Dashboard].[RealisatieDetails] AS R
--WHERE R.[fk_indicator_id] = 110
--JOIN [Dashboard].[vw_Indicator] AS I
--	ON I.[id] = R.[fk_indicator_id]
--	AND I.[Jaargang] = year(R.[Datum])
	--AND I.[Zichtbaar] = 1 /* UITGESCHAKELD ZODAT INDICATOR IN RAPPORT IN AANBOUW ZICHTBAAR WORDT. */
UNION
SELECT
	 [id] = (P.[id] + 1000000000000)
	,[Datum] = P.[Datum]
	,[Waarde] = P.[Waarde]
	,[Laaddatum] = getdate()
	,[Omschrijving] = P.[Omschrijving]
	,[fk_indicator_id] = P.[fk_indicator_id]
	,[fk_eenheid_id] = null
	,[fk_contract_id] = null
	,[fk_klant_id] = null
	,[Teller] = null
	,[Noemer] = null
	,[Clusternummer] = null
	,[Prognose] = 1
	,[Detail.01] = null
	,[Detail.02] = null
	,[Detail.03] = null
	,[Detail.04] = null
	,[Detail.05] = null
	,[Detail.06] = null
	,[Detail.07] = null
	,[Detail.08] = null
	,[Detail.09] = null
	,[Detail.10] = null
	,[Detail.11] = null
	,[Detail.12] = null
FROM [Dashboard].[PrognoseDetails] AS P
--JOIN [Dashboard].[vw_Indicator] AS I
--	ON I.[id] = P.[fk_indicator_id]
--	AND I.[Jaargang] = year(P.[Datum])
	--AND I.[Zichtbaar] = 1 /* UITGESCHAKELD ZODAT INDICATOR IN RAPPORT IN AANBOUW ZICHTBAAR WORDT. */
WHERE NOT EXISTS (
  SELECT 1
  FROM Dashboard.RealisatieDetails AS RD
  WHERE RD.[fk_indicator_id] = P.[fk_indicator_id]
  AND year(RD.[Datum]) = year(P.[Datum])
  AND month(RD.[Datum]) = month(P.[Datum])
)
GO
