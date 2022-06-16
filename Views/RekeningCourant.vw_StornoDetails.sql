SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [RekeningCourant].[vw_StornoDetails]
AS
SELECT DET.[Klantnr]
	, DET.[Bedrijf]
	, DET.[Volgnummer]
	, DET.[Boekdatum]
	, DET.[Broncode]
	, DET.[Bedrag]
	, DET.[Omschrijving]
	, DET.[Document]
	, DET.[Eenheid]
	, DET.[Document Type]
	, DET.[Vervaldatum]
	, DET.[Boekingssoort]
	, DET.[Soort storno code]
	, DET.[Storno code]
	, SC.[Stornocode en omschrijving]
	, SC.[Storno omschrijving]
	, SC.[Telt mee als storno] 
	-- select SC.[Stornocode en omschrijving], count(*)
FROM [RekeningCourant].[KlantpostenDetails] AS DET
LEFT OUTER JOIN [RekeningCourant].[StornoCode] AS SC
ON DET.[Storno code] = SC.[Storno code]
WHERE  DET.[Storno code] IS NOT null
GO
