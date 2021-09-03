SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














CREATE PROCEDURE[dbo].[sp_load_kpi_npo_doorlooptijd](
  @peildatum date = '20210430'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_npo_doorlooptijd] '20210131'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%personeelslasten%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 


################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id smallint

		set	@start = current_timestamp

		select	 [Verzoek]
				,[Verzoek - huurdernr]
				,[Verzoek - eenheidnr]
				,[Verzoek - clusternummer]
				,[Verzoek - onderhoudstype]
				,[Verzoek - gereed]
				,[Verzoek - Order laatste gereed]
				,[Verzoek - Order laatste datum technisch gereed]
				,[Order] 
				,[Order - Eigen dienst of derde]
				,[Order - Leverancier rekening houdend met afhaalorder]
				,[Order - Uitvoerende]
				,[Order - Taak bekwaamheid]
				,[Order - urgent]
				,[Order - openstaand] 
				,[Order - gunningsdatum]
				,[Order - datum technisch gereed]
				,[Order - Totale kosten incl BTW]
				,[Order - Totale kosten incl BTW >= 750]
				,[Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
				,[Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
				,[Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
				,[Order - norm technisch gereed order minus gunningsdatum order]
				,[Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
				into #TempTable
				FROM empire_dwh.dbo.[ITVF_npo_doorlooptijd TEST PP](datefromparts(year(@peildatum) - 1, month(@peildatum) + 1, 1), @peildatum)

-----------------------------------------------------------------------------------------------------------
	-- 1003 Eigen dienst - Δ werkdagen vanaf melding reparatieverzoek tot laatste order technisch gereed

		select @fk_indicator_id = 1003
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Eenheden] as 
				( 
						SELECT  *
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
				),
								
			[Details] as
				(
						SELECT   [Datum] = cast([Verzoek - Order laatste datum technisch gereed] as date)
								,[Verzoek]
								,[Verzoek - huurdernr]
								,[Verzoek - eenheidnr]
								,[Verzoek - adres] = iif(coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], '') = '', 'Onbekend/NVT',
									 coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], ''))
								,[Verzoek - clusternummer]
								,[Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
								--,[Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
								--,[Tijdig] = case when [Order - voldoet aan norm technisch gereed order minus gunningsdatum order] = 1 then 'Tijdig' else 'Buiten Norm' end
						FROM #TempTable as NPO
						left outer join [Eenheden] as EIG
							on EIG.Eenheidnr = NPO.[Verzoek - eenheidnr]
						WHERE [Verzoek - Order laatste datum technisch gereed] IS NOT NULL
								AND [Order - Eigen dienst of derde] = 'Eigen dienst'
								and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
								and [Verzoek - gereed] = 1
								and [Verzoek - Order laatste gereed] = 1
								AND year([Verzoek - Order laatste datum technisch gereed]) = year(@peildatum)
								and month([Verzoek - Order laatste datum technisch gereed]) = month(@peildatum))

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Verzoek] + '; ' +
													[Verzoek - huurdernr] + '; ' +
													[Verzoek - eenheidnr] + '; ' +
													[Verzoek - adres]
						,@fk_indicator_id 
						,[Verzoek - clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;

-----------------------------------------------------------------------------------------------------------
	-- 1020 Aantal afgeronde orders dagelijks onderhoud


		select @fk_indicator_id = 1020
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			
			[Details] as
				(
						SELECT   [Datum] = cast([Order - datum technisch gereed] as date)
								,[Aantal orders] = count([Order])
						FROM #TempTable as NPO
						WHERE [Order - datum technisch gereed] IS NOT NULL
								AND year([Order - datum technisch gereed]) = year(@peildatum)
								and month([Order - datum technisch gereed]) = month(@peildatum)
						Group by cast([Order - datum technisch gereed] as date))

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						--,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Aantal orders]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			= ''
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;

--------------------------------------------------------------------------------------------------------
	-- 1029 Eigen dienst - ∆ werkdagen vanaf order gegund tot order openstaand op peildatum

	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN
		select @fk_indicator_id = 1029
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			with
			[Eenheden] as 
				( 
						SELECT  *
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
				),
				

			[Details] as
				(
						SELECT   [Datum] = cast(getdate() as date)
								,[Order]
								,[Order - gunningsdatum]
								,[Order - Leverancier rekening houdend met afhaalorder]
								,[Order - Uitvoerende]
								,[Verzoek - huurdernr]
								,[Verzoek - eenheidnr]
								,[Verzoek - adres] = iif(coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], '') = '', 'Onbekend/NVT',
									 coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], ''))
								,[Verzoek - clusternummer]
								,[Order - Taak bekwaamheid]
								,[Order - urgentieklasse] = case when [Order - urgent] = 1 then 'Spoed' else 'Regulier' end
								,[Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
						FROM #TempTable as NPO
						left outer join [Eenheden] as EIG
							on EIG.Eenheidnr = NPO.[Verzoek - eenheidnr]
						WHERE [Order - gunningsdatum] IS NOT NULL
								AND [Order - Eigen dienst of derde] = 'Eigen dienst'
								and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
								and [Order - openstaand] = 1)

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Order] + '; ' +
													format([Order - gunningsdatum], 'yyyy-MM-dd') + '; ' +
													[Order - Leverancier rekening houdend met afhaalorder] + '; ' +
													[Order - Uitvoerende] + '; ' +
													[Verzoek - huurdernr] + '; ' +
													[Verzoek - eenheidnr] + '; ' +
													[Verzoek - adres] + '; ' +
													[Order - Taak bekwaamheid] + '; ' +
													[Order - urgentieklasse]
						,@fk_indicator_id 
						,[Verzoek - clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, cast(getdate() as date), avg([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
				group by det.fk_indicator_id;
		END


-----------------------------------------------------------------------------------------------------------
	-- 1030 Eigen dienst - ∆ werkdagen vanaf order gegund tot order technisch gereed


		select @fk_indicator_id = 1030
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Eenheden] as 
				( 
						SELECT  *
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
				),
				

			[Details] as
				(
						SELECT   [Datum] = cast([Order - datum technisch gereed] as date)
								,[Order]
								,[Order - gunningsdatum]
								,[Order - Leverancier rekening houdend met afhaalorder]
								,[Order - Uitvoerende]
								,[Verzoek - huurdernr]
								,[Verzoek - eenheidnr]
								,[Verzoek - adres] = iif(coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], '') = '', 'Onbekend/NVT',
									 coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], ''))
								,[Verzoek - clusternummer]
								,[Order - Taak bekwaamheid]
								,[Order - urgentieklasse] = case when [Order - urgent] = 1 then 'Spoed' else 'Regulier' end 
								,[Order - Totale kosten incl BTW]
								,[Order - Totale kosten incl BTW >= 750]
								,[Order - Totale kosten incl BTW categorie] = case when [Order - Totale kosten incl BTW >= 750] = 1 then 'Orderkosten >= 750' else 'Orderkosten < 750' end
								,[Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
								,[Order - norm technisch gereed order minus gunningsdatum order]
								,[Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
								,[Tijdig] = case when [Order - voldoet aan norm technisch gereed order minus gunningsdatum order] = 1 then 'Tijdig' else 'Buiten Norm' end
						FROM #TempTable as NPO
						left outer join [Eenheden] as EIG
							on EIG.Eenheidnr = NPO.[Verzoek - eenheidnr]
						WHERE [Order - datum technisch gereed] IS NOT NULL
								AND [Order - Eigen dienst of derde] = 'Eigen dienst'
								and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
								AND year([Order - datum technisch gereed]) = year(@peildatum)
								and month([Order - datum technisch gereed]) = month(@peildatum))

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Order] + '; ' +
													format([Order - gunningsdatum], 'yyyy-MM-dd') + '; ' +
													[Order - Leverancier rekening houdend met afhaalorder] + '; ' +
													[Order - Uitvoerende] + '; ' +
													[Verzoek - huurdernr] + '; ' +
													[Verzoek - eenheidnr] + '; ' +
													[Verzoek - adres] + '; ' +
													[Order - Taak bekwaamheid] + '; ' +
													[Order - urgentieklasse] + '; ' +
													FORMAT(coalesce([Order - Totale kosten incl BTW], 0), 'C', 'nl-NL') + '; ' +
													[Order - Totale kosten incl BTW categorie] + '; ' +
													'Norm: ' + cast([Order - norm technisch gereed order minus gunningsdatum order] as nvarchar) + '; ' +
													[Tijdig]
						,@fk_indicator_id 
						,[Verzoek - clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;

-----------------------------------------------------------------------------------------------------------
	-- 1006 Derden - Δ werkdagen vanaf melding reparatieverzoek tot laatste order technisch gereed

		select @fk_indicator_id = 1006
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Eenheden] as 
				( 
						SELECT  *
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
				),
				

			[Details] as
				(
						SELECT   [Datum] = cast([Verzoek - Order laatste datum technisch gereed] as date)
								,[Verzoek]
								,[Verzoek - huurdernr]
								,[Verzoek - eenheidnr]
								,[Verzoek - adres] = iif(coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], '') = '', 'Onbekend/NVT',
									 coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], ''))
								,[Verzoek - clusternummer]
								,[Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
								--,[Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
								--,[Tijdig] = case when [Order - voldoet aan norm technisch gereed order minus gunningsdatum order] = 1 then 'Tijdig' else 'Buiten Norm' end
						FROM #TempTable as NPO
						left outer join [Eenheden] as EIG
							on EIG.Eenheidnr = NPO.[Verzoek - eenheidnr]
						WHERE [Verzoek - Order laatste datum technisch gereed] IS NOT NULL
								AND [Order - Eigen dienst of derde] = 'Derde'
								and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
								and [Verzoek - gereed] = 1
								and [Verzoek - Order laatste gereed] = 1
								AND year([Verzoek - Order laatste datum technisch gereed]) = year(@peildatum)
								and month([Verzoek - Order laatste datum technisch gereed]) = month(@peildatum))

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Doorlooptijd in werkdagen - laatste order technisch gereed op afgerond verzoek minus invoerdatum verzoek]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Verzoek] + '; ' +
													[Verzoek - huurdernr] + '; ' +
													[Verzoek - eenheidnr] + '; ' +
													[Verzoek - adres]
						,@fk_indicator_id 
						,[Verzoek - clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;

	-----------------------------------------------------------------------------------------------------------
	-- 1069 Derden - ∆ werkdagen vanaf order gegund tot order openstaand op peildatum

	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN
		select @fk_indicator_id = 1069
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			with
			[Eenheden] as 
				( 
						SELECT  *
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
				),
				

			[Details] as
				(
						SELECT   [Datum] = cast(getdate() as date)
								,[Order]
								,[Order - gunningsdatum]
								,[Order - Leverancier rekening houdend met afhaalorder]
								,[Order - Uitvoerende]
								,[Verzoek - huurdernr]
								,[Verzoek - eenheidnr]
								,[Verzoek - adres] = iif(coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], '') = '', 'Onbekend/NVT',
									 coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], ''))
								,[Verzoek - clusternummer]
								,[Order - Taak bekwaamheid]
								,[Order - urgentieklasse] = case when [Order - urgent] = 1 then 'Spoed' else 'Regulier' end
								,[Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
						FROM #TempTable as NPO
						left outer join [Eenheden] as EIG
							on EIG.Eenheidnr = NPO.[Verzoek - eenheidnr]
						WHERE [Order - gunningsdatum] IS NOT NULL
								AND [Order - Eigen dienst of derde] = 'Derde'
								and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
								and [Order - openstaand] = 1)

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Doorlooptijd in werkdagen - op peildatum openstaande order minus gunningsdatum order]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Order] + '; ' +
													format([Order - gunningsdatum], 'yyyy-MM-dd') + '; ' +
													[Order - Leverancier rekening houdend met afhaalorder] + '; ' +
													[Order - Uitvoerende] + '; ' +
													[Verzoek - huurdernr] + '; ' +
													[Verzoek - eenheidnr] + '; ' +
													[Verzoek - adres] + '; ' +
													[Order - Taak bekwaamheid] + '; ' +
													[Order - urgentieklasse]
						,@fk_indicator_id 
						,[Verzoek - clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, cast(getdate() as date), avg([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
				group by det.fk_indicator_id;

		END
	-----------------------------------------------------------------------------------------------------------
	-- 1070 Derden - ∆ werkdagen vanaf order gegund tot order technisch gereed


		select @fk_indicator_id = 1070
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Eenheden] as 
				( 
						SELECT  *
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
				),
				

			[Details] as
				(
						SELECT   [Datum] = cast([Order - datum technisch gereed] as date)
								,[Order]
								,[Order - gunningsdatum]
								,[Order - Leverancier rekening houdend met afhaalorder]
								,[Order - Uitvoerende]
								,[Verzoek - huurdernr]
								,[Verzoek - eenheidnr]
								,[Verzoek - adres] = iif(coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], '') = '', 'Onbekend/NVT',
									 coalesce(EIG.Straatnaam, '') +
									 coalesce(' ' + cast(EIG.[Huisnummer] as nvarchar), '') + 
									 coalesce(EIG.[Huisnummer toevoeging], '') + 
									 coalesce(', ' + EIG.[Plaats], ''))
								,[Verzoek - clusternummer]
								,[Order - Taak bekwaamheid]
								,[Order - urgentieklasse] = case when [Order - urgent] = 1 then 'Spoed' else 'Regulier' end 
								,[Order - Totale kosten incl BTW]
								,[Order - Totale kosten incl BTW >= 750]
								,[Order - Totale kosten incl BTW categorie] = case when [Order - Totale kosten incl BTW >= 750] = 1 then 'Orderkosten >= 750' else 'Orderkosten < 750' end
								,[Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
								,[Order - norm technisch gereed order minus gunningsdatum order]
								,[Order - voldoet aan norm technisch gereed order minus gunningsdatum order]
								,[Tijdig] = case when [Order - voldoet aan norm technisch gereed order minus gunningsdatum order] = 1 then 'Tijdig' else 'Buiten Norm' end
						FROM #TempTable as NPO
						left outer join [Eenheden] as EIG
							on EIG.Eenheidnr = NPO.[Verzoek - eenheidnr]
						WHERE [Order - datum technisch gereed] IS NOT NULL
								AND [Order - Eigen dienst of derde] = 'Derde'
								and [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
								AND year([Order - datum technisch gereed]) = year(@peildatum)
								and month([Order - datum technisch gereed]) = month(@peildatum))

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum] 
						,[Waarde]				= [Doorlooptijd in werkdagen - technisch gereed order minus gunningsdatum order]
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Order] + '; ' +
													format([Order - gunningsdatum], 'yyyy-MM-dd') + '; ' +
													[Order - Leverancier rekening houdend met afhaalorder] + '; ' +
													[Order - Uitvoerende] + '; ' +
													[Verzoek - huurdernr] + '; ' +
													[Verzoek - eenheidnr] + '; ' +
													[Verzoek - adres] + '; ' +
													[Order - Taak bekwaamheid] + '; ' +
													[Order - urgentieklasse] + '; ' +
													FORMAT(coalesce([Order - Totale kosten incl BTW], 0), 'C', 'nl-NL') + '; ' +
													[Order - Totale kosten incl BTW categorie] + '; ' +
													'Norm: ' + cast([Order - norm technisch gereed order minus gunningsdatum order] as nvarchar) + '; ' +
													[Tijdig]
						,@fk_indicator_id 
						,[Verzoek - clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;

			drop table #TempTable;

		set		@finish = current_timestamp
	
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish
				
END TRY

BEGIN CATCH

	set		@finish = current_timestamp

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT	ERROR_PROCEDURE() 
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE() 
END CATCH

GO
