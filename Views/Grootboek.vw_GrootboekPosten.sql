SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Grootboek].[vw_GrootboekPosten]
AS 
SELECT	BEDR.Bedrijf,
		--'Maand ' + format(Boekdatum, 'MM', 'nl-NL') + format(Boekdatum, ' MMM', 'nl-NL') AS Maand,
		GP.[Boekdatum],
		R.rekeningnr as Rekeningnr,
		R.Grootboekrekening, 
		R.rekeningnr + ' ' + R.Grootboekrekening AS Rekening,
		GP.Volgnummer,
		GP.[Document nr],
		GP.[Omschrijving],
		GP.[Tegenrekening Leverancier],
		GP.[Bedrag incl. verplichting],
		GP.[Gebruiker],
		GP.[Bron Klant],
		BR.[Code],
		GP.Eenheidnr,
		EIG.[Eenheid + adres],
		PG.Code AS Broncode,
		PG.Productboekingsgroep,
		[Soort-boekingen] = case BR.Code
                               when 'DAEBRC' then
                                   'Overig'
                               when 'AFSLWVREK' then
                                   'Overig'
                               when 'EXTBEHEER' then
                                   'Overig'
                               else
                                   'Saldo grootboek'
                           end
FROM	[Grootboek].[Grootboekposten] AS GP
JOIN	[Grootboek].[Rekening] AS R 
ON		R.rekening_id = GP.Rekening_id
LEFT OUTER JOIN [Grootboek].[Bronnen] AS BR
ON		BR.Bron_id = GP.Bron_id
LEFT OUTER JOIN [Grootboek].[Productboekingsgroep] AS PG
ON		PG.Productboekingsgroep_id = GP.Productboekingsgroep_id
LEFT OUTER JOIN [Algemeen].[Bedrijven] AS BEDR
ON		BEDR.bedrijf_id = GP.Bedrijf_id
LEFT OUTER JOIN [Eenheden].[Eigenschappen] AS EIG
ON		EIG.Eenheidnr = GP.Eenheidnr
AND		EIG.Einddatum IS null
WHERE	YEAR(GP.[Boekdatum]) >=2019
;
GO
