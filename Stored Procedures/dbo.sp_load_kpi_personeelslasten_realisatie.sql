SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE PROCEDURE[dbo].[sp_load_kpi_personeelslasten_realisatie](
  @peildatum date = '20210131'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_personeelslasten_realisatie] '20210331'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%personeelslasten%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 

1900	Personeelslasten gebaseerd op (1700 Bedrijfslaten volgens Aedes Benchmark (per VHE))


################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @nr as smallint
		declare @fk_indicator_id_min as smallint
		declare @fk_indicator_id_max as smallint
		declare @laaddatum as date
		declare @LoggenDetails as bit = 1
		declare @aanduiding as nvarchar(8)

		set	@start = current_timestamp
		select @nr = 4
		select @fk_indicator_id_min = min(id), @fk_indicator_id_max = (min(id) + @nr) from [Dashboard].[Indicator] where lower([Omschrijving]) like 'personeelslasten%'

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

			;with
			[Indicator] as
				(
					select		 j.fk_indicator_id
								,j.Aanduiding
								,i.Omschrijving
					from [Dashboard].[Indicator] as i
					inner join [Dashboard].[Jaargang] as j on i.id = j.fk_indicator_id and j.Jaargang = YEAR(@peildatum)
					where j.fk_indicator_id between @fk_indicator_id_min + 1 and @fk_indicator_id_max
				),

			[Grootboek] as 
				(
					select		 [Rekeningnummer]
								,[Rekeningnaam]
								,[Rekening]
								,[Kostenplaatscode]
								,[Kostenplaatsnaam]
								,[Kostenplaats]
								,[Datum]						= @peildatum
								,[Bedrag]						= sum([Bedrag])
					from		 [staedion_dm].[Financieel].[Grootboek realisatie] 
					where		 [Rekeningnummer]	IN ( 'A411100'
														,'A411200'
														,'A411500'
														,'A412100'
														,'A412150'
														,'A412200'
														,'A412250'
														,'A412300'
														,'A412350'
														,'A412400'
														,'A412450'
														,'A412500'
														,'A412550'
														,'A412600'
														,'A413100'
														,'A413200'
														,'A413300'
														,'A413610'
														,'A416100'
														,'A416200'
														,'A416300'
														,'A416400')
					and			 [Boekdatum] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
					group by 	 [Rekeningnummer]
								,[Rekeningnaam]
								,[Rekening]
								,[Kostenplaatscode]
								,[Kostenplaatsnaam]
								,[Kostenplaats]
				),

			[Details] as
				(
					select			 i.fk_indicator_id
									,i.Aanduiding
									,i.Omschrijving
									,g.[Rekeningnummer]
									,g.[Rekeningnaam]
									,g.[Rekening]
									,g.[Kostenplaatscode]
									,g.[Kostenplaatsnaam]
									,g.[Kostenplaats]
									,g.[Datum]
									,g.[Bedrag]		
					from [Grootboek] as g
					cross join [Indicator] as i
					where   (g.[Rekeningnummer] IN ( 'A411100'
													,'A411200'
													,'A411500') AND i.fk_indicator_id = 1901) OR
							(g.[Rekeningnummer] IN ( 'A412100'
													,'A412150'
													,'A412200'
													,'A412250'
													,'A412300'
													,'A412350'
													,'A412400'
													,'A412450'
													,'A412500'
													,'A412550'
													,'A412600') AND i.fk_indicator_id = 1902) OR
							(g.[Rekeningnummer] IN ( 'A413100'
													,'A413200'
													,'A413300'
													,'A413610') AND i.fk_indicator_id = 1903) OR
							(g.[Rekeningnummer] IN ( 'A416100'
													,'A416200'
													,'A416300'
													,'A416400') AND i.fk_indicator_id = 1904) 
				)

			insert into [Dashboard].[RealisatieDetails]
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

			select		 [Datum] 
						,[Waarde]				= sum([Bedrag])
						,[Laaddatum]			= getdate()
						,[Omschrijving]			= [Kostenplaatscode] + ' ; ' + [Kostenplaatsnaam]
						,@fk_indicator_id_min 
			from		 [Details]
			group by	 [Kostenplaatscode], [Kostenplaatsnaam], [Datum]

			union

			select		 [Datum] 
						,[Waarde]				= sum([Bedrag])
						,[Laaddatum]			= getdate()
						,[Omschrijving]			= [Kostenplaatscode] + ' ; ' + [Kostenplaatsnaam] + ' ; ' + [Rekeningnummer] + ' ; ' + [Rekeningnaam]
						,fk_indicator_id
			from		 [Details]
			group by	 fk_indicator_id, [Kostenplaatscode], [Kostenplaatsnaam], [Rekeningnummer], [Rekeningnaam], [Datum];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id

		end 

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
