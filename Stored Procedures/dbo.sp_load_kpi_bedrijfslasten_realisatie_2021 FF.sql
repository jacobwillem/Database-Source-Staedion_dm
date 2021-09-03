SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE[dbo].[sp_load_kpi_bedrijfslasten_realisatie_2021 FF](
  @peildatum date = '20210131'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_bedrijfslasten_realisatie] '20191231'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%bedrijfslasten%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
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
		declare @LoggenDetails as bit = 1
		declare @aanduiding as nvarchar(8)

		set	@start = current_timestamp
		select @nr = count(id) from [empire_staedion_data].[dbo].[Bedrijfslasten schema categorie]
		select @fk_indicator_id_min = min(id), @fk_indicator_id_max = (min(id) + @nr) from [Dashboard].[Indicator] where lower([Omschrijving]) like 'bedrijfslasten%'
		select @aanduiding = aanduiding from [Dashboard].[Indicator] where id = @fk_indicator_id_min

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			--delete from Dashboard.[RealisatieDetails] where fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

			;with
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
					where		 left([Rekeningnummer], 2) in ('A4', 'A5', 'A8')
					and			 [Rekeningnummer] not in ('A814945', 'A830945', 'A812945', 'A860945', 'A870945', 'A815945', 'A850945')
					and			 [Boekdatum] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
					group by 	 [Rekeningnummer]
								,[Rekeningnaam]
								,[Rekening]
								,[Kostenplaatscode]
								,[Kostenplaatsnaam]
								,[Kostenplaats]
				)
				select * into #grootboek from Grootboek
				;

				with [A4] as
				(		
					select		 [Rekeningnummer]				= 'A814945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten VH'		-- Verhuur
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.2763 + 
																	sum(iif([Rekeningnummer] in ('A515100'),								[Bedrag], 0)) * 0.1000 +	-- A515100 = Dekking doorberekende uren verhuur (herstructurering)
																	sum(iif([Rekeningnummer] in ('A560400'),								[Bedrag], 0))				-- A560400 = Dekking incasso kosten
																	))
					from		 #grootboek as [Grootboek]

					union select [Rekeningnummer]				= 'A830945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten VG VK'	-- Verkoop Vastgoed
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, sum([Bedrag]) * 0.0036)
					from		  #grootboek as [Grootboek]
					where		 [Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999'

					union select [Rekeningnummer]				= 'A812945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten SC'		-- Service abb
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.0341 + 
																	sum(iif([Rekeningnummer] in ('A515220'),								[Bedrag], 0)) * 0.2840		-- A515220 = Dekking direct loon
																	))
					from		  #grootboek as [Grootboek]

					union select [Rekeningnummer]				= 'A860945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten OO'		-- Overig
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.0474
																	))
					from		  #grootboek as [Grootboek]

					union select [Rekeningnummer]				= 'A870945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten LF'		-- Leefbaarheid
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.1726 + 
																	sum(iif([Rekeningnummer] in ('A515100'),								[Bedrag], 0)) * 0.2500 + 	-- A515100 = Dekking doorberekende uren verhuur (herstructurering)
																	sum(iif([Rekeningnummer] in ('A570200'),								[Bedrag], 0)) * 0.0000		-- A570200 = Dekking doorberekende uren LF
																	))
					from		  #grootboek as [Grootboek]

					union select [Rekeningnummer]				= 'A815945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten OH'		-- Onderhoud
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.4375 + 
																	sum(iif([Rekeningnummer] in ('A515100'),								[Bedrag], 0)) * 0.6500 +	-- A515100 = Dekking doorberekende uren verhuur (herstructurering) 
																	sum(iif([Rekeningnummer] in ('A515220'),								[Bedrag], 0)) * 0.7160 +	-- A515220 = Dekking direct loon
																	sum(iif([Rekeningnummer] in ('A560200'),								[Bedrag], 0))				-- A560200 = Dekking administratiekosten brandschade
																	))
					from		  #grootboek as [Grootboek]

					union select [Rekeningnummer]				= 'A850945'
								,[Rekeningnaam]					= 'Toegerekende organisatiekosten OV ACT'	-- Overige activiteiten
								,[Datum]						= @peildatum
								,[Bedrag]						= convert(float, (
																	sum(iif([Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999',	[Bedrag], 0)) * 0.0286 + 
																	sum(iif([Rekeningnummer] in ('A560300'),								[Bedrag], 0))				-- A560300 = Dekking doorberekende uren VVE
																	))
					from		  #grootboek as [Grootboek]
				)
				select  * into #A4 from [A4]
				;
				with [Details] as
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
									from			 #Grootboek

									union select	 [Rekeningnummer]
													,[Rekeningnaam]
													,[Rekening] = [Rekeningnummer] + ' ' + [Rekeningnaam]	
													,[Kostenplaatscode] = null
													,[Kostenplaatsnaam] = null
													,[Kostenplaats] = null
													,[Datum]
													,[Bedrag]
									from			 #A4
									) g	on r.Rekeningnummer = g.Rekeningnummer
				) 
				select * into #Details from [Details]
				;
				with [Weging] as
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
				)
				select * into #Weging from [weging]
				;
				with [VHE] as
				(
					select		[vhe_aantal] = cast(round(sum([vhe_gewogen]),0) as int) from #Weging
				)
				select * into #vhe from VHE
				;
				with [Bedrijfslasten] as
				(
					select		 [Nr]
								,[Categorie]
								,[Rekening]
								,[Datum]
								--,[Bedrag] = cast(sum([Bedrag]) as float)
								,[Bedrag per VHE] = cast((sum([Bedrag])/[vhe_aantal]) as float)
					from		 #Details as [Details]
					inner join	 #VHE as [vhe] on 1 = 1
					--where Rekeningnummer = 'A812945'
					group by [Nr], [Categorie], [Rekening], [Datum], [vhe_aantal]
				)
				select * into #Bedrijfslasten from Bedrijfslasten
				;

			--insert into [Dashboard].[RealisatieDetails]
			--			([Datum]
			--			,[Waarde]
			--			,[Laaddatum]
			--			,[Omschrijving]
			--			,fk_indicator_id
			--			--,[fk_eenheid_id]
			--			--,[fk_contract_id]
			--			--,[fk_klant_id]
			--			--,[Teller]
			--			--,[Noemer]
			--			)

			select		 [Datum] 
						,[Waarde]				= sum([Bedrag per VHE])
						,[Laaddatum]			= getdate()
						,[Omschrijving]			= @aanduiding + cast([Nr] as nvarchar) + '. ' + [Categorie]
						,@fk_indicator_id_min 
			from		 #Bedrijfslasten as [Bedrijfslasten]
			group by	 [Nr], [Categorie], [Datum]

			union

			select		 [Datum] 
						,[Waarde]				= sum([Bedrag per VHE])
						,[Laaddatum]			= getdate()
						,[Omschrijving]			= [Rekening]
						,@fk_indicator_id_min + [Nr]
			from		 #Bedrijfslasten as [Bedrijfslasten]
			group by	 [Nr], [Categorie], [Rekening], [Datum];
			
			--select * from [Weging];
			--select * from [VHE];
			--select * from [Details] order by [Nr];
			--select [Bedrag per VHE] = cast(sum([Bedrag per VHE]) as float) from [Bedrijfslasten]; --, [Bedrag per VHE extrapolatie] = cast((sum([Bedrag per VHE]) * 12) as float)
			--select [Bedrag totaal] = sum([Bedrag]) from [Grootboek] where [Rekeningnummer] like 'A4%' and [Rekeningnummer] <> 'A499999';
		end 
		
  -- Samenvatting opvoeren tbv dashboards
	--delete from Dashboard.[Realisatie] where fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	--insert into Dashboard.[Realisatie] (
	--	fk_indicator_id,
	--	Datum,
	--	Waarde,
	--	Laaddatum
	--	)
		select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id between @fk_indicator_id_min and @fk_indicator_id_max and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
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
