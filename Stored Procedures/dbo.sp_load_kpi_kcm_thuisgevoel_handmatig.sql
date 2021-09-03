SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[sp_load_kpi_kcm_thuisgevoel_handmatig](
  @peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_kcm_thuisgevoel_handmatig] '20210131'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = 700 and year(Datum) = 2020
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = 700 and year(Datum) = 2020
select * from Dashboard.[Realisatie] where fk_indicator_id = 700 and year(Datum) = 2021
select * from Dashboard.[RealisatieDetails] where fk_indicator_id = 700 and year(Datum) = 2021

select min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%bewoners%voelen%thuis'
		
----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210201 JvdW: jaargang 2020 ongemoeid laten - vandaar extra conditie toegevoegd bij delete en insert
+ Naam aangepast (er werd geen id opgehaald)
20210607 PP: Clusternummer toegevoegd aan output
################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start =current_timestamp

		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) = 'Bewoners voelen zich thuis in de woning'

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
			-- JvdW 20210201
			and year(Datum) >= 2021
			;
			INSERT INTO [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,[fk_eenheid_id]
						,[Clusternummer]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			SELECT Datum, [Indicator Voelt zich thuis]
						, getdate(), convert(nvarchar(10),[Score thuisgevoel]), @fk_indicator_id, [sleutel eenheid], convert(nvarchar(7),[clusternr])
			-- select top 10  * 
			FROM	staedion_dm.[Klanttevredenheid].[Thuisgevoel_Handmatig]
			WHERE datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
			and year(Datum) >= 2021

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
		select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
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
