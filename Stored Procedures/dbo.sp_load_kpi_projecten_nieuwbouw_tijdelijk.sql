SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi_projecten_nieuwbouw_tijdelijk](
  @peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_projecten_nieuwbouw_tijdelijk] '20201130'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures

declare @fk_indicator_id as smallint
select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%start%nieuwbouw%'

select * from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and year(Datum) = 2020 and month(Datum) = 11
select * from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and year(Datum) = 2020 and month(Datum) = 11
 
select max(Datum),sum(waarde), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and year(Datum) = 2020 and month(Datum) = 1
select max(Datum), sum(waarde), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and year(Datum) = 2020  and month(Datum) = 1
select * from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and year(Datum) = 2020 and month(Datum) = 11
select * from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and year(Datum) = 2020 and month(Datum) = 11

20201221 JvdW 
Naar aanleiding van nieuwe excelsheet andere opzet gemaakt: inlezen van excel sheet in staedion_dm.Projecten.InvulsheetOpleveringEnStart
Vervolgens mbv 1 functie in plaats van huidige view: 
	SELECT Datum, [Aantal start gerealiseerd], getdate(),  [Project]-- , @fk_indicator_id
	FROM	staedion_dm.[Projecten].[fn_OpleveringStart_tijdelijk] (@Peildatum,  'Nieuwbouw')
	where [Aantal start gerealiseerd] <> 0
	


################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start = current_timestamp
		
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%start%nieuwbouw%'

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

			INSERT INTO [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			--SELECT Datum, [Aantal start gerealiseerd], getdate(),  [Project], @fk_indicator_id
			--FROM	staedion_dm.[Projecten].[OpleveringEnStart_Tijdelijk]
			--WHERE [Soort Project] = 'Nieuwbouw' and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
			SELECT Datum, [Aantal start gerealiseerd], getdate(),  [Project] , @fk_indicator_id
			FROM	staedion_dm.[Projecten].[fn_OpleveringStart_tijdelijk] (@Peildatum,  'Nieuwbouw')
			where [Aantal start gerealiseerd] <> 0
			;
			
--SELECT [Soort Project]
--       ,[KPI Start bouw] = sum([KPI Start bouw])
--       ,[KPI Oplevering bouw] = sum([KPI Oplevering bouw])
--       ,[Aantal start gerealiseerd] = sum([Aantal start gerealiseerd])
--       ,[Aantal oplevering gerealiseerd] = sum([Aantal oplevering gerealiseerd])
---- select *
--FROM staedion_dm.[Projecten].[OpleveringEnStart_Tijdelijk]
--WHERE year([Datum]) = 2020
--       AND month([Datum]) = 1
--GROUP BY [Soort Project]

		end 
		
	-- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, sum([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and 
		det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		group by det.fk_indicator_id

	set		@finish = current_timestamp
	
 
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish

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
