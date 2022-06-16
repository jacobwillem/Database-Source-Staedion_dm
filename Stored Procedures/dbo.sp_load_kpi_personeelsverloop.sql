SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


























CREATE PROCEDURE[dbo].[sp_load_kpi_personeelsverloop](
  @peildatum date = '20220110'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_personeelsverloop] '20220110'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures where Databaseobject like '%personeelsbezetting%' order by Begintijd desc

Voor toevoeging kpi 1826? fte realisatie gebruik SUM(fte_resources) ipv SUM(parttime_factor)

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
						,begroting_id
						,org_level_2
						,org_level_3
						,org_level_4
						,org_level_5
						,org_level_6
						,org_level_7
						,org_level_8
						,formatiecategorie = case	when tijdelijke_formatie = 1 then 'Tijdelijke formatie'
													when plus_tien_formatie = 1 then '+10 formatie'
													else 'Vaste formatie'
													end
						,[FTE ultimo] = parttime_factor
						,nettoverloop = case		when instroom = 1 then 1
													when doorstroom = 1 then 0
													when uitstroom = 1 then -1
													end
						,verloopcategorie = case	when instroom = 1 then 'Instroom'
													when doorstroom = 1 then 'Doorstroom'
													when uitstroom = 1 then 'Uitstroom'
													end
				from cteFTE
				where	emp_groupname = 'werknemers'
				and		org_level_2 = 'Bestuur'
				and		cts_type IN ('Onbepaalde duur', 'Tijdelijk contract') -- alle werknemers met contract voor (on)bepaalde tijd in de formatiegroepen vast, tijdelijk en +10	
				and		reporting_date between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				and		(instroom = 1 or doorstroom = 1 or uitstroom = 1)
				)

	select	 Waarde = cteSFTE.nettoverloop
			,Omschrijving =  'Verloopcategorie: '
							+ cteSFTE.verloopcategorie
							+ '; '
							+ 'Formatiegroep: '
							+ cteSFTE.formatiecategorie
							+ '; '
							+ 'FTE: '
							+ format(cteSFTE.[FTE ultimo], 'N2')
							+ '; '
							+ 'Functie: '
							+ format(cteSFTE.fun_functionid, 'G') + ' - ' + cteSFTE.functionname
							+ '; '
							+ 'Directie: '
							+ cteSFTE.org_level_3
							+ '; '
							+ 'Kostenplaats: '
							+ format(cteSFTE.dep_costcenter, 'G') + ' - ' + cteSFTE.dep_costcentername
			,Detail_01 = cteSFTE.verloopcategorie
			,Detail_02 = cteSFTE.org_level_2
			,Detail_03 = cteSFTE.org_level_3
			,Detail_04 = cteSFTE.org_level_4
			,Detail_05 = cteSFTE.org_level_5
			,Detail_06 = cteSFTE.org_level_6
			,Detail_07 = cteSFTE.org_level_7
			,Detail_08 = cteSFTE.org_level_8
			,Detail_09 = format(cteSFTE.fun_functionid, 'G') + ' - ' + cteSFTE.functionname
			,Detail_10 = cteSFTE.formatiecategorie
	into #TempTable
	from cteSFTE;

-----------------------------------------------------------------------------------------------------------
	-- 1840 Personeelsverloop (aantal medewerkers netto)

		set @fk_indicator_id = 1840;

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
					,[Waarde]
					--,[Teller]
					--,[Noemer]
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
