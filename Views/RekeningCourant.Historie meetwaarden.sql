SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [RekeningCourant].[Historie meetwaarden]
AS
SELECT [mg_bedrijf]
	,[klantnr]
	,[klantboekingsgroep]
	,[Name]
	,[Eenheidnr]
	,[eenheid_adres]
	,[eenheid_postcode]
	,[eenheid_plaats]
	,[complex]
	,[complex_naam]
	,[technisch_type]
	,[wijk_naam]
	,[buurt_naam]
	,[staedion_verhuurteam]
	,[staedion_thuisteam]
	,[Zittend of vertrokken] = CASE 
		WHEN [da_heeft_lopend_contract] = 'Ja'
			THEN 'Zittend'
		ELSE CASE 
				WHEN [da_heeft_lopend_contract] = 'Nee'
					THEN 'Vertrokken'
				ELSE 'Onbekend'
				END
		END
	,[heeft_minnelijkeschikking]
	,[heeft_wsnp]
	,[heeft_wsnp_oud]
	,[ha_bij_deurwaarder]
	,[ha_heeft_betalingsregeling]
	,[prioriteit]
	,[Regel]
	,[openstaand_saldo]
	,[saldo]
	,[vooruitbetaling]
	,[gecorr_saldo]
	,[percentage]
	,[voorziening]
	,[categorie]
	,[BOG]
	,[Peildatum]
	,[Gegenereerd]
	,[Voor of achterstand] = CASE 
		WHEN coalesce(openstaand_saldo, 0) > 0
			THEN 'Achterstand'
		ELSE CASE 
				WHEN coalesce(openstaand_saldo, 0) < 0
					THEN 'Voorstand'
				ELSE 'Saldo 0'
				END
		END
FROM staedion_dm.RekeningCourant.HistorieStand
GO
