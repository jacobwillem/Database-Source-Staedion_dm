SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Dashboard].[vw_Normen]
AS
SELECT 
	 N.[id]
	,[fk_indicator_id] = N.[fk_indicator_id]
	,N.[Datum]
	,N.[Waarde]
FROM [Dashboard].[Normen] AS N
JOIN [Dashboard].[vw_Indicator] AS I
	ON I.[id] = N.[fk_indicator_id]
	AND I.[Jaargang] = year(N.[Datum]) --AND I.[Zichtbaar] = 1
GO
