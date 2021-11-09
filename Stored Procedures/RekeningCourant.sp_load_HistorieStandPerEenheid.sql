SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [RekeningCourant].[sp_load_HistorieStandPerEenheid]
	(@Peildatum DATE) AS

/* =======================================================================================================================================
BETREFT:	Op verzoek van Rianne van der Slot: tonen van achterstanden op andere manier dan Rudolph, conform DWEX-wijze
			> per huurder/eenheid wordt gekeken van welke datum een openstaande post is, dan wordt zo de achterstand van een huurder verdeeld:
			huurder		eenheid		1 maand	2 maanden etc
			1			1			10		20
			1			2			0		400
			1			?			200		0


NB: updaten gebeurt via een abonnement op het rapport Voorzieningen rapportage huurdebiteuren

-----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
-----------------------------------------------------------------------------------------------------------------
20211106 JvdW aangemaakt
20211108 JvdW tijdens load viel ie over paar views uit empire_data: vervanging door verwijzing naar gematerialiseerde tabellen 

-----------------------------------------------------------------------------------------------------------------
TESTEN updaten van details in voorzieningen rapport
-----------------------------------------------------------------------------------------------------------------
DELETE FROM  staedion_dm.RekeningCourant.HistorieStandPerEenheid WHERE Peildatum = '20211031'
exec [dsp_rs_voorziening_debiteuren]
SELECT DISTINCT Peildatum FROM staedion_dm.RekeningCourant.HistorieStandPerEenheid


-----------------------------------------------------------------------------------------------------------------
TESTEN: Check consistentie
-----------------------------------------------------------------------------------------------------------------
SELECT Saldo = SUM(Saldo),
       [Optelsom klassen] = SUM(COALESCE([Saldo nvt],0)) + SUM([Saldo 0-1 maand]) + SUM([Saldo 1-2 maanden])
                            + SUM([Saldo 3 maanden]) + SUM([Saldo 4-6 maanden]) + SUM([Saldo 7-11 maanden])
                            + SUM([Saldo >=12 maanden]),
       [Openstaand saldo] = SUM(Rekensaldo)
FROM staedion_dm.RekeningCourant.[vw_HuurstandenBOGInclEenheden]
WHERE Peildatum = '20211031'
AND [Divisiecode klant] = '85'
AND [Achterstand of voorstand] = 'Achterstand'
;

-----------------------------------------------------------------------------------------------------------------
TESTEN: Detailcheck
-----------------------------------------------------------------------------------------------------------------
DECLARE @HRD AS NVARCHAR(20) = 'KLNT-0057656'

-- specificatie BOG DWEX 31-08-2021
SELECT
	[Divisiecode klant] = DIV.bk_code
   ,Klantnr = D.fk_klant_id
   ,[Saldo rekening-courant (grootboek)] = D.openstaand_saldo
   ,[Soort stand] = D.da_soortstand
   ,[Achterstandsduur] = D.da_duurstand
   ,[Zitten of vertrokken huurder] = D.da_vertrokkenhuurder
   ,D.dt_boeking
   ,D.omschrijving
   ,D.da_duurstand 
-- select sum(D.openstaand_saldo)
-- select top 1 D.*
FROM backup_empire_dwh.dbo.d_staedion_stand AS D
JOIN empire_dwh.dbo.klant AS KLANT
	ON D.fk_klant_id = KLANT.id
JOIN empire_dwh.dbo.relatie AS REL
	ON KLANT.fk_relatie_id = REL.id
JOIN empire_dwh.dbo.divisie AS DIV
	ON REL.fk_divisie_id = DIV.id
WHERE KLANT.da_klantboekingsgroep = 'HUURDERS'
AND D.datum = '20211030'
--AND DIV.bk_code = '85'
--AND D.da_soortstand = 'Achterstand'
AND KLANT.id = @HRD
;

-- Dataset - rekening houden met te betalen huur + ogeh - opbouw saldo naar post bepalen
SELECT Klantnr,
       Eenheidnr,
       [Boekdatum openstaande post],
       [Saldo 0-1 maand],
       [Saldo 1-2 maanden],
       [Saldo 2-3 maanden],
       [Saldo 4-6 maanden],
       [Saldo 7-11 maanden],
       [Saldo >=12 maanden]
FROM RekeningCourant.[vw_HuurstandenBOGInclEenheden]
WHERE Klantnr = @HRD
      AND Peildatum = '20211031'
ORDER BY [Boekdatum openstaande post];
SELECT TOP 100
       *
FROM staedion_dm.RekeningCourant.HistorieStandPerEenheid
WHERE Peildatum = '20211031'
      AND Klantnr = @HRD;
SELECT TOP 10
       *
FROM RekeningCourant.vw_HuurstandenBOG
WHERE Klantnr = @HRD; -- obv HistorieStand
SELECT TOP 10
       *
FROM RekeningCourant.vw_HuurstandenBOGInclEenheden
WHERE Klantnr = @HRD;
SELECT TOP 10
       *
FROM staedion_dm.RekeningCourant.HistorieStand
WHERE Peildatum = '20211031'
      AND klantnr = @HRD;

======================================================================================================================================= */


-- Saldi per eenheid (ongelijk aan 0)
-- Zie [dsp_rs_voorziening_debiteuren]

BEGIN TRY

		IF @Peildatum IS NULL 
		SET @Peildatum = EOMONTH(DATEADD(m, -1, GETDATE()))
		
		DELETE FROM RekeningCourant.HistorieStandPerEenheid WHERE Peildatum = @Peildatum
		;
		WITH cte_basis
						AS (SELECT Bedrijf = CLE.mg_bedrijf,
								   Klantnr = CLE.[Customer No_],
								   Eenheidnr = CLE.Eenheidnr_,
								   Saldo = CONVERT(
													  DECIMAL(12, 2),
													  SUM(IIF(dcl.[Posting Date] <= @Peildatum, dcl.amount, 0))
												  ),
								   Rekensaldo = CONVERT(
														   DECIMAL(12, 2),
														   SUM(IIF(
															   CLE.[Due Date] <= @Peildatum OR CLE.[Document Type] IN (
																														 10,
																														 11
																														 ),
																   dcl.amount,
																   0.0)
															  )
													   ),
								   Peildatum = @Peildatum,
								   [Boekdatum openstaande post] = CLE.[Posting Date],
								   Volgnr = ROW_NUMBER() OVER (PARTITION BY CLE.[Customer No_],
																			CLE.Eenheidnr_
															   ORDER BY CLE.[Posting Date] DESC
															  )
							FROM empire_data.dbo.vw_lt_mg_cust_ledger_entry AS CLE
								INNER JOIN empire_data.dbo.vw_lt_mg_detailed_cust_ledg_entry dcl
									ON CLE.mg_bedrijf = dcl.mg_bedrijf
									   AND CLE.[Entry No_] = dcl.[Cust_ Ledger Entry No_]
								INNER JOIN empire_data.dbo.Customer cus
									ON CLE.[Customer No_] = cus.[No_]
							WHERE cus.[Customer Posting Group] IN ( 'HUURDERS' )
								  AND dcl.mg_bedrijf IN ( 'Staedion', 'xEnergiek_2_B_V_' )
								  AND dcl.[Posting Date] <= @Peildatum
							--AND cus.No_ = 'HRDR-0003422'
							--AND cle.Eenheidnr_ = 'OGEH-0015381'
							GROUP BY CLE.mg_bedrijf,
									 CLE.[Customer No_],
									 CLE.Eenheidnr_,
									 CLE.[Posting Date]
							HAVING NOT (
										   CONVERT(
													  DECIMAL(12, 2),
													  SUM(IIF(
														  CLE.[Due Date] <= @Peildatum OR CLE.[Document Type] IN ( 10,
																													  11
																													),
															  dcl.amount,
															  0.0)
														 )
												  ) = 0
										   AND CONVERT(
														  DECIMAL(12, 2),
														  SUM(IIF(dcl.[Posting Date] <= @Peildatum, dcl.amount, 0))
													  ) = 0
									   )),
						cte_vooruitbetaling
						AS (SELECT Bedrijf = cle.mg_bedrijf,
								   Klantnr = cle.[Customer No_],
								   Eenheidnr = cle.Eenheidnr_,
								   Vooruitbetaling = SUM(dcl.Amount),
								   Peildatum = @Peildatum
							FROM empire_data.dbo.vw_lt_mg_cust_ledger_entry cle
								INNER JOIN empire_data.dbo.vw_lt_mg_detailed_cust_ledg_entry dcl
									ON cle.mg_bedrijf = dcl.mg_bedrijf
									   AND cle.[Entry No_] = dcl.[Cust_ Ledger Entry No_]
								INNER JOIN empire_data.dbo.vw_lt_mg_cust_ledger_entry afl
									ON dcl.[Applied Cust_ Ledger Entry No_] = afl.[Entry No_]
									   AND afl.[Posting Date] <= @Peildatum
								INNER JOIN empire_data.dbo.Customer cus
									ON cle.[Customer No_] = cus.[No_]
							WHERE cle.[Document Type] NOT IN ( 10, 11 )
								  AND cle.[Due Date] > @Peildatum
								  AND dcl.[Entry Type] >= 2
								  AND cus.[Customer Posting Group] IN ( 'HUURDERS' )
								  AND cle.mg_bedrijf IN ( 'Staedion', 'xEnergiek_2_B_V_' )
							GROUP BY cle.mg_bedrijf,
									 cle.[Customer No_],
									 cle.eenheidnr_)

	INSERT INTO staedion_dm.RekeningCourant.HistorieStandPerEenheid
	(
		[Bedrijf],
		[Klantnr],
		[Eenheidnr],
		[Saldo],
		[Rekensaldo],
		[Peildatum],
		[Boekdatum openstaande post],
		[Volgnr],
		[Vooruitbetaling],
		[Saldo 0-1 maand],
		[Saldo 1 maand],
		[Saldo 2 maanden],
		[Saldo 3 maanden],
		[Saldo 4-6 maanden],
		[Saldo 7-11 maanden],
		[Saldo >=12 maanden]
	)
	SELECT BASIS.[Bedrijf],
		   BASIS.[Klantnr],
		   BASIS.[Eenheidnr],
		   BASIS.[Saldo],
		   BASIS.[Rekensaldo],
		   BASIS.[Peildatum],
		   BASIS.[Boekdatum openstaande post],
		   BASIS.[Volgnr],
		   Vooruitbetaling = IIF(Volgnr = 1, UIT.Vooruitbetaling, 0),
		   [Saldo 0-1 maand] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum) < 1,
								   BASIS.[Saldo],
								   NULL),
		   [Saldo 1 maand] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum) = 1,
									 BASIS.[Saldo],
									 NULL),
		   [Saldo 2 maanden] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum) = 2,
									 BASIS.[Saldo],
									 NULL),
		   [Saldo 3 maanden] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum)
									= 3,
									 BASIS.[Saldo],
									 NULL),
		   [Saldo 4-6 maanden] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum)
									 BETWEEN 4 AND 6,
									 BASIS.[Saldo],
									 NULL),
		   [Saldo 7-11 maanden] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum)
									  BETWEEN 7 AND 11,
									  BASIS.[Saldo],
									  NULL),
		   [Saldo >=12 maanden] = IIF(DATEDIFF(MONTH, BASIS.[Boekdatum openstaande post], BASIS.Peildatum) >= 12,
									 BASIS.[Saldo],
									 NULL)
	FROM cte_basis AS BASIS
		LEFT OUTER JOIN cte_vooruitbetaling AS UIT
			ON BASIS.bedrijf = UIT.Bedrijf
			   AND BASIS.Klantnr = UIT.Klantnr
			   AND BASIS.eenheidnr = UIT.Eenheidnr
	--WHERE BASIS.Klantnr = 'HRDR-0003422'
END TRY
BEGIN CATCH

SELECT ERROR_LINE(), ERROR_NUMBER(),ERROR_MESSAGE()
END CATCH

;
GO
