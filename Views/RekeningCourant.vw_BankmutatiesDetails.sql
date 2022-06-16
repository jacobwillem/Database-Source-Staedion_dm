SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [RekeningCourant].[vw_BankmutatiesDetails]
AS
SELECT DET.[Importnr],
       DET.[Boekdatum],
       DET.[Bedrag],
       DET.[Naam],
       DET.[Volgnr klantposten],
       DET.[Bron],
	   DET.Klantnr
	   -- select top 10 *
FROM [RekeningCourant].[BankmutatiesDetails] AS DET;
GO
