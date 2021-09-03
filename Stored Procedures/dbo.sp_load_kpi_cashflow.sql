SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create PROCEDURE[dbo].[sp_load_kpi_cashflow](
  @peildatum date = '20210715'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_npo_doorlooptijd] '20210131'
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

-----------------------------------------------------------------------------------------------------------
	-- 2630, 2650, 2670, 2690 Dagelijks bestuur cashflow
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id in (2630, 2650, 2670, 2690) and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
								
			[Details] as
				(
						select
								 [Datum] = CFL.[Posting Date]
								,[Waarde] = convert(float, abs(sum(CFL.[Allocated Amount])))
								,[fk_indicator_id] = case CAT.[Code]
													when '1.01.1' then 2630
													when '1.08' then 2670
													when '1.09' then 2690
													when '2.05 A' then 2650
													when '2.05 B' then 2650
													when '2.14 A' then 2650
													when '2.14 B' then 2650
												end 
								,[Omschrijving] = case CAT.[Code]
													when '1.01.1' then 'Huurinkomsten' 
													when '1.08' then 'Onderhoud' 
													when '1.09' then 'Bedrijfslasten'
													when '2.05 A' then 'Investeringen'
													when '2.05 B' then 'Investeringen'
													when '2.14 A' then 'Investeringen'
													when '2.14 B' then 'Investeringen'
												end
								,[Laaddatum] = getdate()
								from empire_data.dbo.Staedion$Realized_Cash_Flow_Line as CFL
								left outer join empire_data.dbo.Staedion$Cash_Flow_Category as CAT on CFL.[CF Category Code] = CAT.[Code]
								where CFL.[Posting Date] between dateadd(m, datediff(m, 0, @peildatum), 0) and eomonth(@peildatum)
								and CAT.[Code] in (
									'1.01.1'
									, -- Huurinkomsten
									'1.08'
									, -- Onderhoudsuitgaven
									'1.09'
									, -- Overige bedrijfsuitgaven
									'2.05 A'
									,-- (Des)Investeringsontvangsten overig DAEB
									'2.05 B'
									,-- (Des)Investeringsontvangsten overig Niet-DAEB
									'2.14 A'
									,-- Investeringen overig DAEB
									'2.14 B'
									-- Investeringen overig Niet-DAEB
								)
								group by CFL.[Posting Date], CAT.[Code])

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
						,[Waarde]	
						,[Laaddatum]	
						,[Omschrijving]		
						,fk_indicator_id 
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id in (2630, 2650, 2670, 2690) and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, @peildatum, sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id in (2630, 2650, 2670, 2690) and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;


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
