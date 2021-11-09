SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [RekeningCourant].[vw_HuurstandenBOGInclEenheden]
AS
/* ######################################################################################################################

Dataset - rekening houden met te betalen huur + ogeh - opbouw saldo naar post bepalen

select  * from RekeningCourant.vw_HuurstandenBOGInclEenheden order by Klantnr, Eenheidnr

###################################################################################################################### */

SELECT BASIS.[Divisiecode klant],
	   [Klantnr en naam] = BASIS.[Klantnr] + ' ' + BASIS.[Klantnaam],
       BASIS.[Klantnr],
       BASIS.[klantboekingsgroep],
       BASIS.[Klantnaam],
       EENH.[Eenheidnr],
       [Adres eenheid] = COALESCE(EENH.[Eenheidnr] + ' ' + OGE.Straatnaam + ' ' + OGE.Huisnr_ + ' ' + OGE.Toevoegsel, 'Geen eenheid vermeld in openstaande post'),
       [Postcode eenheid] = OGE.Postcode,
       [Plaats eenheid] = OGE.Plaats,
       BASIS.[FT-cluster],
       BASIS.[Clusternaam],
       BASIS.[Technisch type],
       BASIS.[Wijk],
       BASIS.[Buurt],
       BASIS.[Verhuurteam],
       BASIS.[Thuisteam],
       BASIS.[Heeft minnelijke beschikking],
       BASIS.[Heeft WNSP],
       BASIS.[heeft_wsnp_oud],
       BASIS.[Heeft deurwaarder],
       BASIS.[Heeft betalingsregeling],
       BASIS.[Prioriteit],
       BASIS.[Regel],
       BASIS.[Openstaand saldo],
       [Saldo klant] = BASIS.[Saldo],
       BASIS.[Vooruitbetaling],
       [Rekensaldo klant] = BASIS.Rekensaldo,
       BASIS.[Rekensaldo],
       BASIS.[Percentage],
       BASIS.[Voorziening],
       BASIS.[Categorie],
       BASIS.[BOG],
       BASIS.[Peildatum],
       BASIS.[Zittend of vertrokken],
       BASIS.[Achterstand of voorstand],
       BASIS.[Opmerking 1],
       BASIS.[Huidige periode],

       [Rekensaldo oge] = EENH.Rekensaldo,
       [Saldo eenheid] = EENH.Saldo,
       EENH.[Boekdatum openstaande post],
       EENH.[Saldo],
       EENH.[Saldo nvt],
       EENH.[Saldo 0-1 maand],
       EENH.[Saldo 1 maand],
       EENH.[Saldo 2 maanden],       
	   EENH.[Saldo 3 maanden],
       EENH.[Saldo 4-6 maanden],
       EENH.[Saldo 7-11 maanden],
       EENH.[Saldo >=12 maanden]
-- select count(*) as AantalRegels, count(distinct BASIS.Klantnr) as AantalKlantnrs
-- select top 10 EENH.*
FROM [RekeningCourant].[vw_HuurstandenBOG] AS BASIS
    LEFT OUTER JOIN staedion_dm.RekeningCourant.HistorieStandPerEenheid AS EENH
        ON EENH.Peildatum = BASIS.Peildatum
           AND EENH.Klantnr = BASIS.Klantnr
    LEFT OUTER JOIN empire_data.dbo.staedion$oge AS OGE
        ON OGE.nr_ = EENH.Eenheidnr
GO
