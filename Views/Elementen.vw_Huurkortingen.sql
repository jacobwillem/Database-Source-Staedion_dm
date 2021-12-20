SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Elementen].[vw_Huurkortingen]												-- in PBI opnemen 
as
SELECT SAM.[Sleutel], -- In PBI labellen als primary key + In PowerApps meenemen
       SAM.[Eenheidnr],
       SAM.[Eenheidnr] + ': ' + SAM.[Adres] AS Eenheid,
       SAM.[Klantnr] + ': ' + SAM.[Klantnaam] AS Klant,
       SAM.[Klantnr],
       SAM.[Klantnaam],
       SAM.[Elementnr] + ': ' + SAM.[Elementnaam] AS Element,
       SAM.[Elementnr],
       SAM.[Elementnaam],
       SAM.[Adres],
       SAM.[Thuisteam],
       DET.[Grootboekrekening],
       DET.[Boekdatum],
       DET.[Stuknummer],
       DET.[Bedrag],
       DET.[Volgnummer],
       DET.[Info verhuurmutatie],
       BEV.Opmerking, -- In PowerApps opnemen
       BEV.Onderwerp, -- In PowerApps opnemen
       BEV.Tijdstip,
       BEV.Gebruiker,
       BEV.Prioriteit,
	   BEV.[Voorlopige einddatum],
	   IIF(NULLIF(DET.[Info notitieveld contractregels],'') IS NULL,null,1) AS [Teller info contractregel],
	   IIF(NULLIF(SAM.Herzieningsdatum,'17530101') IS NULL,'Niet ingevuld','Wel ingevuld') AS [Teller herzieningsdatum],
       DET.[Info notitieveld contractregels],
	   SAM.[Info notitieveld contractregels geaggregeerd],
       SAM.[Info verhuurmutatie geaggregeerd],
       NULLIF(SAM.Herzieningsdatum,'17530101') AS Herzieningsdatum,
	   DET.[Gebruiker] AS [Verwerkt door],
	   IIF(DET.[Volgnummer] <> 0, 'Contractregels', 'Aparte nota') AS [Bron],
	   '<a href="'+empire_staedion_data.empire.fnEmpireLink('Staedion', 11024012, 'Soort=1,Eenheidnr.='+SAM.[Eenheidnr]+'', 'view')+'">'+SAM.[Eenheidnr]+'</a>' AS [Hyperlink Empire]
FROM Elementen.HuurkortingSamenvatting AS SAM
    LEFT OUTER JOIN Elementen.HuurkortingDetails AS DET
        ON DET.Sleutel = SAM.Sleutel
    LEFT OUTER JOIN [PowerApps].[Bevindingen] AS BEV
        ON BEV.Sleutel = SAM.Sleutel
		--WHERE 1=0
		
GO
