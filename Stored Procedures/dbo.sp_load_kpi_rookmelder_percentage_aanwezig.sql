SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE[dbo].[sp_load_kpi_rookmelder_percentage_aanwezig](
  @peildatum date = '20210930'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_rookmelder_percentage_aanwezig] '20211005'
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


-----------------------------------------------------------------------------------------------------------
	-- 308 Percentage woningen met rookmelders
	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN
		select @fk_indicator_id = 308
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with

			cteFIX as
				(		select	 *
						from [empire_data].[dbo].[Staedion$Fixture]
						where [Fixture Type Code] = '651110'
				 ),				
			[Details] as
				(
						SELECT	 Datum = @peildatum
							    ,Waarde = IIF(MEL.[Install_ Date] is not null, 1, 0)
								,Laaddatum = getdate()
								,Omschrijving = OGE.Nr_ + ' ; ' + 'Installatiedatum: ' + IIF(cast(MEL.[Install_ Date] as date) <> cast('17530101' as date), format(cast(MEL.[Install_ Date] as date), 'yyyy-MM-dd'), 'ONBEKEND/NVT') + ' ; ' + 'Merk: ' + IIF(MEL.Brand <> '', MEL.Brand, 'ONBEKEND/NVT') + ' ; ' + 'Type: ' + IIF(MEL.[Type] <> '', MEL.[Type], 'ONBEKEND/NVT')
								,Eenheidnummer = OGE.Nr_
								,Clusternummer = OGE.[PMC Nr_]
								FROM empire_data.dbo.[Staedion$OGE] AS OGE
								left outer join cteFIX AS MEL
								ON OGE.Nr_ = MEL.No_
								JOIN empire_Data.dbo.[Staedion$type] AS TT
								ON TT.[Code] = OGE.[Type] AND TT.Soort = 0
								WHERE (TT.[Analysis Group Code] = 'WON ZELF' or TT.[Analysis Group Code] = 'WON ONZ')
								AND OGE.[Begin exploitatie] <> '17530101'
								AND OGE.[Begin exploitatie] <= @peildatum
								AND (OGE.[Einde exploitatie] >= @peildatum
								OR OGE.[Einde exploitatie] = '17530101')
				)

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
						,[Waarde]				
						,[Laaddatum]			
						,[Omschrijving]
						,@fk_indicator_id 
						,[Clusternummer]
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
		END
-----------------------------------------------------------------------------------------------------------

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
