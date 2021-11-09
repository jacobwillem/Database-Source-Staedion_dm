SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  procedure [dbo].[sp_load_kpi_aantal_leegstaande_woningen](
  @peildatum date = null
)
as
/* #################################################################################################################
select * from empire_Dwh.dbo.tijd where isoweeknum = 202127
--exec staedion_dm.[dbo].[sp_load_kpi_aantal_leegstaande_woningen] '20210718' -- week 29
exec staedion_dm.[dbo].[sp_load_kpi_aantal_leegstaande_woningen] '20210711' -- week 27
exec staedion_dm.[dbo].[sp_load_kpi_aantal_leegstaande_woningen] '20210704' -- week 26
exec staedion_dm.[dbo].[sp_load_kpi_aantal_leegstaande_woningen] '20210627' -- week 25
exec staedion_dm.[dbo].[sp_load_kpi_aantal_leegstaande_woningen] '20210620' -- week 24

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures

declare @fk_indicator_id as smallint
select * from  [Dashboard].[Indicator] where omschrijving = 'Leegstand' 
select * from staedion_dm.Dashboard.[RealisatieDetails]  where fk_indicator_id = 150
select * from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = 150
delete from Dashboard.[Realisatie] where fk_indicator_id = 150
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = 150 
select * from staedion_dm.Dashboard.[RealisatieDetails] ORDER BY ID DESC


select	* 
from		staedion_dm.dashboard.indicator where id = 150

----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210817 MV: [Laaddatum] gevuld met getdate() ipv Peildatum
20210713 JvdW: Toegevoegd in overleg met Martijn
20211013 JvdW: wissen ging niet goed - moet obv DETAILS.datum en niet DETAILS.Laaddatum

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start =current_timestamp
		
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where omschrijving = 'Aantal leegstaande woningen'
		
		if @Peildatum is NULL
		set @Peildatum = (select datum from empire_Dwh.dbo.tijd where last_loading_day = 1)

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete 
			from	Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 
			and		datum in (select datum from empire_Dwh.dbo.tijd 
										where isoweeknum = (select isoweeknum from empire_Dwh.dbo.tijd where datum = @Peildatum)
										)
			-- JvdW 20210201
			and year(Datum) >= 2021
			;
			INSERT INTO [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]	
						)

			SELECT  Peildatum, 1, getdate(),[Eenheidnr + adres] + ' ; '+ verhuurteam + ' ; '+ [soort leegstand] + ' ; miv: ' + convert(nvarchar(20),[Datum ingang reden leegstand],105) , @fk_indicator_id
			-- select *
			FROM	 Leegstand.fn_LeegstandAantallen (@Peildatum)

		end 
		
  -- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
	-- JvdW 20210201
	and year(Datum) >= 2021
	;
	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, sum([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		-- JvdW 20210201
		and year(Datum) >= 2021
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
