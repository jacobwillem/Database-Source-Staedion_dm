SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Dashboard].[sp_update_prognose]
AS
BEGIN
	/*
	BEGIN
		INSERT INTO [Dashboard].[Prognose] (
		 [fk_indicator_id]
		,[Datum]
		,[Waarde]
		,[Laaddatum]
		)
		SELECT [fk_indicator_id] = N.[fk_indicator_id]
			  ,[Datum] = CONVERT(DATETIME, EOMONTH(N.[Datum]), 120)
			  ,[Waarde] = N.[Waarde]
			  ,[Laaddatum] = CONVERT(DATETIME, GETDATE(), 120)
		FROM [Dashboard].[Rapport] AS R 
		INNER JOIN [Dashboard].[RapportDetails] AS D
			ON D.[fk_rapport_id] = R.[id]
		INNER JOIN [Dashboard].[Normen] AS N
			ON N.[fk_indicator_id] = D.[fk_indicator_id]
			AND YEAR(N.[Datum]) = YEAR(GETDATE())
			AND MONTH(N.[Datum]) = 1
		LEFT OUTER JOIN [Dashboard].[Prognose] AS P
			ON P.[fk_indicator_id] = N.[fk_indicator_id]
			AND EOMONTH(P.[Datum]) = EOMONTH(N.[Datum])
		WHERE D.[fk_indicator_id] NOT BETWEEN 1700 AND 1710   -- Prognoses niet aanpassen voor KPI Bedrijfslasten, deze worden apart geladen vanuit de procedure zelf.
		  AND D.[fk_indicator_id] NOT IN (200, 210, 220, 400) -- Prognoses niet aanpassen voor KPI Reno/Nieuwbouwprojecten, deze worden apart geladen vanuit de procedure zelf.
		  AND P.[id] IS NULL
		  AND (YEAR(R.Startdatum) >= YEAR(GETDATE()) OR R.Einddatum IS NULL)
		  AND (YEAR(R.Einddatum) <= YEAR(GETDATE()) OR R.Einddatum IS NULL)
		ORDER BY D.[fk_rapport_id], D.[Volgorde]
	END
	*/

	BEGIN
		INSERT INTO [Dashboard].[Prognose] (
		 [fk_indicator_id]
		,[Datum]
		,[Waarde]
		,[Laaddatum]
		)
		SELECT [fk_indicator_id] = D.[fk_indicator_id]
			  ,[Datum] = CONVERT(DATETIME, EOMONTH(GETDATE()), 120)
			  ,[Waarde] = P1.[Waarde]
			  ,[Laaddatum] = CONVERT(DATETIME, GETDATE(), 120)
		FROM [Dashboard].[Rapport] AS R 
		INNER JOIN [Dashboard].[RapportDetails] AS D
			ON D.[fk_rapport_id] = R.[id]
		LEFT OUTER JOIN [Dashboard].[Prognose] AS P1
			ON P1.[fk_indicator_id] = D.[fk_indicator_id]
			AND EOMONTH(P1.[Datum]) = EOMONTH(DATEADD(MONTH, -1, CONVERT(DATETIME, GETDATE(), 120)))
		LEFT OUTER JOIN [Dashboard].[Prognose] AS P2
			ON P2.[fk_indicator_id] = D.[fk_indicator_id]
			AND EOMONTH(P2.[Datum]) = EOMONTH(CONVERT(DATETIME, GETDATE(), 120))
		WHERE D.[fk_indicator_id] NOT BETWEEN 1700 AND 1710   -- Prognoses niet aanpassen voor KPI Bedrijfslasten, deze worden apart geladen vanuit de procedure zelf.
		  AND D.[fk_indicator_id] NOT IN (200, 210, 220, 400) -- Prognoses niet aanpassen voor KPI Reno/Nieuwbouwprojecten, deze worden apart geladen vanuit de procedure zelf.
		  AND P1.[id] IS NOT NULL
		  AND P2.[id] IS NULL
		  AND (YEAR(R.Startdatum) >= YEAR(GETDATE()) OR R.Einddatum IS NULL)
		  AND (YEAR(R.Einddatum) <= YEAR(GETDATE()) OR R.Einddatum IS NULL)
		GROUP BY D.[fk_indicator_id], P1.[Waarde]
	END
END
GO
