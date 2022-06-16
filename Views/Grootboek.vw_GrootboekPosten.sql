SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Grootboek].[vw_GrootboekPosten]
AS 
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'View grootboekposten op basis van onderliggende datamart. 
Zodoende is naast de (incrementeel geladen grootboektabel) ook als kolom bescikbaar: 
- eenheidnr + adres 
- omschrijving collectief object
- aparte kolom voor leverancier, voor klant
- omschrijving productboekingsgroep
Eventueel ook toe te voegen: link naar xtendis voor INKF
Zie datamart staedion_dm.grootboek'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Grootboek'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_GrootboekPosten';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220513 JvdW metadata toegevoegd + sinds deze datum ook join naar collectieve objecten voor benaming - wellicht werkt dit vertragend door extra join ?
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
-- door joins mogen er natuurlijk geen regels bij komen
select count(*) from [Grootboek].[vw_GrootboekPosten] where year(Boekdatum)>= 2019
select count(*) from [Grootboek].[GrootboekPosten] where year(Boekdatum)>= 2019

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */


SELECT	BEDR.Bedrijf,
		--'Maand ' + format(Boekdatum, 'MM', 'nl-NL') + format(Boekdatum, ' MMM', 'nl-NL') AS Maand,
		GP.[Boekdatum],
		R.rekeningnr AS Rekeningnr,
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
		coalesce(EIG.[Eenheid + adres],COLL.[Collectief object] + ' '+ COLL.Omschrijving) as [Eenheid + adres],  -- naam niet aangepast ivm comptabiliteit
		PG.Code AS Broncode,
		PG.Productboekingsgroep,
		GP.Cluster,
		GP.[Empire werksoort],
		GP.[Empire projectnr],
		GP.[Empire Projecttype],
		GP.[Datum aanmaak],
		[Soort-boekingen] = CASE BR.Code
                               WHEN 'DAEBRC' THEN
                                   'Overig'
                               WHEN 'AFSLWVREK' THEN
                                   'Overig'
							   WHEN 'DAEBVERD' THEN 
									'Overig'
                               WHEN 'EXTBEHEER' THEN
                                   'Overig'
                               ELSE
                                   'Saldo grootboek'
                           END,
		GP.[Referentie onderhoud]
-- select top 5 Cluster 
FROM	[Grootboek].[Rekening] AS R 
LEFT OUTER JOIN [Grootboek].[Grootboekposten] AS GP
ON		R.rekening_id = GP.Rekening_id
LEFT OUTER JOIN [Grootboek].[Bronnen] AS BR
ON		BR.Bron_id = GP.Bron_id
LEFT OUTER JOIN [Grootboek].[Productboekingsgroep] AS PG
ON		PG.Productboekingsgroep_id = GP.Productboekingsgroep_id
LEFT OUTER JOIN [Algemeen].[Bedrijven] AS BEDR
ON		BEDR.bedrijf_id = GP.Bedrijf_id
LEFT OUTER JOIN [Eenheden].[Eigenschappen] AS EIG
ON		EIG.Eenheidnr = GP.Eenheidnr
AND		EIG.Einddatum IS NULL
LEFT OUTER JOIN [Eenheden].[Collectieve objecten] AS COLL
ON		COLL.[Collectief object] = GP.Eenheidnr
AND		COLL.Einddatum IS NULL
WHERE	YEAR(GP.[Boekdatum]) >=2019
;
GO
