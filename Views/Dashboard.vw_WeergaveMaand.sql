SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Dashboard].[vw_WeergaveMaand]
AS

SELECT [Weergave opties] = 'in maand' UNION
SELECT [Weergave opties] = 't/m maand' 

GO
