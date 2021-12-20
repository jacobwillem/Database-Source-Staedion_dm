SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

















CREATE PROCEDURE[dbo].[sp_load_kpi_npo_doorlooptijd](
  @peildatum date = '20211031'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_npo_doorlooptijd] '20211214'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures where Databaseobject like '%npo_doorlooptijd%' order by Begintijd desc

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime;
	declare @finish as datetime;
	declare @fk_indicator_id smallint;

	set	@start = current_timestamp;


	select	 [Verzoek]
			,[Verzoek - huurdernr]
			,[Verzoek - eenheidnr]
			,[Verzoek - clusternummer]
			,[Verzoek - bouwbloknummer]
			,[Verzoek - eenheidtype]
			,[Verzoek - straatnaam]
			,[Verzoek - huisnummer]
			,[Verzoek - toevoegsel] 
			,[Verzoek - plaats]
			,[Verzoek - BU buurt code]
			,[Verzoek - Buurt]
			,[Verzoek - Gemeente]
			,[Verzoek - DagelijksOnderhoudGebied]
			,[Verzoek - onderhoudstype]
			,[Verzoek - status]
			,[Verzoek - datum invoer]
			,[Verzoek - gereed]
			,[Verzoek - Order laatste gereed]
			,[Verzoek - Order laatste datum technisch gereed]
			,[Verzoek - Aantal verschillende uitvoerenden]
			,[Order] 
			,[Order - status]
			,[Order - Eigen dienst of derde]
			,[Order - Leverancier rekening houdend met afhaalorder]
			,[Order - Uitvoerende]
			,[Order - Taak bekwaamheid]
			,[Order - Taak standaard taakcode] = left([Order - Taak standaard taakcode], 250)
			,[Order - Taak draaideur of brand]
			,[Order - urgent]
			,[Order - openstaand] 
			,[Order - gunningsdatum]
			,[Order - datum technisch gereed]
			,[Order - Gefactureerd]
			,[Order - Factuurdatum]
			,[Order - Totale kosten incl BTW]
			,[Order - Totale kosten incl BTW categorie]
			,[Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
			,[Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
			,[Doorlooptijd in werkdagen - factuurdatum order minus technisch gereed order]
			,[Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
			,[Order - norm technisch gereed order minus gunningsdatum order]
			,[Order - norm factuurdatum order minus technisch gereed order]
			,[Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
			,[Order - voldoet aan norm factuurdatum order minus technisch gereed order]
			into #TempTable
			FROM empire_dwh.dbo.[ITVF_npo_doorlooptijd](DATEADD(year, -1, @peildatum), @peildatum);
			
-----------------------------------------------------------------------------------------------------------
	-- 1003 Eigen dienst - delta werkdagen vanaf melding reparatieverzoek tot laatste order technisch gereed

		set @fk_indicator_id = 1003;
		
			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														--,[Detail_05]
														--,[Detail_06]
														--,[Detail_07]
														--,[Detail_08]
														--,[Detail_09]
														--,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														--,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														--,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

		SELECT	 [fk_indicator_id] = @fk_indicator_id
				,[Datum] = cast([Verzoek - Order laatste datum technisch gereed] as date)
				,[Laaddatum] = getdate()
				,[Waarde] = [Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
				--,[Teller]
				--,[Noemer]
				,[Omschrijving] =	  'Onderhoudsverzoek: '
									+ [Verzoek]
									+ '; '
									+ 'Verzoekstatus: '
									+ [Verzoek - status]
									+ '; '
									+ 'Invoerdatum: '
									+ format([Verzoek - datum invoer], 'yyyy-MM-dd')
									+ '; '
									+ 'Adres: '
									+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
									+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
									+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
									+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
									+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
									+ '; '
									+ 'Aantal verschillende uitvoerenden: '
									+ format([Verzoek - Aantal verschillende uitvoerenden], 'G')
				,[Detail_01] = cast([Verzoek - datum invoer] as date)
				,[Detail_02] = [Verzoek - status]
				,[Detail_03] = [Verzoek - DagelijksOnderhoudGebied]
				,[Detail_04] = [Verzoek - Aantal verschillende uitvoerenden]
				--,[Detail_05]
				--,[Detail_06]
				--,[Detail_07] 
				--,[Detail_08] 
				--,[Detail_09]
				--,[Detail_10]
				,[eenheidnummer] = [Verzoek - eenheidnr]
				,[bouwbloknummer] = [Verzoek - bouwbloknummer]
				,[clusternummer] = [Verzoek - clusternummer]
				,[klantnummer] = [Verzoek - huurdernr]
				--,[volgnummer]
				--,[relatienummer]
				--,[dossiernummer]
				--,[betalingsregelingnummer]
				--,[rekeningnummer]
				--,[documentnummer]
				--,[leveranciernummer]
				--,[werknemernummer]
				--,[projectnummer]
				,[verzoeknummer] = [Verzoek]
				--,[ordernummer]
				--,[taaknummer]
				--,[overig]
		FROM #TempTable
		WHERE [Verzoek - Order laatste datum technisch gereed] IS NOT NULL
				AND [Order - Eigen dienst of derde] = 'Eigen dienst'
				and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
				and [Verzoek - gereed] = 1
				and [Verzoek - Order laatste gereed] = 1
				AND year([Verzoek - Order laatste datum technisch gereed]) = year(@peildatum)
				and month([Verzoek - Order laatste datum technisch gereed]) = month(@peildatum);


-----------------------------------------------------------------------------------------------------------
	-- 1020 Aantal afgeronde orders dagelijks onderhoud

		set @fk_indicator_id = 1020;
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														--,[Omschrijving]
														--,[Detail_01]
														--,[Detail_02]
														--,[Detail_03]
														--,[Detail_04]
														--,[Detail_05]
														--,[Detail_06]
														--,[Detail_07]
														--,[Detail_08]
														--,[Detail_09]
														--,[Detail_10]
														--,[eenheidnummer]
														--,[bouwbloknummer]
														--,[clusternummer]
														--,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														--,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														--,[verzoeknummer]
														--,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

			SELECT	 [fk_indicator_id] = max(@fk_indicator_id)
					,[Datum] = cast([Order - datum technisch gereed] as date)
					,[Laaddatum] = max(getdate())
					,[Waarde] = COUNT(distinct [Order])
					--,[Teller]
					--,[Noemer]
					--,[Omschrijving]
					--,[Detail_01]
					--,[Detail_02]
					--,[Detail_03]
					--,[Detail_04]
					--,[Detail_05]
					--,[Detail_06]
					--,[Detail_07]
					--,[Detail_08]
					--,[Detail_09]
					--,[Detail_10]
					--,[eenheidnummer]
					--,[bouwbloknummer]
					--,[clusternummer]
					--,[klantnummer]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					--,[leveranciernummer]
					--,[werknemernummer]
					--,[projectnummer]
					--,[verzoeknummer]
					--,[ordernummer]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE [Order - datum technisch gereed] IS NOT NULL
					AND year([Order - datum technisch gereed]) = year(@peildatum)
					and month([Order - datum technisch gereed]) = month(@peildatum)
			GROUP BY cast([Order - datum technisch gereed] as date);

--------------------------------------------------------------------------------------------------------
	-- 1031 Eigen dienst - delta werkdagen vanaf order gegund tot order openstaand op peildatum

	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN
		set @fk_indicator_id = 1031;
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														--,[Detail_09]
														--,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = cast(getdate() as date)
					,[Laaddatum] = getdate()
					,[Waarde] = [Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
					--,[Teller]
					--,[Noemer]
					,[Omschrijving] =	  'Onderhoudsorder: '
										+ [Order]
										+ '; '
										+ 'Orderstatus: '
										+ [Order - status]
										+ '; '
										+ 'Gunningsdatum: '
										+ format([Order - gunningsdatum], 'yyyy-MM-dd')
										+ '; '
										+ 'Adres: '
										+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
										+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
										+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
										+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
										+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
										+ '; '
										+ 'Leverancier: '
										+ [Order - Uitvoerende]
					,[Detail_01] = cast([Order - gunningsdatum] as date)
					,[Detail_02] = [Order - status]
					,[Detail_03] = [Order - urgent]
					,[Detail_04] = [Verzoek - DagelijksOnderhoudGebied]
					,[Detail_05] = [Order - Uitvoerende] 
					,[Detail_06] = [Order - Taak bekwaamheid]
					,[Detail_07] = [Order - Taak standaard taakcode]
					,[Detail_08] = [Order - Taak draaideur of brand]
					--,[Detail_09]
					--,[Detail_10]
					,[eenheidnummer] = [Verzoek - eenheidnr]
					,[bouwbloknummer] = [Verzoek - bouwbloknummer]
					,[clusternummer] = [Verzoek - clusternummer]
					,[klantnummer] = [Verzoek - huurdernr]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					,[leveranciernummer] = [Order - Leverancier rekening houdend met afhaalorder]
					--,[werknemernummer]
					--,[projectnummer]
					,[verzoeknummer] = [Verzoek]
					,[ordernummer] = [Order]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE [Order - gunningsdatum] IS NOT NULL
					AND [Order - Eigen dienst of derde] = 'Eigen dienst'
					and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
					and [Order - openstaand] = 1;
		END

-----------------------------------------------------------------------------------------------------------
	-- 1032 Eigen dienst - delta werkdagen vanaf order gegund tot order technisch gereed


		set @fk_indicator_id = 1032;
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]						
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														,[Detail_09]							
														,[Detail_10]							
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														,[ordernummer]							
														--,[taaknummer]
														--,[overig]
														)
			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = cast([Order - datum technisch gereed] as date)
					,[Laaddatum] = getdate()
					,[Waarde] = [Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
					--,[Teller]
					--,[Noemer]
					,[Omschrijving] =	  'Onderhoudsorder: '
										+ [Order]
										+ '; '
										+ 'Orderstatus: '
										+ [Order - status]
										+ '; '
										+ 'Gunningsdatum: '
										+ format([Order - gunningsdatum], 'yyyy-MM-dd')
										+ '; '
										+ 'Norm: '
										+ iif([Order - Gefactureerd] = 1, format([Order - norm technisch gereed order minus gunningsdatum order], 'G') + ' werkdagen', 'Onbekend/NVT')
										+ '; '
										+ 'Adres: '
										+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
										+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
										+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
										+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
										+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
										+ '; '
										+ 'Leverancier: '
										+ [Order - Uitvoerende]
										+ '; '
										+ 'Orderkosten: '
										+ iif([Order - Gefactureerd] = 1, format([Order - Totale kosten incl BTW], 'C', 'nl-nl'), 'Onbekend/NVT')
					,[Detail_01] = cast([Order - gunningsdatum] as date)
					,[Detail_02] = [Order - status]
					,[Detail_03] = [Order - urgent]
					,[Detail_04] = [Verzoek - DagelijksOnderhoudGebied]
					,[Detail_05] = [Order - Uitvoerende] 
					,[Detail_06] = [Order - Totale kosten incl BTW categorie]
					,[Detail_07] = [Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
					,[Detail_08] = [Order - Taak bekwaamheid]
					,[Detail_09] = [Order - Taak standaard taakcode]
					,[Detail_10] = [Order - Taak draaideur of brand]
					,[eenheidnummer] = [Verzoek - eenheidnr]
					,[bouwbloknummer] = [Verzoek - bouwbloknummer]
					,[clusternummer] = [Verzoek - clusternummer]
					,[klantnummer] = [Verzoek - huurdernr]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					,[leveranciernummer] = [Order - Leverancier rekening houdend met afhaalorder]
					--,[werknemernummer]
					--,[projectnummer]
					,[verzoeknummer] = [Verzoek]
					,[ordernummer] = [Order]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE [Order - datum technisch gereed] IS NOT NULL
					AND [Order - Eigen dienst of derde] = 'Eigen dienst'
					and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
					AND year([Order - datum technisch gereed]) = year(@peildatum)
					and month([Order - datum technisch gereed]) = month(@peildatum);

-----------------------------------------------------------------------------------------------------------
	-- 1006 Derden - delta werkdagen vanaf melding reparatieverzoek tot laatste order technisch gereed

		set @fk_indicator_id = 1006;
		
			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														--,[Detail_05]
														--,[Detail_06]
														--,[Detail_07]
														--,[Detail_08]
														--,[Detail_09]
														--,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														--,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														--,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

		SELECT	 [fk_indicator_id] = @fk_indicator_id
				,[Datum] = cast([Verzoek - Order laatste datum technisch gereed] as date)
				,[Laaddatum] = getdate()
				,[Waarde] = [Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
				--,[Teller]
				--,[Noemer]
				,[Omschrijving] =	  'Onderhoudsverzoek: '
									+ [Verzoek]
									+ '; '
									+ 'Verzoekstatus: '
									+ [Verzoek - status]
									+ '; '
									+ 'Invoerdatum: '
									+ format([Verzoek - datum invoer], 'yyyy-MM-dd')
									+ '; '
									+ 'Adres: '
									+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
									+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
									+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
									+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
									+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
									+ '; '
									+ 'Aantal verschillende uitvoerenden: '
									+ format([Verzoek - Aantal verschillende uitvoerenden], 'G')
				,[Detail_01] = cast([Verzoek - datum invoer] as date)
				,[Detail_02] = [Verzoek - status]
				,[Detail_03] = [Verzoek - DagelijksOnderhoudGebied]
				,[Detail_04] = [Verzoek - Aantal verschillende uitvoerenden]
				--,[Detail_05]
				--,[Detail_06]
				--,[Detail_07] 
				--,[Detail_08] 
				--,[Detail_09]
				--,[Detail_10]
				,[eenheidnummer] = [Verzoek - eenheidnr]
				,[bouwbloknummer] = [Verzoek - bouwbloknummer]
				,[clusternummer] = [Verzoek - clusternummer]
				,[klantnummer] = [Verzoek - huurdernr]
				--,[volgnummer]
				--,[relatienummer]
				--,[dossiernummer]
				--,[betalingsregelingnummer]
				--,[rekeningnummer]
				--,[documentnummer]
				--,[leveranciernummer]
				--,[werknemernummer]
				--,[projectnummer]
				,[verzoeknummer] = [Verzoek]
				--,[ordernummer]
				--,[taaknummer]
				--,[overig]
		FROM #TempTable
		WHERE [Verzoek - Order laatste datum technisch gereed] IS NOT NULL
				AND [Order - Eigen dienst of derde] = 'Derde'
				and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
				and [Verzoek - gereed] = 1
				and [Verzoek - Order laatste gereed] = 1
				AND year([Verzoek - Order laatste datum technisch gereed]) = year(@peildatum)
				and month([Verzoek - Order laatste datum technisch gereed]) = month(@peildatum);

--------------------------------------------------------------------------------------------------------
	-- 1071 Derden - delta werkdagen vanaf order gegund tot order openstaand op peildatum

	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN
		set @fk_indicator_id = 1071;
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														--,[Detail_09]
														--,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = cast(getdate() as date)
					,[Laaddatum] = getdate()
					,[Waarde] = [Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
					--,[Teller]
					--,[Noemer]
					,[Omschrijving] =	  'Onderhoudsorder: '
										+ [Order]
										+ '; '
										+ 'Orderstatus: '
										+ [Order - status]
										+ '; '
										+ 'Gunningsdatum: '
										+ format([Order - gunningsdatum], 'yyyy-MM-dd')
										+ '; '
										+ 'Adres: '
										+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
										+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
										+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
										+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
										+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
										+ '; '
										+ 'Leverancier: '
										+ [Order - Uitvoerende]
					,[Detail_01] = cast([Order - gunningsdatum] as date)
					,[Detail_02] = [Order - status]
					,[Detail_03] = [Order - urgent]
					,[Detail_04] = [Verzoek - DagelijksOnderhoudGebied]
					,[Detail_05] = [Order - Uitvoerende] 
					,[Detail_06] = [Order - Taak bekwaamheid]
					,[Detail_07] = [Order - Taak standaard taakcode]
					,[Detail_08] = [Order - Taak draaideur of brand]
					--,[Detail_09]
					--,[Detail_10]
					,[eenheidnummer] = [Verzoek - eenheidnr]
					,[bouwbloknummer] = [Verzoek - bouwbloknummer]
					,[clusternummer] = [Verzoek - clusternummer]
					,[klantnummer] = [Verzoek - huurdernr]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					,[leveranciernummer] = [Order - Leverancier rekening houdend met afhaalorder]
					--,[werknemernummer]
					--,[projectnummer]
					,[verzoeknummer] = [Verzoek]
					,[ordernummer] = [Order]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE [Order - gunningsdatum] IS NOT NULL
					AND [Order - Eigen dienst of derde] = 'Derde'
					and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
					and [Order - openstaand] = 1;
		END
	
-----------------------------------------------------------------------------------------------------------
	-- 1072 Derden - delta werkdagen vanaf order gegund tot order technisch gereed

		set @fk_indicator_id = 1072;
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														,[Detail_09]
														,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = cast([Order - datum technisch gereed] as date)
					,[Laaddatum] = getdate()
					,[Waarde] = [Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
					--,[Teller]
					--,[Noemer]
					,[Omschrijving] =	  'Onderhoudsorder: '
										+ [Order]
										+ '; '
										+ 'Orderstatus: '
										+ [Order - status]
										+ '; '
										+ 'Gunningsdatum: '
										+ format([Order - gunningsdatum], 'yyyy-MM-dd')
										+ '; '
										+ 'Norm: '
										+ iif([Order - Gefactureerd] = 1, format([Order - norm technisch gereed order minus gunningsdatum order], 'G') + ' werkdagen', 'Onbekend/NVT')
										+ '; '
										+ 'Adres: '
										+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
										+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
										+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
										+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
										+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
										+ '; '
										+ 'Leverancier: '
										+ [Order - Uitvoerende]
										+ '; '
										+ 'Orderkosten: '
										+ iif([Order - Gefactureerd] = 1, format([Order - Totale kosten incl BTW], 'C', 'nl-nl'), 'Onbekend/NVT')
					,[Detail_01] = cast([Order - gunningsdatum] as date)
					,[Detail_02] = [Order - status]
					,[Detail_03] = [Order - urgent]
					,[Detail_04] = [Verzoek - DagelijksOnderhoudGebied]
					,[Detail_05] = [Order - Uitvoerende] 
					,[Detail_06] = [Order - Totale kosten incl BTW categorie]
					,[Detail_07] = [Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
					,[Detail_08] = [Order - Taak bekwaamheid]
					,[Detail_09] = [Order - Taak standaard taakcode]
					,[Detail_10] = [Order - Taak draaideur of brand]
					,[eenheidnummer] = [Verzoek - eenheidnr]
					,[bouwbloknummer] = [Verzoek - bouwbloknummer]
					,[clusternummer] = [Verzoek - clusternummer]
					,[klantnummer] = [Verzoek - huurdernr]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					,[leveranciernummer] = [Order - Leverancier rekening houdend met afhaalorder]
					--,[werknemernummer]
					--,[projectnummer]
					,[verzoeknummer] = [Verzoek]
					,[ordernummer] = [Order]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE [Order - datum technisch gereed] IS NOT NULL
					AND [Order - Eigen dienst of derde] = 'Derde'
					and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
					AND year([Order - datum technisch gereed]) = year(@peildatum)
					and month([Order - datum technisch gereed]) = month(@peildatum);

	
-----------------------------------------------------------------------------------------------------------
	-- 1073 Derden - delta werkdagen vanaf order technisch gereed tot factuur datum

		set @fk_indicator_id = 1073;
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														,[Detail_09]
														,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														,[verzoeknummer]
														,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)

			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = cast([Order - Factuurdatum] as date)
					,[Laaddatum] = getdate()
					,[Waarde] = [Doorlooptijd in werkdagen - factuurdatum order minus technisch gereed order]
					--,[Teller]
					--,[Noemer]
					,[Omschrijving] =	  'Onderhoudsorder: '
										+ [Order]
										+ '; '
										+ 'Orderstatus: '
										+ [Order - status]
										+ '; '
										+ 'Datum technisch gereed: '
										+ format(cast([Order - datum technisch gereed] as date), 'yyyy-MM-dd')
										+ '; '
										+ 'Norm: '
										+ format([Order - norm factuurdatum order minus technisch gereed order], 'G') + ' werkdagen'
										+ '; '
										+ 'Adres: '
										+ iif([Verzoek - eenheidtype] = '', '', [Verzoek - eenheidtype] + ' ')
										+ iif([Verzoek - straatnaam] = '', '', [Verzoek - straatnaam] + ' ')
										+ iif([Verzoek - huisnummer] = '', '', [Verzoek - huisnummer] + ' ')
										+ iif([Verzoek - toevoegsel] = '', '', [Verzoek - toevoegsel] + ' ') 
										+ iif([Verzoek - plaats] = '', '', [Verzoek - plaats]) 
										+ '; '
										+ 'Leverancier: '
										+ [Order - Uitvoerende]
										+ '; '
										+ 'Orderkosten: '
										+ format([Order - Totale kosten incl BTW], 'C', 'nl-nl')
					,[Detail_01] = cast([Order - datum technisch gereed] as date)
					,[Detail_02] = [Order - status]
					,[Detail_03] = [Order - urgent]
					,[Detail_04] = [Verzoek - dagelijksOnderhoudGebied]
					,[Detail_05] = [Order - Uitvoerende] 
					,[Detail_06] = [Order - Totale kosten incl BTW categorie]
					,[Detail_07] = [Order - voldoet aan norm factuurdatum order minus technisch gereed order]
					,[Detail_08] = [Order - Taak bekwaamheid]
					,[Detail_09] = [Order - Taak standaard taakcode]
					,[Detail_10] = [Order - Taak draaideur of brand]
					,[eenheidnummer] = [Verzoek - eenheidnr]
					,[bouwbloknummer] = [Verzoek - bouwbloknummer]
					,[clusternummer] = [Verzoek - clusternummer]
					,[klantnummer] = [Verzoek - huurdernr]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					,[leveranciernummer] = [Order - Leverancier rekening houdend met afhaalorder]
					--,[werknemernummer]
					--,[projectnummer]
					,[verzoeknummer] = [Verzoek]
					,[ordernummer] = [Order]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE [Order - Gefactureerd] = 1
					AND [Order - Eigen dienst of derde] = 'Derde'
					and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
					AND year([Order - Factuurdatum]) = year(@peildatum)
					and month([Order - Factuurdatum]) = month(@peildatum);

			drop table #TempTable;

		set	@finish = current_timestamp;
	
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish;
				
END TRY

BEGIN CATCH

	set	@finish = current_timestamp;

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT	ERROR_PROCEDURE() 
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE();
END CATCH

GO
