SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [RekeningCourant].[StornoDetails]
AS
SELECT [Klantnr]
	,[Bedrijf]
	,[Volgnummer]
	,[Boekdatum]
	,[Broncode]
	,[Bedrag]
	,[Omschrijving]
	,[Document]
	,[Eenheid]
	,[Document Type]
	,[Vervaldatum]
	,[Boekingssoort]
	,[Soort storno code]
	,[Storno code]
FROM [RekeningCourant].[KlantpostenDetails]
WHERE nullif([Soort storno code], '') IS NOT NULL
	OR nullif([Storno code], '') IS NOT NULL

GO
