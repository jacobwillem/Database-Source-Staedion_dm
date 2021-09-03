SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROCEDURE[dbo].[sp_load_kpi_crediteuren](
  @peildatum date = '20210901', @fk_indicator_id smallint = 2610
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_crediteuren] '20210901' , @fk_indicator_id = 2619
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

		set	@start = current_timestamp

	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN

		--------------------------------------------------------------------------------------------------------
		-- 2610 Aantal openstaande crediteuren 31 - 60 dagen

		if @fk_indicator_id = 2610
			BEGIN
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			with
			[Details] as
				(
						select	 Documentdatum
								,[Document Type]
								,[Documentnr.]
								,Leveranciersnaam
								,[Bedrag VAT]
								,Factuurbedrag
								,Gebruiker
								,[Factuur dagen open]
						from backup_empire_dwh.dbo.[ITVF_check_crediteuren_purchase] (default,default)
				where [Factuur dagen open] > 30 and [Factuur dagen open] <= 60)

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

			select		 [Datum]				= cast(GETDATE() as date)
						,[Waarde]				= 1
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   format(Documentdatum, 'yyyy-MM-dd') + '; ' +
													[Document Type] + '; ' +
													[Documentnr.] + '; ' +
													Leveranciersnaam + '; ' +
													coalesce(format([Bedrag VAT], 'C', 'nl-nl'), 'Onbekend/NVT') + '; ' +
													coalesce(format(Factuurbedrag, 'C', 'nl-nl'), 'Onbekend/NVT') + '; ' +
													Gebruiker + '; ' +
													format([Factuur dagen open], 'D')
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, cast(getdate() as date), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
				group by det.fk_indicator_id;

			end

		--------------------------------------------------------------------------------------------------------
		-- 2616 Aantal openstaande crediteuren 61 - 90 dagen

		if @fk_indicator_id = 2616
			BEGIN
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			with
			[Details] as
				(
						select	 Documentdatum
								,[Document Type]
								,[Documentnr.]
								,Leveranciersnaam
								,[Bedrag VAT]
								,Factuurbedrag
								,Gebruiker
								,[Factuur dagen open]
						from backup_empire_dwh.dbo.[ITVF_check_crediteuren_purchase] (default,default)
				where [Factuur dagen open] > 60 and [Factuur dagen open] <= 90)

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

			select		 [Datum]				= cast(GETDATE() as date)
						,[Waarde]				= 1
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   format(Documentdatum, 'yyyy-MM-dd') + '; ' +
													[Document Type] + '; ' +
													[Documentnr.] + '; ' +
													Leveranciersnaam + '; ' +
													coalesce(format([Bedrag VAT], 'C', 'nl-nl'), 'Onbekend/NVT') + '; ' +
													coalesce(format(Factuurbedrag, 'C', 'nl-nl'), 'Onbekend/NVT') + '; ' +
													Gebruiker + '; ' +
													format([Factuur dagen open], 'D')
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, cast(getdate() as date), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
				group by det.fk_indicator_id;

			end

		--------------------------------------------------------------------------------------------------------
		-- 2619 Aantal openstaande crediteuren > 90 dagen

		if @fk_indicator_id = 2619
			BEGIN
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			with
			[Details] as
				(
						select	 Documentdatum
								,[Document Type]
								,[Documentnr.]
								,Leveranciersnaam
								,[Bedrag VAT]
								,Factuurbedrag
								,Gebruiker
								,[Factuur dagen open]
						from backup_empire_dwh.dbo.[ITVF_check_crediteuren_purchase] (default,default)
				where [Factuur dagen open] > 90)

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

			select		 [Datum]				= cast(GETDATE() as date)
						,[Waarde]				= 1
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   format(Documentdatum, 'yyyy-MM-dd') + '; ' +
													[Document Type] + '; ' +
													[Documentnr.] + '; ' +
													Leveranciersnaam + '; ' +
													coalesce(format([Bedrag VAT], 'C', 'nl-nl'), 'Onbekend/NVT') + '; ' +
													coalesce(format(Factuurbedrag, 'C', 'nl-nl'), 'Onbekend/NVT') + '; ' +
													Gebruiker + '; ' +
													format([Factuur dagen open], 'D')
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, cast(getdate() as date), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
				group by det.fk_indicator_id;

			END
		END

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
