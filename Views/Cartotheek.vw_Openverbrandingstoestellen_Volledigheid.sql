SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Cartotheek].[vw_Openverbrandingstoestellen_Volledigheid]												-- in PBI opnemen 
AS

WITH cte_OVT AS 
(SELECT CART.[Sleutel], -- In PBI labellen als primary key + In PowerApps meenemen
       CART.[Eenheidnr],
       CART.[Datum],
       CART.[Cartotheek-item],
       CART.[Cartotheek-item-omschrijving],
       CART.[Categorie OVT],
       CART.[aanwezig],
       CART.[rekenregel],
       BEV.Opmerking,  -- In PowerApps opnemen
       BEV.Onderwerp,  -- In PowerApps opnemen
       BEV.Tijdstip,
       BEV.Gebruiker,
       BEV.Prioriteit,
       BEV.[Voorlopige einddatum]
	   ,ROW_NUMBER() OVER (PARTITION BY CART.[Eenheidnr] order BY CART.[Categorie OVT] DESC) AS Volgnr
FROM   Cartotheek.OpenVerbrandingsToestellen AS CART
    LEFT OUTER JOIN [PowerApps].[Bevindingen] AS BEV
        ON BEV.Sleutel = CART.Sleutel
	   )

SELECT
	OVT.[Sleutel]
   , -- In PBI labellen als primary key + In PowerApps meenemen
	ELS.Eenheidnr
   ,ELS.corpodata_type
   ,ELS.bouwjaar
   ,ELS.clusternummer
   ,ELS.clusternaam
   ,ELS.adres
   ,ELS.status_eenheidskaart
   ,ELS.[IN exploitatie]
   ,ELS.omschrijving_technischtype
   ,OVT.[Datum]
   ,OVT.[Cartotheek-item]
   ,OVT.[Cartotheek-item-omschrijving]
   ,OVT.[Categorie OVT]
   ,OVT.[aanwezig]
   ,COALESCE(OVT.[rekenregel], 'Eenheid niet meegenomen in rapportage, waarom ?') AS [rekenregel]
   ,OVT.Opmerking
   ,  -- In PowerApps opnemen
	OVT.Onderwerp
   ,  -- In PowerApps opnemen
	OVT.Tijdstip
   ,OVT.Gebruiker
   ,OVT.Prioriteit
   ,OVT.[Voorlopige einddatum]
   ,'<a href="'
	+ empire_staedion_data.empire.fnEmpireLink(
	'Staedion',
	11024266,
	'No.=''' + ELS.[Eenheidnr] + '''' + ',Table=''1''',
	'view'
	) + '">Cartotheek ' + ELS.[Eenheidnr] + '</a>' AS [Hyperlink Empire]
	,ELS.clusternummer + ' '+ ELS.clusternaam AS cluster
	,ELs.eenheidnr + ' '+ ELS.adres AS eenheid
FROM empire_Staedion_data.dbo.els AS ELS
LEFT OUTER JOIN cte_OVT AS OVT
	ON OVT.Eenheidnr = ELS.Eenheidnr
		AND OVT.volgnr = 1
WHERE ELS.datum_gegenereerd = (SELECT
		MAX(datum_gegenereerd)
	FROM empire_Staedion_data.dbo.els
	WHERE datum_gegenereerd < GETDATE())
AND ELS.corpodata_type LIKE '%WON%'
	AND ELS.[In Exploitatie] = 'Ja'






GO
