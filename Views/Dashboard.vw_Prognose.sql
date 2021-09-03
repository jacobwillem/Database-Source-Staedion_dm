SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Dashboard].[vw_Prognose]
AS
SELECT   P.[id]
		,P.[fk_indicator_id]
		,P.[Datum]
		,P.[Waarde]
		,P.[Laaddatum]
		,P.[Omschrijving]
		,P.[Huidig]
FROM Dashboard.Prognose AS P
JOIN [Dashboard].[vw_Indicator] AS I
	ON I.[id] = P.[fk_indicator_id]
	AND I.[Jaargang] = year(P.[Datum])

GO
