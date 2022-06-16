SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Dashboard].[vw_WeergaveJaar]
AS

SELECT [Weergave opties] = 'Vorig jaar' UNION
SELECT [Weergave opties] = 'Huidig jaar' 

GO
