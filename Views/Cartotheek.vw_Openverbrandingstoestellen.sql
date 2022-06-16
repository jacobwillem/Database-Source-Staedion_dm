SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Cartotheek].[vw_Openverbrandingstoestellen]												-- in PBI opnemen 
AS
SELECT CART.[Sleutel], -- In PBI labellen als primary key + In PowerApps meenemen
       CART.[Corpodatatype],
       CART.[Eenheid],
       CART.[Eenheidnr],
       CART.[Datum],
       CART.[Cartotheek-item],
       CART.[Cartotheek-item-omschrijving],
       CART.[Categorie OVT],
       CART.[aanwezig],
       CART.[status eenheidskaart],
       CART.[Bouwjaar],
       CART.[Exploitatiestatus],
       CART.[rekenregel],
       BEV.Opmerking,  -- In PowerApps opnemen
       BEV.Onderwerp,  -- In PowerApps opnemen
       BEV.Tijdstip,
       BEV.Gebruiker,
       BEV.Prioriteit,
       BEV.[Voorlopige einddatum],
       '<a href="'
       + empire_staedion_data.empire.fnEmpireLink(
                                                     'Staedion',
                                                     11024266,
                                                     'No.=''' + CART.[Eenheidnr] + '''' + ',Table=''1''',
                                                     'view'
                                                 ) + '">Cartotheek ' + CART.[Eenheidnr] + '</a>' AS [Hyperlink Empire]
FROM Cartotheek.OpenVerbrandingsToestellen AS CART
    LEFT OUTER JOIN [PowerApps].[Bevindingen] AS BEV
        ON BEV.Sleutel = CART.Sleutel
		WHERE CART.[Categorie OVT] <> 'Geen OVT'
		
GO
