SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

























CREATE PROCEDURE[dbo].[sp_load_kpi_personeelsbezetting](
  @peildatum date = '20220105'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_personeelsbezetting] '20220106'

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
						,formatiecategorie = case	when tijdelijke_formatie = 1 then 'Tijdelijke formatie'
													when plus_tien_formatie = 1 then '+10 formatie'
													else 'Vaste formatie'
													end
						,[FTE ultimo] = SUM(parttime_factor)
				from cteFTE
				where	emp_groupname = 'werknemers'
				and		org_level_2 = 'Bestuur'
				and		cts_type IN ('Onbepaalde duur', 'Tijdelijk contract') -- alle werknemers met contract voor (on)bepaalde tijd in de formatiegroepen vast, tijdelijk en +10	
				and		reporting_date between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by year_number
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
						,case	when tijdelijke_formatie = 1 then 'Tijdelijke formatie'
								when plus_tien_formatie = 1 then '+10 formatie'
								else 'Vaste formatie'
								end
				)

	,cteBUD as(	select *
				from [A-PBI-PROD].[vault].[visma].[view_dim_begroting]
			   ) 

	,cteSBUD as(
				select   begroting_id
						,bedrijfsonderdeel
						,kostenplaats_id
						,kostenplaats_naam
						,dep_costcenter
						,dep_costcenter_name
						,functie
						,formatiecategorie = 'Vaste formatie'
						,formatie = vaste_formatie
						,dekking_formatie
				from cteBUD
				where vaste_formatie is not null

				union all

				select   begroting_id
						,bedrijfsonderdeel
						,kostenplaats_id
						,kostenplaats_naam
						,dep_costcenter
						,dep_costcenter_name
						,functie
						,formatiecategorie = 'Tijdelijke formatie'
						,formatie = tijdelijke_formatie
						,dekking_formatie
				from cteBUD
				where tijdelijke_formatie is not null

				union all

				select   begroting_id
						,bedrijfsonderdeel
						,kostenplaats_id
						,kostenplaats_naam
						,dep_costcenter
						,dep_costcenter_name
						,functie
						,formatiecategorie = '+10 formatie'
						,formatie = plus_tien_formatie
						,dekking_formatie
				from cteBUD
				where plus_tien_formatie is not null
				)

	select	 Waarde = cteSFTE.[FTE ultimo]
			,Omschrijving =  'Formatiebudget: '
							+ iif(year(cteSFTE.reporting_date) >= 2022, format(coalesce(cteSBUD.formatie, 0), 'N2') + ' FTE', 'Onbekend/NVT')
							+ '; '
							+ 'Formatiegroep: '
							+ cteSFTE.formatiecategorie
							+ '; '
							+ 'Functie: '
							+ format(cteSFTE.fun_functionid, 'G') + ' - ' + cteSFTE.functionname
							+ '; '
							+ 'Formatiestatus: '
							+ iif(year(cteSFTE.reporting_date) >= 2022,
									iif(round(cteSFTE.[FTE ultimo], 2) > round(coalesce(cteSBUD.formatie, 0), 2),
										format(round(cteSFTE.[FTE ultimo], 2) - round(coalesce(cteSBUD.formatie, 0), 2), 'N2') + ' FTE buiten formatie',
										'Binnen formatie'),
									'Onbekend/NVT') 
							+ '; '
							+ 'Dekking formatie: '
							+ iif(year(cteSFTE.reporting_date) >= 2022, iif(cteSBUD.dekking_formatie is not null, 'Ja', 'Nee'), 'Onbekend/NVT')
							+ '; '
							+ 'Directie: '
							+ cteSFTE.org_level_3
							+ '; '
							+ 'Kostenplaats: '
							+ format(cteSFTE.dep_costcenter, 'G') + ' - ' + cteSFTE.dep_costcentername
			,Detail_01 = cteSFTE.org_level_3
			,Detail_02 = format(cteSFTE.dep_costcenter, 'G') + ' - ' + cteSFTE.dep_costcentername
			,Detail_03 = format(cteSFTE.fun_functionid, 'G') + ' - ' + cteSFTE.functionname
			,Detail_04 = cteSFTE.formatiecategorie
			,Detail_05 = iif(year(cteSFTE.reporting_date) >= 2022,
									iif(round(cteSFTE.[FTE ultimo], 2) > round(coalesce(cteSBUD.formatie, 0), 2),
										'Buiten formatie',
										'Binnen formatie'),
									'Onbekend/NVT') 
			,Detail_06 = iif(year(cteSFTE.reporting_date) >= 2022, iif(cteSBUD.dekking_formatie is not null, 'Ja', 'Nee'), 'Onbekend/NVT')
	into #TempTable
	from cteSFTE
	left outer join cteSBUD
		on cteSFTE.begroting_id = cteSBUD.begroting_id
			and cteSFTE.formatiecategorie = cteSBUD.formatiecategorie;

-----------------------------------------------------------------------------------------------------------
	-- 1825 Personeelsbezetting FTE (ultimo)

		set @fk_indicator_id = 1825;

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
					,[Detail_05]
					,[Detail_06]
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
