SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Dashboard].[vw_Datum]
AS

SELECT * FROM [Algemeen].[Datum]
WHERE Datum >= '20200101'

GO
