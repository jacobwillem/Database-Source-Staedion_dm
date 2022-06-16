SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






create VIEW [Dashboard].[vw_RealisatiePrognose3]
AS
	SELECT
		 R.[id]
		,R.[fk_indicator_id]
		,R.[Datum]
		,R.[Laaddatum]
		,R.[Waarde]
		,R.[Teller]
		,R.[Noemer]
		,R.[Omschrijving]
		,[Prognose] = 0
	FROM [Dashboard].[RealisatieDetails] AS R
  --where fk_indicator_id between 1500 and 1550

	UNION

	SELECT
		 [id] = (P.[id] + 1000000000000)
		,[fk_indicator_id] = P.[fk_indicator_id]
		,[Datum] = P.[Datum]
		,[Laaddatum] = GETDATE()
		,[Waarde] = P.[Waarde]
		,[Teller] = NULL
		,[Noemer] = NULL
		,[Omschrijving] = P.[Omschrijving]
		,[Prognose] = 1
	FROM [Dashboard].[PrognoseDetails] AS P
	WHERE NOT EXISTS (
	  SELECT 1
	  FROM Dashboard.RealisatieDetails AS RD
	  WHERE RD.[fk_indicator_id] = P.[fk_indicator_id]
	  AND YEAR(RD.[Datum]) = YEAR(P.[Datum])
	  AND MONTH(RD.[Datum]) = MONTH(P.[Datum])
	)

GO
