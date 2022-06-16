SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO























CREATE PROCEDURE[dbo].[sp_load_kpi_verzuimpercentage](
  @peildatum date = '20210930'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_verzuimpercentage] '20210930'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures where Databaseobject like '%verzuimpercentage%' order by Begintijd desc

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime;
	declare @finish as datetime;
	declare @fk_indicator_id smallint;
	declare @minimumFTE int;

	set @minimumFTE = 10; -- minimale groepsgrootte om te voorkomen dat gegevens tot medewerkers te herleiden zijn
	set	@start = current_timestamp;

	with cte as(
	select *
	from [A-PBI-PROD].[vault].[visma].[view_sickness_by_employee]
	)
	,cte8 as(
	SELECT			 [Teller] = SUM(sic_hours_ill)
					,[Noemer] = SUM(normal_hours)
					,[Detail_01] = SUM(fte_resources)
					,[Detail_02] = org_level_2
					,[Detail_03] = org_level_3
					,[Detail_04] = org_level_4
					,[Detail_05] = org_level_5
					,[Detail_06] = org_level_6
					,[Detail_07] = org_level_7
					,[Detail_08] = iif(SUM(fte_resources) >= @minimumFTE, org_level_8, 'Geanonimiseerd')
					,[Detail_09] = null
					,[Detail_10] = null										
			from cte
			where	emp_groupname = 'werknemers'
			and		org_level_2 = 'Bestuur'
			and		cts_type IN ('Onbepaalde duur', 'Tijdelijk contract') -- alle werknemers met contract voor (on)bepaalde tijd in de formatiegroepen vast, tijdelijk en +10	
			and		reporting_date between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
			GROUP BY org_level_2
					,org_level_3
					,org_level_4
					,org_level_5
					,org_level_6
					,org_level_7
					,org_level_8
			)
	,cte7 as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					,[Detail_05]
					,[Detail_06]
					,[Detail_07] = iif(SUM(Detail_01) >= @minimumFTE, Detail_07, 'Geanonimiseerd')
					,[Detail_08]
					,[Detail_09]
					,[Detail_10]									
			from cte8
			GROUP BY Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
					,Detail_10
			)
	,cte6 as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					,[Detail_05]
					,[Detail_06] = iif(SUM(Detail_01) >= @minimumFTE, Detail_06, 'Geanonimiseerd')
					,[Detail_07] 
					,[Detail_08]
					,[Detail_09]
					,[Detail_10]									
			from cte7
			GROUP BY Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
					,Detail_10
			)
	,cte5 as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					,[Detail_05] = iif(SUM(Detail_01) >= @minimumFTE, Detail_05, 'Geanonimiseerd')
					,[Detail_06]
					,[Detail_07] 
					,[Detail_08]
					,[Detail_09]
					,[Detail_10]									
			from cte6
			GROUP BY Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
					,Detail_10
			)
	,cte4 as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02]
					,[Detail_03]
					,[Detail_04] = iif(SUM(Detail_01) >= @minimumFTE, Detail_04, 'Geanonimiseerd')
					,[Detail_05]
					,[Detail_06]
					,[Detail_07] 
					,[Detail_08]
					,[Detail_09]
					,[Detail_10] = ROW_NUMBER() over (PARTITION by [Detail_03] order by SUM(Detail_01))									
			from cte5
			GROUP BY Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
					,Detail_10
			)
	,cte3 as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02]
					,[Detail_03] = iif(SUM(Detail_01) >= @minimumFTE, Detail_03, 'Geanonimiseerd')
					,[Detail_04] = iif(ROW_NUMBER() over (PARTITION by [Detail_03] order by MIN(Detail_10))	= 2, 'Geanonimiseerd', [Detail_04])
					,[Detail_05] = iif(ROW_NUMBER() over (PARTITION by [Detail_03] order by MIN(Detail_10))	= 2, 'Geanonimiseerd', [Detail_05])
					,[Detail_06] = iif(ROW_NUMBER() over (PARTITION by [Detail_03] order by MIN(Detail_10))	= 2, 'Geanonimiseerd', [Detail_06])
					,[Detail_07] = iif(ROW_NUMBER() over (PARTITION by [Detail_03] order by MIN(Detail_10))	= 2, 'Geanonimiseerd', [Detail_07])
					,[Detail_08] = iif(ROW_NUMBER() over (PARTITION by [Detail_03] order by MIN(Detail_10))	= 2, 'Geanonimiseerd', [Detail_08])
					,[Detail_09]
					,[Detail_10] = ROW_NUMBER() over (PARTITION by [Detail_03] order by MIN(Detail_10))							
			from cte4
			GROUP BY Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
			)
	,cte3a as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					,[Detail_05] 
					,[Detail_06]
					,[Detail_07]
					,[Detail_08]
					,[Detail_09]
					,[Detail_10] = MIN(Detail_10)						
			from cte3
			GROUP BY Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
			)
	,cte2 as(
	SELECT			 [Teller] = SUM(Teller)
					,[Noemer] = SUM(Noemer)
					,[Detail_01] = SUM(Detail_01)
					,[Detail_02] = MAX(Detail_02)
					,[Detail_03] = IIF(Detail_03 in ('Bestuur', 'Geanonimiseerd'), 'Bestuur (incl stafdiensten)', Detail_03)
					,[Detail_04]
					,[Detail_05]
					,[Detail_06]
					,[Detail_07] 
					,[Detail_08]
					,[Detail_09]
					,[Detail_10] = ROW_NUMBER() over (order by SUM(Detail_01) desc)							
			from cte3a
			GROUP BY IIF(Detail_03 in ('Bestuur', 'Geanonimiseerd'), 'Bestuur (incl stafdiensten)', Detail_03)
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
			)
			select		 [Datum] = @peildatum
						,[Teller]
						,[Noemer]
						,[Laaddatum] = GETDATE()
						,Omschrijving =   'Verzuimpercentage: '
										+ iif(Teller/Noemer < 0.1, '  ' + format(Teller/Noemer,'P2'), format(Teller/Noemer,'P2'))
										+ '; '
										+ 'FTE: '
										+ format(Detail_01,'N1')
										+ '; '
										+ 'Directie: '
										+ Detail_03
										+ iif(Detail_03 <> 'Geanonimiseerd' and Detail_04 <> 'Geanonimiseerd' and Detail_03 <> Detail_04, '; Afdeling: '	+ Detail_04, '')
										+ iif(Detail_04 <> 'Geanonimiseerd' and Detail_05 <> 'Geanonimiseerd' and Detail_04 <> Detail_05, '; Team: '		+ Detail_05, '')
										+ iif(Detail_05 <> 'Geanonimiseerd' and Detail_06 <> 'Geanonimiseerd' and Detail_05 <> Detail_06, '; Groep: '		+ Detail_06, '')
						,[Detail_01] = case when [Detail_01] < 20 then '10+'
											when [Detail_01] < 30 then '20+'
											when [Detail_01] < 40 then '30+'
											else '40+'
											end
						,[Detail_02]
						,[Detail_03]
						,[Detail_04]
						,[Detail_05]
						,[Detail_06]
						,[Detail_07]
						,[Detail_08]
						,[Detail_09] = case when Detail_08 <> 'Geanonimiseerd' then Detail_08
											when Detail_07 <> 'Geanonimiseerd' then Detail_07
											when Detail_06 <> 'Geanonimiseerd' then Detail_06
											when Detail_05 <> 'Geanonimiseerd' then Detail_05
											when Detail_04 <> 'Geanonimiseerd' then Detail_04
											else Detail_03
											end
						,[Detail_10]	
			into #TempTable
			from cte2;

-----------------------------------------------------------------------------------------------------------
	-- 1881 Maandelijks verzuimpercentage

		set @fk_indicator_id = 1881;

			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														--,[Waarde]
														,[Teller]
														,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														,[Detail_09]
														,[Detail_10]
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
					--,[Waarde]
					,[Teller]
					,[Noemer]
					,[Omschrijving]
					,[Detail_01]
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					,[Detail_05]
					,[Detail_06]
					,[Detail_07]
					,[Detail_08]
					,[Detail_09]
					,[Detail_10]
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


-----------------------------------------------------------------------------------------------------------

	IF exists(  select *
				from [staedion_dm].[Dashboard].[RealisatieDetails] 
				where fk_indicator_id = @fk_indicator_id
						and Datum between dateadd(mm, 1, dateadd(yy, -1, dateadd(d, 1-day(@peildatum), @peildatum))) and eomonth(dateadd(mm, 1, dateadd(yy, -1, dateadd(d, 1-day(@peildatum), @peildatum))))
			  )
		BEGIN

		with cteM as(	select	 Datum
								,Teller = SUM(Teller)
								,Noemer = SUM(Noemer)
		from staedion_dm.Dashboard.RealisatieDetails
		where fk_indicator_id = @fk_indicator_id
				and Datum between dateadd(mm, 1, dateadd(yy, -1, dateadd(d, 1-day(@peildatum), @peildatum))) and eomonth(@peildatum)
		group by Datum
		)

		select	 Datum = @peildatum
				,Teller
				,Noemer
				,Omschrijving =   'Verzuimpercentage: ' 
								+ format(cast(Teller as float) / cast(Noemer as float), 'P2') 
								+ '; '
								+ 'Periode: '
								+ FORMAT(Datum, 'yyyy-MM')
		into #TempTable2
		from cteM;



-----------------------------------------------------------------------------------------------------------
	-- 1885 Jaarlijks verzuimfrequentie

		set @fk_indicator_id = 1885;

			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														--,[Waarde]
														,[Teller]
														,[Noemer]
														,[Omschrijving]
														--,[Detail_01]
														--,[Detail_02]
														--,[Detail_03]
														--,[Detail_04]
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
					--,[Waarde]
					,[Teller]
					,[Noemer]
					,[Omschrijving]
					--,[Detail_01]
					--,[Detail_02]
					--,[Detail_03]
					--,[Detail_04]
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
			FROM #TempTable2;

			drop table #TempTable2;

		END


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
