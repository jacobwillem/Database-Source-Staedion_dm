SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Dashboard].[vw_Prognose]
AS
SELECT   P.[id]
		,P.[fk_indicator_id]
		,P.[Datum]
		,P.[Waarde]
		,P.[Laaddatum]
		,P.[Omschrijving]
		,P.[Huidig]
		--,I.jaargang
		-- select * 
FROM Dashboard.Prognose AS P
WHERE P.[fk_indicator_id] IN (SELECT DISTINCT [fk_indicator_id] FROM [Dashboard].[vw_Indicator2])

/*
SELECT   P.[id]
		,P.[fk_indicator_id]
		,P.[Datum]
		,P.[Waarde]
		,P.[Laaddatum]
		,P.[Omschrijving]
		,P.[Huidig]
		,I.jaargang
		-- select * 
FROM Dashboard.Prognose AS P
JOIN [Dashboard].[vw_Indicator] AS I
	ON I.[id] = P.[fk_indicator_id]
	AND I.[Jaargang] = YEAR(P.[Datum])
*/
GO
