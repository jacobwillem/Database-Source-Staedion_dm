SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Magazijn].[ArtikelenInclBarcode]
as 
WITH cte_laaddatum ([Laaddatum])
AS (
	SELECT laaddatum
	FROM [staedion_dm].[Algemeen].[Laaddatum]
	)
	,cte_barcode
AS (
	SELECT [Item No_]
		,Kruisverwijzingsnr = convert(NVARCHAR(20), [Cross-Reference No_] + ' ')
		,Kruisverwijzingssoort = CASE [Cross-Reference Type]
			WHEN 0
				THEN ''
			WHEN 1
				THEN 'Klant'
			WHEN 2
				THEN 'Leverancier'
			WHEN 3
				THEN 'Barcode'
			END
		,volgnr = row_number() OVER (
			PARTITION BY [Item No_] ORDER BY [Cross-Reference No_]
			)
	FROM empire_data.dbo.[Staedion$Item_Cross_Reference]
	WHERE [Cross-Reference Type] = 3 -- barcode 
	)
SELECT Leveranciersnr = ART.[Vendor No_]
	,Leveranciersnaam = coalesce((
			SELECT [name]
			FROM empire_Data.dbo.vendor
			WHERE no_ = ART.[Vendor No_]
			), '')
	,Artikelnr = ART.No_
	,Artikelomschrijving = ART.[Description]
	,Kruisverwijzingsnr = coalesce(BAR.Kruisverwijzingsnr, 'Geen kruisverwijzingsnr')
	,Kruisverwijzingssoort = coalesce(BAR.Kruisverwijzingssoort, 'Geen barcode')
	,Voorraad = (
		SELECT convert(FLOAT, sum([Quantity]))
		FROM empire_Data.dbo.Staedion$Item_Ledger_Entry AS ILE
		WHERE ILE.[Item No_] = ART.No_
		)
	,[Basiseenheid] = ART.[Base Unit of Measure]
	,Kostprijs = convert(FLOAT, ART.[Unit Cost])
	,Eenheidsprijs = convert(FLOAT, ART.[Unit Price])
	,[Artikelnr. leverancier] = ART.[Vendor Item No_]
	,Geblokkeerd = iif(ART.Blocked = 1, 'Geblokkeerd', '')
	,DATUM.Laaddatum
-- select count(*)
FROM empire_data.dbo.staedion$item AS ART
LEFT OUTER JOIN cte_laaddatum AS DATUM ON 1 = 1
LEFT OUTER JOIN cte_barcode AS BAR ON BAR.[Item No_] = ART.No_
WHERE BAR.volgnr IS NULL
	OR BAR.volgnr = 1;

GO
