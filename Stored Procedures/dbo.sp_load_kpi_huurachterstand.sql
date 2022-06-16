SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_kpi_huurachterstand](
  @peildatum date = '20190131'
)
as
/* #################################################################################################################

20200110 Rvg Op verzoek van Eric de Gier is een extra variant van de KPI toegevoegd, die nagenoeg identiek is aan de 
		 oorspronkelijke KPI, waarin alleen de minnelijke en wettelijke schikkingen niet worden meegeteld als achterstand
		 zodat de achterstandsberekening beter aansluit bij de wijze waarop andere corporaties de schterstand vaststellen.
		 Omdat de berekening voor 99.9% gelijk is aan de oorspronkelijke KPI laat ik de berekening parralel uitvoeren.
		 Gevolg daarvan is dat deze procedure nu twee KPI's bepaald in plaats van 1. 

exec staedion_dm.[dbo].[sp_load_kpi_huurachterstand] '20191231', 0
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
select * from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = 1500
select * from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = 1500


################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start =current_timestamp
		
		select @fk_indicator_id = 1500 -- min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%uurachterstand%zittende%huurder%'

		declare @sql nvarchar(1000) = 'exec [backup_empire_dwh].[dbo].[dsp_rs_voorziening_debiteuren] ''' + convert(varchar(10), @peildatum, 120) + ''', ' + convert(nvarchar(10), @fk_indicator_id)

		exec (@sql)
	
  -- Samenvatting opvoeren tbv dashboards
	delete from staedion_dm.dashboard.Realisatie where fk_indicator_id in (1500, 1505, 1506, 1507, 1508, 1509, 1510, 1515, 1516, 1517, 1518, 1519, 1527, 1528, 1529) and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into staedion_dm.dashboard.Realisatie (fk_indicator_id, Datum, Waarde, Laaddatum)
		select fk_indicator_id, Datum, sum(teller) / sum(noemer), max(Laaddatum)
		from staedion_dm.dashboard.RealisatieDetails 
		where fk_indicator_id in (@fk_indicator_id, @fk_indicator_id + 10) and datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		group by fk_indicator_id, Datum

	set		@finish = current_timestamp
	
  -- Voor sommige kpi's bewaren we de details wel
	if @LoggenDetails = 0
		begin 
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
		end 

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
