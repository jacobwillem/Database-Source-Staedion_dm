SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [RekeningCourant].[vw_HuurstandenBOG] 
 AS 
SELECT	   [Divisiecode klant] = KLANT.[Responsibility Center],
           [Klantnr] = STAND.[klantnr],
           STAND.[klantboekingsgroep],
           Klantnaam = STAND.[Name],
           STAND.[Eenheidnr],
           [Adres eenheid] = STAND.[eenheid_adres],
           [Postcode eenheid] = STAND.[eenheid_postcode],
           [Plaats eenheid] = STAND.[eenheid_plaats],
           [FT-cluster] = STAND.[complex],
           [Clusternaam] = STAND.[complex_naam],
           [Technisch type] = STAND.[technisch_type],
           [Wijk] = STAND.[wijk_naam],
           [Buurt] = STAND.[buurt_naam],
           [Verhuurteam] = STAND.[staedion_verhuurteam],
           [Thuisteam] = STAND.[staedion_thuisteam],
           --STAND.[da_heeft_lopend_contract],
           [Heeft minnelijke beschikking] = STAND.[heeft_minnelijkeschikking],
           [Heeft WNSP] = STAND.[heeft_wsnp],
           STAND.[heeft_wsnp_oud],
           [Heeft deurwaarder] = STAND.[ha_bij_deurwaarder],
           [Heeft betalingsregeling] = STAND.[ha_heeft_betalingsregeling],
           Prioriteit = STAND.[prioriteit],
           Regel = STAND.[Regel],
           [Openstaand saldo] = STAND.[openstaand_saldo], -- De kolom 'Openstaand saldo' geeft het openstaande vervallen saldo aan inclusief toekomstige termijnen van een betalingsregeling, exclusief de posten waarvan de vervaldatum na de peildatum ligt.
           Saldo = STAND.[saldo], -- - De kolom 'Saldo' geeft het totale saldo inclusief toekomstige betalingstermijnen en nog niet vervallen posten. Deze komt overeen met wat er in het grootboek staat. Boekdatum is dus bepalend, niet vervaldatum
           Vooruitbetaling = STAND.[vooruitbetaling], -- De kolom Vooruitbet. geeft het bedrag aan is ontvangen voor de peildatum en afgeletterd is tegen een post met een vervaldatum na de peildatum.
           Rekensaldo = STAND.[gecorr_saldo], -- De kolom Rekensaldo betreft het openstaande saldo exclusief eventuele vooruitbetalingen. Op basis van het rekensaldo wordt de voorziening bepaald.
           [Percentage] = STAND.[percentage],
           [Voorziening] = STAND.[voorziening],
           [Categorie] = STAND.[categorie],
           STAND.[BOG],
		   STAND.Peildatum, 
		   [Zittend of vertrokken] = case STAND.[da_heeft_lopend_contract] when 'Ja' then 'Zittend' when 'Nee' then 'Vertrokken' else 'Nvt' end,
		   [Achterstand of voorstand] = case when STAND.[saldo] <0  then 'Voorstand' else case when STAND.[saldo] >0 then 'Achterstand' else 'Nvt' end end,
           [Opmerking 1] = CASE
                               WHEN KLANT.[Responsibility Center] = '85'
                                    AND NULLIF(STAND.[BOG], '') IS NULL THEN
                                   'BOG want divisiecode 85'
                           END,
		   [Huidige periode] = case when STAND.Peildatum =  (select max(KOPIE.Peildatum) from [staedion_dm].[RekeningCourant].HistorieStand AS KOPIE) then 'Ja' else 'Nee' end

    -- select SUM(Saldo)
	-- select distinct [da_heeft_lopend_contract]
    FROM staedion_dm.RekeningCourant.HistorieStand AS STAND
        LEFT OUTER JOIN empire_Data.dbo.customer AS KLANT
            ON KLANT.no_ = STAND.klantnr
    WHERE YEAR(Peildatum) >= 2020
	and   Peildatum = eomonth(Peildatum) -- stand 1-1 of 1-7 niet meenemen
	AND (KLANT.[Responsibility Center] = '85'
                                    or STAND.[BOG]  = 'BOG')
;

GO
