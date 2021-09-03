SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE procedure [dbo].[sp_load_kpi_bedrijfslasten_prognose_2020](
  @peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_bedrijfslasten] '20191231'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%bedrijfslasten%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Bedrag] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Bedrag] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 

1700	Bedrijfslasten volgens Aedes Benchmark (per VHE)


################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @nr as smallint
		declare @fk_indicator_id_min as smallint
		declare @fk_indicator_id_max as smallint
		declare @laaddatum as date
		declare @LoggenDetails bit = 1
		declare @aanduiding as nvarchar(8)
		declare @budget as char(12)

		set	@start = current_timestamp
		select @nr = count(id) from [empire_staedion_data].[dbo].[Bedrijfslasten schema categorie]
		select @fk_indicator_id_min = min(id), @fk_indicator_id_max = (min(id) + @nr) from [Dashboard].[Indicator] where lower([Omschrijving]) like 'bedrijfslasten%'
		select @aanduiding = aanduiding from [Dashboard].[Indicator] where id = @fk_indicator_id_min
		select @budget = 'BEGR ' + format(@peildatum, 'yy_MM')

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[Prognose] where fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and datum >= dateadd(d, 1-day(@peildatum), @peildatum)

			;with
			[Grootboek] as 
				(
					select		 [Rekeningnummer]
								,[Rekeningnaam]
								,[Rekening]
								,[Kostenplaatscode]
								,[Kostenplaatsnaam]
								,[Kostenplaats]
								,[Datum]						--= @peildatum
								,[Bedrag]						= sum([Bedrag])
					from		 [staedion_dm].[Financieel].[Grootboek budget] 
					where		 left([Rekeningnummer], 2) in ('A4', 'A5', 'A8')
					and			 [Rekeningnummer] not in ('A814945', 'A830945', 'A812945', 'A860945', 'A870945', 'A815945')
					--and			 [Datum] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
					and			 [Budget] = @budget
					group by 	 [Rekeningnummer]
								,[Rekeningnaam]
								,[Rekening]
								,[Kostenplaatscode]
								,[Kostenplaatsnaam]
								,[Kostenplaats]
								,[Datum]
				),

			[A4] as
				(		
					select		 [Rekeningnummer]				= 'A814945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten VH'		-- Verhuur
								,[Datum]						--= @peildatum
								--,[Bedrag]						= convert(float, sum([Bedrag]) * 0.5465)
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.5465 + 
																	sum(iif([Rekeningnummer] in ('A570200'),								[Bedrag], 0))
																	))
					from		 [Grootboek]
					--where		 [Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999'
					group by	 [Datum]

					union select [Rekeningnummer]				= 'A830945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten VG VK'	-- Verkoop Vastgoed
								,[Datum]						--= @peildatum
								,[Bedrag]						= convert(float, sum([Bedrag]) * 0.0071)
					from		 [Grootboek]
					where		 [Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999'
					group by	 [Datum]

					union select [Rekeningnummer]				= 'A812945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten SC'		-- Service abb
								,[Datum]						--= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.0397 + 
																	sum(iif([Rekeningnummer] in ('A515220'),								[Bedrag], 0)) * 0.3500
																	))
					from		 [Grootboek]
					group by	 [Datum]

					union select [Rekeningnummer]				= 'A860945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten OO'		-- Overig
								,[Datum]						--= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.0327 + 
																	sum(iif([Rekeningnummer] in ('A560200', 'A560300', 'A560400'),			[Bedrag], 0))
																	))
					from		 [Grootboek]
					group by	 [Datum]

					union select [Rekeningnummer]				= 'A870945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten LF'		-- Leefbaarheid
								,[Datum]						--= @peildatum
								,[Bedrag]						= convert(float, sum([Bedrag]) * 0.0509)
					from		 [Grootboek]
					where		 [Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999'
					group by	 [Datum]

					union select [Rekeningnummer]				= 'A815945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten OH'		-- Onderhoud
								,[Datum]						--= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.3232 + 
																	sum(iif([Rekeningnummer] in ('A515220'),								[Bedrag], 0))
																	))
					from		 [Grootboek]
					group by	 [Datum]
				),

			[Details] as
				(
					select			 [Nr] = c.id
									,c.[Categorie]
									,g.[Rekeningnummer]
									,g.[Rekeningnaam]
									,g.[Rekening]
									,g.[Kostenplaatscode]
									,g.[Kostenplaatsnaam]
									,g.[Kostenplaats]
									,g.[Datum]
									,g.[Bedrag]	
					from			[empire_staedion_data].[dbo].[Bedrijfslasten schema categorie] c
					inner join		[empire_staedion_data].[dbo].[Bedrijfslasten schema rekening] r on r.fk_categorie_id = c.id
					inner join		(
									select			 [Rekeningnummer]
													,[Rekeningnaam]
													,[Rekening]	
													,[Kostenplaatscode]
													,[Kostenplaatsnaam]
													,[Kostenplaats]
													,[Datum]
													,[Bedrag]
									from			 [Grootboek]

									union select	 [Rekeningnummer]
													,[Rekeningnaam]
													,[Rekening] = [Rekeningnummer] + ' ' + [Rekeningnaam]	
													,[Kostenplaatscode] = null
													,[Kostenplaatsnaam] = null
													,[Kostenplaats] = null
													,[Datum]
													,[Bedrag]
									from			 [A4]
									) g	on r.Rekeningnummer = g.Rekeningnummer
				),

			[Weging] as
				(
					/*
					BEREKENING WEGING:
					De vhe’s zijn gewogen: huurwoningen en onzelfstandige wooneenheden worden voor 1,0 meegewogen, evenals
					winkels en bedrijfsruimtes boven de liberalisatiegrens. Bedrijven en winkels onder de liberalisatiegrens worden voor
					2,0 meegewogen en garages en overig bezit voor 0,2

					BRON: https://dkvwg750av2j6.cloudfront.net/m/2757c7ba6d472480/original/Rapportage-Aedes-benchmark-2016-Van-inzicht-en-vergelijken-naar-verder-verbeteren.pdf, blz 32.
					*/

					select		 [corpodata_type]					= t.[Analysis Group Code]
								,[vhe_aantal]						= count(distinct o.[Nr_])
								,[weging]							= case
																		when t.[Analysis Group Code] in ('WON ZELF', 'WON ONZ', 'BOG') then 1.0
																		else 0.2
																		end
								,[vhe_gewogen]						= count(distinct o.[Nr_]) * 
																		case
																		when t.[Analysis Group Code] in ('WON ZELF', 'WON ONZ', 'BOG') then 1.0
																		else 0.2
																		end
					from		empire_data.dbo.vw_lt_mg_oge o
					inner join	empire_data.dbo.staedion$type t on o.[Type] = t.[Code]
					where		(o.[Einde exploitatie]  = '1753-01-01' or  o.[Einde exploitatie]  > @peildatum)
					and			(o.[Begin exploitatie] <> '1753-01-01' and o.[Begin exploitatie] <= @peildatum)
					and			o.[Common Area] = 0 and o.mg_bedrijf = 'Staedion'
					and			o.[Type] not in ('ANT', 'SCO')
					and			t.[Analysis Group Code] not in ('NVT')
					and			left(o.Nr_, 4) = 'OGEH'
					group by	t.[Analysis Group Code]
				),

			[VHE] as
				(
					select		[vhe_aantal] = cast(round(sum([vhe_gewogen]),0) as int) from Weging
				),

			[Bedrijfslasten] as
				(
					select		 [Nr]
								,[Categorie]
								,[Rekening]
								,[Datum]
								--,[Bedrag] = cast(sum([Bedrag]) as float)
								,[Bedrag per VHE] = cast((sum([Bedrag])/[vhe_aantal]) as float)
					from		 [Details]
					inner join	 [VHE] on 1 = 1
					--where Datum >= dateadd(d, 1-day(@peildatum), @peildatum)
					group by [Nr], [Categorie], [Rekening], [Datum], [vhe_aantal]
				)

			insert into [Dashboard].[Prognose]
						([fk_indicator_id]
						,[Datum]
						,[Waarde]
						,[Laaddatum]
						--,[Omschrijving]
						)
					
			select		 @fk_indicator_id_min
						,[Datum]				= format(dateadd(month, datediff(month, 0, @peildatum), 0), 'yyyy-MM-dd')
						,[Waarde]				= sum([Bedrag per VHE])
						,[Laaddatum]			= getdate()
						--,[Omschrijving]			= @aanduiding + cast([Nr] as nvarchar) + '. ' + [Categorie]
			from		 [Bedrijfslasten]

			
			union

			select		 @fk_indicator_id_min + [Nr]
						,[Datum]				= format(dateadd(month, datediff(month, 0, @peildatum), 0), 'yyyy-MM-dd')
						,[Waarde]				= sum([Bedrag per VHE])
						,[Laaddatum]			= getdate()
						--,[Omschrijving]			= [Rekening]
			from		 [Bedrijfslasten]
			group by	 [Nr], [Categorie];
			

			--select * from [Weging];
			--select * from [VHE];
			--select * from [Details] order by [Nr];
			--select [Bedrag per VHE] = cast(sum([Bedrag per VHE]) as float) from [Bedrijfslasten]; --, [Bedrag per VHE extrapolatie] = cast((sum([Bedrag per VHE]) * 12) as float)
			--select [Bedrag totaal] = sum([Bedrag]) from [Grootboek] where [Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999';
		end 
		
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
