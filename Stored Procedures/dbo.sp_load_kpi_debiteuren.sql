SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE PROCEDURE[dbo].[sp_load_kpi_debiteuren](
  @peildatum date = '20210630', @fk_indicator_id smallint = 2620
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_debiteuren] '20210630', @fk_indicator_id = 2620
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

		--------------------------------------------------------------------------------------------------------
		-- 2620 Aantal openstaande debiteuren 31 - 60 dagen

		if @fk_indicator_id = 2620
			BEGIN
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Details] as
				(
						select [Datum] = max(s.datum)
							  ,[Omschrijving] = concat(s.fk_klant_id, '; Huurachterstand: ',  format(max(s.klant_ha_achterstand), 'C', 'nl-nl'))
						from backup_empire_dwh.dbo.d_staedion_stand s
						join empire_Dwh.dbo.klant as k
						on k.id = s.fk_klant_id
						where s.datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
						and s.klant_ha_achterstand > 0
						and s.da_bedrijf = 'Staedion'
						and k.da_klantboekingsgroep = 'HUURDERS'
						and s.aantal_dagen_vanaf_ingang > 30
						and s.aantal_dagen_vanaf_ingang <= 60
						group by s.fk_klant_id)

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
						,[Waarde]				= 1
						,[Laaddatum]			= getdate()
						,[Omschrijving]			
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, MAX(Datum), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
				group by det.fk_indicator_id;
			END
		--------------------------------------------------------------------------------------------------------
		-- 2626 Aantal openstaande debiteuren 61 - 90 dagen

		if @fk_indicator_id = 2626
			BEGIN
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Details] as
				(
						select [Datum] = max(s.datum)
							  ,[Omschrijving] = concat(s.fk_klant_id, '; Huurachterstand: ',  format(max(s.klant_ha_achterstand), 'C', 'nl-nl'))
						from backup_empire_dwh.dbo.d_staedion_stand s
						join empire_Dwh.dbo.klant as k
						on k.id = s.fk_klant_id
						where s.datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
						and s.klant_ha_achterstand > 0
						and s.da_bedrijf = 'Staedion'
						and k.da_klantboekingsgroep = 'HUURDERS'
						and s.aantal_dagen_vanaf_ingang > 60
						and s.aantal_dagen_vanaf_ingang <= 90
						group by s.fk_klant_id)

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
						,[Waarde]				= 1
						,[Laaddatum]			= getdate()
						,[Omschrijving]			
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, MAX(Datum), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
				group by det.fk_indicator_id;
			end
		--------------------------------------------------------------------------------------------------------
		-- 2629 Aantal openstaande debiiteuren > 90 dagen

		IF @fk_indicator_id = 2629
			BEGIN
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
			[Details] as
				(
						select [Datum] = max(s.datum)
							  ,[Omschrijving] = concat(s.fk_klant_id, '; Huurachterstand: ',  format(max(s.klant_ha_achterstand), 'C', 'nl-nl'))
						from backup_empire_dwh.dbo.d_staedion_stand s
						join empire_Dwh.dbo.klant as k
						on k.id = s.fk_klant_id
						where s.datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
						and s.klant_ha_achterstand > 0
						and s.da_bedrijf = 'Staedion'
						and k.da_klantboekingsgroep = 'HUURDERS'
						and s.aantal_dagen_vanaf_ingang > 90
						group by s.fk_klant_id)

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
						,[Waarde]				= 1
						,[Laaddatum]			= getdate()
						,[Omschrijving]			
						,@fk_indicator_id
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, MAX(Datum), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
				group by det.fk_indicator_id;
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
