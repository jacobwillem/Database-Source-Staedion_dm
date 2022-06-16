SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


























CREATE PROCEDURE[dbo].[sp_load_kpi_personeelsinhuur](
  @peildatum date = '20220106'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_personeelsinhuur] '20220106'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures where Databaseobject like '%personeelsinhuur%' order by Begintijd desc

Voor toevoeging kpi 1836? fte realisatie gebruik SUM(fte_resources) ipv SUM(parttime_factor)

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime;
	declare @finish as datetime;
	declare @fk_indicator_id smallint;

	set	@start = current_timestamp;

	with cteFTE as(	select *
					from [A-PBI-PROD].[vault].[visma].[view_function_by_employee]
			       )

	,cteSFTE as(select	 year_number
						,month_number
						,reporting_date
						,emp_groupname
						,dep_costcenter
						,dep_costcentername
						,fun_functionid
						,functionname
						,cts_contracttypeindication_nl
						,org_level_2
						,org_level_3
						,[FTE ultimo] = SUM(parttime_factor)
				from cteFTE
				where	emp_groupname = 'externen'
				and		org_level_2 = 'Bestuur'
				and		reporting_date between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by year_number
						,month_number
						,reporting_date
						,emp_groupname
						,dep_costcenter
						,dep_costcentername
						,fun_functionid
						,functionname
						,cts_contracttypeindication_nl
						,org_level_2
						,org_level_3
				)

	select	 Waarde = cteSFTE.[FTE ultimo]
			,Omschrijving =   'Functie: '
							+ format(cteSFTE.fun_functionid, 'G') + ' - ' + cteSFTE.functionname
							+ '; '
							+ 'Onderbouwing: '
							+ cts_contracttypeindication_nl
							+ '; '
							+ 'Directie: '
							+ cteSFTE.org_level_3
							+ '; '
							+ 'Kostenplaats: '
							+ format(cteSFTE.dep_costcenter, 'G') + ' - ' + cteSFTE.dep_costcentername
			,Detail_01 = cteSFTE.org_level_3
			,Detail_02 = format(cteSFTE.dep_costcenter, 'G') + ' - ' + cteSFTE.dep_costcentername
			,Detail_03 = format(cteSFTE.fun_functionid, 'G') + ' - ' + cteSFTE.functionname
			,Detail_04 = cts_contracttypeindication_nl
	into #TempTable
	from cteSFTE

-----------------------------------------------------------------------------------------------------------
	-- 1835 Personeelsinhuur FTE (ultimo)

		set @fk_indicator_id = 1835;

			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														--,[Detail_05]
														--,[Detail_06]
														--,[Detail_07]
														--,[Detail_08]
														--,[Detail_09]
														--,[Detail_10]
														--,[eenheidnummer]
														--,[bouwbloknummer]
														--,[clusternummer]
														--,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														--,[leveranciernummer]
														--,[werknemernummer]
														--,[projectnummer]
														--,[verzoeknummer]
														--,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)
			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = @peildatum
					,[Laaddatum] = getdate()
					,[Waarde]
					--,[Teller]
					--,[Noemer]
					,[Omschrijving]
					,[Detail_01]
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					--,[Detail_05]
					--,[Detail_06]
					--,[Detail_07]
					--,[Detail_08]
					--,[Detail_09]
					--,[Detail_10]
					--,[eenheidnummer]
					--,[bouwbloknummer]
					--,[clusternummer]
					--,[klantnummer]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					--,[leveranciernummer]
					--,[werknemernummer]
					--,[projectnummer]
					--,[verzoeknummer]
					--,[ordernummer]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable;

			drop table #TempTable;

		set	@finish = current_timestamp;
	
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish;
				
END TRY

BEGIN CATCH

	set	@finish = current_timestamp;

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT	ERROR_PROCEDURE() 
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE();
END CATCH

GO
