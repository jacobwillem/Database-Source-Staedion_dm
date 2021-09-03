SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_load_dashboard] @peildatum date = null
as
	BEGIN TRY

  -- Diverse variabelen
		set nocount on;

		declare @start as datetime;
		declare @finish as datetime;
		declare @LogboekTekst NVARCHAR(255) = ' Procedure staedion_dm.Datakwaliteit.';
		declare @VersieNr NVARCHAR(80) = ' - Versie 4 20200720 JvdW'	;
		set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
		declare @Bericht NVARCHAR(255);
		set	@start =current_timestamp;

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';


		-- Completeness
				declare @indicatorid int, @frequentie int, @berekeningswijze int, @procedure nvarchar(1000), @argument varchar(200), @sql nvarchar(1000)

				set nocount on
	
				if @peildatum is null
					begin
						select @peildatum = loading_day from empire_logic.dbo.dlt_loading_day	 
					end
				;

				-- cursor voor indicatoren 
				declare kpi cursor for
						SELECT ind.id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_completeness
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Procedure_completeness, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_completeness is not null		-- jvdw 23-06-2021 toegevoegd
						union
						-- JvdW 2020-07-15 toegevoegd
						SELECT ind.id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_Overig
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Procedure_overig, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_Overig is not null		-- jvdw 23-06-2021 toegevoegd
						union
						-- JvdW 2020-10-28 toegevoegd
						SELECT ind.id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_accuracy
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Dimension_accuracy, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_Accuracy is not null		-- jvdw 23-06-2021 toegevoegd
						union
						-- JvdW 2020-11-04 toegevoegd
						SELECT ind.id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_consistency
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Dimension_consistency, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_consistency is not null		-- jvdw 23-06-2021 toegevoegd
						ORDER BY ind.id DESC

				open kpi

				fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument
	
					while @@fetch_status = 0
					begin
							-- als @berekeningwijze = 2, dan peildatum altijd wijzigen in laatste van de maand, anders peildatum ongewijzigd doorgeven aan procedure
							set @sql = @procedure
							set @sql = replace(@sql, '@Laaddatum = null', '@Laaddatum = ' + '''' + CONVERT(VARCHAR(10), @peildatum, 112) + '''')
		
							--print @sql 
							exec (@sql)

						fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument
			
					end
	
				close kpi

				deallocate kpi


					SET @bericht = 'Alles verwerkt ' 
					EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht


			set		@finish = current_timestamp

			PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - EINDE';

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
