SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Dashboard].[vw_Normen2]
AS
SELECT 
	 N.[id]
	,[fk_indicator_id] = N.[fk_indicator_id]
	,N.[Datum]
	,N.[Waarde]
FROM [Dashboard].[Normen] AS N
WHERE N.[fk_indicator_id] IN (SELECT DISTINCT [fk_indicator_id] FROM [Dashboard].[vw_Indicator2])
GO
