SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE PROCEDURE[dbo].[sp_load_kpi_npo_productieve_uren_eigen_dienst](
  @peildatum date = '20210101'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_npo_productieve_uren_eigen_dienst] '20210131'
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
	-- 2100 Productieve uren eigen dienst

		select @fk_indicator_id = 2100
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			with
								
			[Details] as
				(
						SELECT	 [Datum] = cast(Datum as date)
								,[Waarde] = [Aantal uren]
								,[Resource]
								,[Sjablooncode]
								,[Reparatie-order]
								,[Reparatie-verzoek]
								,[Eenheidnummer] = VERZ.[Realty Object No_]
							    ,[Clusternummer] = CASE WHEN VERZ.[Cluster No_] LIKE 'FT%'
															THEN VERZ.[Cluster No_]
														WHEN VERZ.[Cluster No_] LIKE 'BB%'
															THEN 'FT-' + right(LEFT(VERZ.[Cluster No_], 7), 4)
														ELSE NULL
														END
						FROM [Backup_empire_dwh].[dbo].[tmv_projectpost] as UREN
						inner join [empire_staedion_data].[dwh].[Improductiviteit] as IMPR
							on UREN.[Sleutel improductiviteit] = IMPR.id
						left outer join [empire_data].[dbo].[Staedion$Maintenance_Request] as VERZ
							on UREN.[Reparatie-verzoek] = VERZ.No_
						where IMPR.Groepering = 'F. Uren reparatietaken (D – E)'
								AND [Aantal uren] <> 0
								and cast(Datum as date) between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum))

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
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   [Eenheidnummer] + '; ' +
													[Reparatie-verzoek] + '; ' +
													[Reparatie-order] + '; ' +
													[Sjablooncode] + '; ' +
													[Resource]
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
				select det.fk_indicator_id, @peildatum, sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
				group by det.fk_indicator_id;

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
