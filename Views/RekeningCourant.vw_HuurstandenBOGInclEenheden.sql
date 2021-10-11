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

-- als huurder maar 1 eenheid heeft, dan deze ook later benoemen ook als eenheidnr niet opgevoerd is in rekening-courant
WITH cte_aantal_contracten (
	Klantnr
	,Aantal
	,Eenheidnr
	)
AS (
	SELECT Klantnr = adi.[Customer No_]
		,Aantal = COUNT(*)
		,Eenheidnr = MAX(eenheidnr_)
	FROM empire_data.[dbo].[Staedion$Additioneel] adi
	GROUP BY adi.[Customer No_]
	)
-- eenheden ophalen die in Empire rekening-courant vermeld staan bij openstaande posten op die peildatum
-- hiervoor wordt gebruik gemaakt van HistorieStandPerEenheid - deze kunnen we apart opvoeren en moet sluiten met HistorieStand
	,cte_huurder_eenheid (
	klantnr
	,Eenheidnr
	)
AS (
	SELECT DISTINCT BASIS.klantnr
		,Eenheidnr = IIF(NULLIF(EENH.eenheidnr, '') IS NULL
			AND CTE.Aantal = 1, CTE.Eenheidnr, EENH.Eenheidnr)
	FROM [RekeningCourant].[vw_HuurstandenBOG] AS BASIS
	LEFT OUTER JOIN staedion_dm.rekeningcourant.HistorieStandPerEenheid AS EENH ON EENH.Peildatum = BASIS.Peildatum
		AND EENH.Klantnr = BASIS.Klantnr
	LEFT OUTER JOIN cte_aantal_contracten AS CTE ON CTE.klantnr = BASIS.Klantnr
	WHERE BASIS.[Huidige periode] = 'Ja'
	)
-- van alle relevante huurders gaan we bepalen welke eenheid op welk laatste moment nog actief was, daarvan kunnen we de brutohuur dan gaan bepalen
	,cte_huurder_eenheid_maandhuur (
	Klantnr
	,Eenheidnr
	,Ingangsdatum
	,PeildatumMaandhuur
	,Brutohuur
	)
AS (
	SELECT BASIS.Klantnr
		,BASIS.Eenheidnr
  	    ,ADDIT.Ingangsdatum
		,Einddatum = COALESCE(NULLIF(ADDIT.Einddatum, '17530101'), GETDATE())
		,HPR.brutohuur_inclbtw
	FROM cte_huurder_eenheid AS BASIS
	LEFT OUTER JOIN empire_data.dbo.staedion$Additioneel AS ADDIT ON ADDIT.Eenheidnr_ = BASIS.Eenheidnr
		AND ADDIT.[Customer No_] = BASIS.Klantnr
	OUTER APPLY empire_staedion_data.dbo.ITVfnHuurprijs(BASIS.Eenheidnr, COALESCE(NULLIF(ADDIT.Einddatum, '17530101'), GETDATE())) AS HPR
	)
	,cte_klant_peildatum_huurtotaal (
	Klantnr
	,EinddatumLaatsteContract
	)
AS (
	SELECT Klantnr
		,EinddatumLaatsteContract = MAX(PeildatumMaandhuur)
	FROM cte_huurder_eenheid_maandhuur
	GROUP BY Klantnr
	)
	,cte_klant_huur_totaal (
	Klantnr
	,EinddatumLaatsteContract
	,Brutohuur
	)
AS (
	SELECT PEIL.Klantnr
		,PEIL.EinddatumLaatsteContract
		,SUM(DETAILS.Brutohuur)
	FROM cte_klant_peildatum_huurtotaal AS PEIL
	JOIN cte_huurder_eenheid_maandhuur AS DETAILS ON PEIL.Klantnr = DETAILS.Klantnr
		AND DETAILS.Ingangsdatum <= PEIL.EinddatumLaatsteContract
		AND DETAILS.PeildatumMaandhuur >= PEIL.EinddatumLaatsteContract
	GROUP BY PEIL.Klantnr
		,PEIL.EinddatumLaatsteContract
	),
	cte_rapportage as 
(SELECT BASIS.Klantnr
	,BASIS.Klantnaam
	,[Saldo klant] = BASIS.Saldo
	,[Rekensaldo klant] = BASIS.Rekensaldo
	,BASIS.[Zittend of vertrokken]
	,BASIS.[Achterstand of voorstand]
	,[Totaal aantal contracten] = CONTR.Aantal
	,BASIS.[Heeft minnelijke beschikking]
	,BASIS.[Heeft WNSP]
	,BASIS.[Heeft deurwaarder]
	,BASIS.[Heeft betalingsregeling]
	,[Totale maandhuur klant] = KLANTHUUR.Brutohuur
	,[Totale rekensaldo tov maandhuur klant] = CASE 
		WHEN NULLIF(KLANTHUUR.Brutohuur, 0) IS NOT NULL
					THEN BASIS.Rekensaldo * 1.0 / KLANTHUUR.Brutohuur
		END
	,BASIS.Peildatum
	,Volgnr  = row_number() over (partition by BASIS.Klantnr order by IIF(NULLIF(EENH.eenheidnr, '') IS NULL
		AND CONTR.Aantal = 1, CONTR.Eenheidnr, EENH.Eenheidnr))

	,Eenheidnr = IIF(NULLIF(EENH.eenheidnr, '') IS NULL
		AND CONTR.Aantal = 1, CONTR.Eenheidnr, EENH.Eenheidnr)
	,Adres = OGE.Straatnaam + ' ' + OGE.Huisnr_ + ' ' + OGE.Toevoegsel
	,[Rekensaldo oge] = EENH.Rekensaldo
	,[Saldo eenheid] = EENH.Saldo
	,[Huur oge] = OGEHUUR.Brutohuur

-- select count(*) as AantalRegels, count(distinct BASIS.Klantnr) as AantalKlantnrs
FROM [RekeningCourant].[vw_HuurstandenBOG] AS BASIS
LEFT OUTER JOIN cte_aantal_contracten AS CONTR ON CONTR.Klantnr = BASIS.Klantnr
LEFT OUTER JOIN staedion_dm.rekeningcourant.HistorieStandPerEenheid AS EENH ON EENH.Peildatum = BASIS.Peildatum
	AND EENH.Klantnr = BASIS.Klantnr
LEFT OUTER JOIN cte_huurder_eenheid_maandhuur AS OGEHUUR ON OGEHUUR.Eenheidnr = IIF(NULLIF(EENH.eenheidnr, '') IS NULL
		AND CONTR.Aantal = 1, CONTR.Eenheidnr, EENH.Eenheidnr)
	AND OGEHUUR.Klantnr = BASIS.Klantnr
LEFT OUTER JOIN empire_data.dbo.staedion$oge AS OGE ON OGE.nr_ = IIF(NULLIF(EENH.eenheidnr, '') IS NULL
		AND CONTR.Aantal = 1, CONTR.Eenheidnr, EENH.Eenheidnr)
LEFT OUTER JOIN cte_klant_huur_totaal AS KLANTHUUR ON KLANTHUUR.klantnr = BASIS.Klantnr
WHERE BASIS.[Huidige periode] = 'Ja'
	--AND BASIS.[Achterstand of voorstand] = 'Achterstand';
	--AND BASIS.Klantnr = 'KLNT-0067217'
) 

select  BASIS.Klantnr
	,BASIS.Klantnaam
	,[Saldo klant] = iif(BASIS.Volgnr =1,BASIS.[Saldo klant],null)
	,[Rekensaldo klant] = iif(BASIS.Volgnr =1,BASIS.[Rekensaldo klant],null)
	,BASIS.[Zittend of vertrokken]
	,BASIS.[Achterstand of voorstand] 
	,[Totaal aantal contracten] = iif(BASIS.Volgnr =1,BASIS.[Totaal aantal contracten],null)
	,BASIS.[Heeft minnelijke beschikking]
	,BASIS.[Heeft WNSP]
	,BASIS.[Heeft deurwaarder]
	,BASIS.[Heeft betalingsregeling]
	,[Totale maandhuur klant] = iif(BASIS.Volgnr =1,BASIS.[Totale maandhuur klant],null)
	,[Totale rekensaldo tov maandhuur klant] = iif(BASIS.Volgnr =1,BASIS.[Totale rekensaldo tov maandhuur klant],null)
	,BASIS.Peildatum
	,BASIS.Volgnr 
	,BASIS.Eenheidnr 
	,BASIS.Adres 
	,BASIS.[Rekensaldo oge]
	,BASIS.[Saldo eenheid]
	,BASIS.[Huur oge] 
	,[Saldo nvt] = iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) <=0 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
--	,[Achterstand nieuwe stand] =  iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) >= 0 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 1 , BASIS.[Saldo klant] ,null)
	,[Saldo 0-1 maand] =  iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) > 0 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 1 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
	,[Saldo 1-2 maanden] = iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) >= 1 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 2 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
	,[Saldo 2-3 maanden] = iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) >= 2 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 3 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
	,[Saldo 3-6 maanden] = iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) >= 3 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 6 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
	,[Saldo 6-12 maanden] = iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) >= 6 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 12 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
	,[Saldo >12 maanden] =  iif(coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0) >= 12 and coalesce(BASIS.[Totale rekensaldo tov maandhuur klant],0 ) < 999 and BASIS.Volgnr =1, BASIS.[Saldo klant] ,null)
	from cte_rapportage as BASIS
;
GO
