SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [RekeningCourant].[vw_IdealDetails] AS 
SELECT	R.Rekeningnr
		,GB.Boekdatum  
		,GB.Volgnummer  
		,GB.[Document nr]  
		,GB.Omschrijving 
		,GB.[Bron Klant] AS Klantnr
		,Broncode = B.Bron
		,Bedrag = GB.[Bedrag incl. verplichting]
		,[Uniek volgnr ideal per klant] = DENSE_RANK() OVER (
		ORDER BY [Bron Klant]
		) 
		-- select top 10 *
FROM	[Grootboek].Grootboekposten AS GB
JOIN	[Grootboek].Rekening AS R
ON		GB.Rekening_id = R.Rekening_id
LEFT OUTER JOIN	[Grootboek].[Bronnen] AS B
ON		B.Bron_id = GB.Bron_id
WHERE	YEAR(GB.Boekdatum)>= 2015
AND		R.Rekeningnr IN ('A155200')
AND		COALESCE([Bron Klant],'') IS NOT NULL
GO
