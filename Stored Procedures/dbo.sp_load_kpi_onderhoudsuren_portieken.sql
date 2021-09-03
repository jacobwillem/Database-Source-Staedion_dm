SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_load_kpi_onderhoudsuren_portieken](
  @peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_onderhoudsuren_portieken] '20200131'
exec staedion_dm.[dbo].[sp_load_kpi_onderhoudsuren_portieken] '20200229'
exec staedion_dm.[dbo].[sp_load_kpi_onderhoudsuren_portieken] '20200331'
exec staedion_dm.[dbo].[sp_load_kpi_onderhoudsuren_portieken] '20200430'
exec staedion_dm.[dbo].[sp_load_kpi_onderhoudsuren_portieken] '20200531'
exec staedion_dm.[dbo].[sp_load_kpi_onderhoudsuren_portieken] '20200630'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%derhoudsuren%portieken%uimten%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start =current_timestamp

		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%derhoudsuren%portieken%uimten%'

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

			INSERT INTO [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,fk_indicator_id
						,omschrijving  
						)

			SELECT Boekdatum, [Aantal uren], getdate(), @fk_indicator_id, omschrijving = 
								[Omschrijving onderhoudspost] + ' ; ' + 
								[Locatie] 
			from	staedion_dm.Onderhoud.OnderhoudsurenPortieken
			WHERE Boekdatum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		end 
		
  -- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		group by det.fk_indicator_id

	set	@finish = current_timestamp
	
 
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish

	set	@finish = current_timestamp
	
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
