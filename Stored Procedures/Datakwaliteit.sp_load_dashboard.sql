SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_load_dashboard] @peildatum DATE = NULL
AS
-- JVDW: begin/try zo geplaatst in while-loop dat bij foutieve aanroep de volgende procedure opgehaald wordt
-- JVDW: procedure_overig kan exec ... bevatten, dan zo uitvoeren dan wel een standaard view die zo is opgebouwd dat ie rechtstreeks in RealistieDetails te inserten is

		SET NOCOUNT ON
		DECLARE @Onderwerp NVARCHAR(100);

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Variabelen definieren';
----------------------------------------------------------------------------------- 
		DECLARE @Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID),										
				@Variabelen NVARCHAR(255),															
				@Categorie AS NVARCHAR(255) = 	COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'Overig'),	
				@AantalRecords DECIMAL(12, 0),														
				@Bericht NVARCHAR(255),															
				@Start as DATETIME,																
				@Finish as DATETIME,
				@AlleenPrintenSQLNietUitvoeren AS smallint = 0

		IF @Peildatum IS NULL
			SET @Peildatum = GETDATE();

		SET @Variabelen = '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') 

		SET	@Start = CURRENT_TIMESTAMP;

		-----------------------------------------------------------------------------------
		SET @Onderwerp = 'BEGIN';
		----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Variabelen = @Variabelen
					,@Bericht = @Onderwerp


		-- Completeness
				declare @soortsql BIT, @indicatorid int, @indicatordimensieid int, @frequentie int, @berekeningswijze int, @procedure nvarchar(1000), @argument varchar(200), @sql nvarchar(1000)

				set nocount on
	
				if @peildatum is null
					begin
						select @peildatum = loading_day from empire_logic.dbo.dlt_loading_day	 
					end
				;

				-- cursor voor indicatoren 
				declare kpi cursor for
						SELECT		0 AS soortsql
									,ind.id
									,ind.fk_indicatordimensie_id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_completeness
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Procedure_completeness, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_completeness is not null		-- jvdw 23-06-2021 toegevoegd
									 --AND 1=0
						union
						-- JvdW 2020-07-15 toegevoegd
						SELECT		0 AS soortsql
									,ind.id
									,ind.fk_indicatordimensie_id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_Overig
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Procedure_overig, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_Overig is not null		-- jvdw 23-06-2021 toegevoegd
									 AND ind.Procedure_Overig LIKE 'exec%'
									 --AND 1=0 
						union
						-- JvdW 2020-10-28 toegevoegd
						SELECT		0 AS soortsql
									,ind.id
									,ind.fk_indicatordimensie_id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_accuracy
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Dimension_accuracy, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_Accuracy is not null		-- jvdw 23-06-2021 toegevoegd
									 --AND 1=0
						union
						-- JvdW 2020-11-04 toegevoegd
						SELECT		 0 AS soortsql
									,ind.id
									,ind.fk_indicatordimensie_id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_consistency
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Dimension_consistency, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_consistency is not null		-- jvdw 23-06-2021 toegevoegd
									 --AND 1=0
						union
						-- JvdW 2022-02-02 toegevoegd
						SELECT		1 AS soortsql
									,ind.id
									,ind.fk_indicatordimensie_id
									 ,frequentie = fk_frequentie_id 
									 ,ind.fk_berekeningswijze_id
									 ,[procedure] = ind.Procedure_Overig
									 ,ind.Indicator_actief
						FROM [Datakwaliteit].[Indicator] ind
						WHERE isnull(ind.Procedure_overig, '') <> ''
									 AND ind.Indicator_actief = 1
									 and ind.Procedure_Overig is not null		-- jvdw 23-06-2021 toegevoegd
									 AND ind.Procedure_Overig NOT LIKE 'exec%'
									 AND @peildatum <= getdate()
									 --AND ind.id = 2504
						ORDER BY ind.id DESC

				open kpi

				fetch next from kpi into @soortsql, @indicatorid, @indicatordimensieid, @frequentie, @berekeningswijze, @procedure, @argument
	
					while @@fetch_status = 0

					BEGIN

						BEGIN TRY

									-- als @berekeningwijze = 2, dan peildatum altijd wijzigen in laatste van de maand, anders peildatum ongewijzigd doorgeven aan procedure
								IF @soortsql = 0
									BEGIN
										SET @sql = @procedure
										SET @sql = replace(@sql, '@Laaddatum = null', '@Laaddatum = ' + '''' + CONVERT(VARCHAR(10), @peildatum, 112) + '''')

										IF @AlleenPrintenSQLNietUitvoeren= 1
											print (@sql)
										IF @AlleenPrintenSQLNietUitvoeren= 0
											EXEC (@sql)

										SET @AantalRecords = @@rowcount;
										SET @Bericht = 'Stap: ' + @Onderwerp + ' @Indicator: ' + FORMAT(@indicatorid,'#') + ' - records: ';
										SET @Bericht = @Bericht + format(@AantalRecords, '#');
										EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
													@Categorie = @Categorie
													,@DatabaseObject = @Bron
													,@Bericht = @Bericht

									END

								IF @soortsql = 1
									BEGIN		
										-----------------------------------------------------------------------------------
										SET @Onderwerp = 'Wissen regels realisatiedetails';
										----------------------------------------------------------------------------------- 
												SET @SQL = 'DELETE '+
												'FROM	datakwaliteit.realisatiedetails '+ CHAR(10) +
												'WHERE	convert(date,Laaddatum) = '+''''+ FORMAT(@Peildatum, 'yyyyMMdd') +''''+ CHAR(10) +
												'and		fk_indicator_id = '+ FORMAT(@indicatorid, '#')+  CHAR(10) +
												'AND		fk_indicatordimensie_id = '+ FORMAT(@indicatordimensieid, '#')+';'

											IF @AlleenPrintenSQLNietUitvoeren= 1
												print (@sql)
											IF @AlleenPrintenSQLNietUitvoeren= 0
												EXEC (@sql)

										SET @AantalRecords = @@rowcount;
										SET @Bericht = 'Stap: ' + @Onderwerp + ' @Indicator: ' + FORMAT(@indicatorid,'#') + ' - records: ';
										SET @Bericht = @Bericht + format(@AantalRecords, '#');
										EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
													@Categorie = @Categorie
													,@DatabaseObject = @Bron
													,@Bericht = @Bericht

										-----------------------------------------------------------------------------------
										SET @Onderwerp = 'Toevoegen regels RealisatieDetails';
										----------------------------------------------------------------------------------- 
										SET @SQL ='INSERT INTO datakwaliteit.RealisatieDetails ' +CHAR(10) +
														'([fk_indicator_id],[fk_indicatordimensie_id] ' +CHAR(10) +
														',[Waarde] ' +CHAR(10) +
														',[Laaddatum] ' +CHAR(10) +
														',[Omschrijving] ' +CHAR(10) +
														',[Teller],[Noemer],[Eenheidnr] ' +CHAR(10) +
														',[Klantnr],[datEinde],[datIngang],[Hyperlink],[Bevinding],[Gebruiker],[Relatienr]) ' +CHAR(10) +
												'SELECT	' + FORMAT(@indicatorid, '#')+ ','+CHAR(10) +
														  + FORMAT(@indicatordimensieid, '#') + CHAR(10) +
														',[Waarde] '+ CHAR(10) +
														',[Laaddatum]  '+CHAR(10) +
														',[Omschrijving]  '+CHAR(10) +
														',[Teller],[Noemer],[Eenheidnr]  '+CHAR(10) +
														',[Klantnr],[datEinde],[datIngang],[Hyperlink],[Bevinding],[Gebruiker],[Relatienr]  '+CHAR(10) +
												'FROM	[staedion_dm].'+@procedure
				
											IF @AlleenPrintenSQLNietUitvoeren= 1
												print (@sql)
											IF @AlleenPrintenSQLNietUitvoeren= 0
												EXEC (@sql)
	
											SET @AantalRecords = @@rowcount;
											SET @Bericht = 'Stap: ' + @Onderwerp + ' @Indicator: ' + FORMAT(@indicatorid,'#') + ' - records: ';
											SET @Bericht = @Bericht + format(@AantalRecords, '#');
											EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
														@Categorie = @Categorie
														,@DatabaseObject = @Bron
														,@Bericht = @Bericht

										-----------------------------------------------------------------------------------
										SET @Onderwerp = 'Wissen regels Realisatie';
										----------------------------------------------------------------------------------- 
												SET @SQL = 'DELETE '+
												'FROM	datakwaliteit.realisatie '+ CHAR(10) +
												'WHERE	convert(date,Laaddatum) = '+''''+ FORMAT(@Peildatum, 'yyyyMMdd') +''''+ CHAR(10) +
												'and		fk_indicator_id = '+ FORMAT(@indicatorid, '#')+  CHAR(10) +
												'AND		fk_indicatordimensie_id = '+ FORMAT(@indicatordimensieid, '#')+';'

											IF @AlleenPrintenSQLNietUitvoeren= 1
												print (@sql)
											IF @AlleenPrintenSQLNietUitvoeren= 0
												EXEC (@sql)

										SET @AantalRecords = @@rowcount;
										SET @Bericht = 'Stap: ' + @Onderwerp + ' @Indicator: ' + FORMAT(@indicatorid,'#') + ' - records: ';
										SET @Bericht = @Bericht + format(@AantalRecords, '#');
										EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
													@Categorie = @Categorie
													,@DatabaseObject = @Bron
													,@Bericht = @Bericht

										-----------------------------------------------------------------------------------
										SET @Onderwerp = 'Toevoegen regels Realisatie';
										----------------------------------------------------------------------------------- 
										SET @SQL ='INSERT INTO datakwaliteit.Realisatie ' +CHAR(10) +
														'([fk_indicator_id],[fk_indicatordimensie_id] ' +CHAR(10) +
														',[Laaddatum] ' +CHAR(10) +
														',[Teller],[Noemer],[Waarde]) ' +CHAR(10) +
												'SELECT	' + FORMAT(@indicatorid, '#')+ ','+CHAR(10) +
														  + FORMAT(@indicatordimensieid, '#') + CHAR(10) +
														',[Laaddatum]  '+CHAR(10) +
														',sum([Teller]),sum(Noemer),sum(Waarde)  '+CHAR(10) +
												'FROM	datakwaliteit.RealisatieDetails '+ CHAR(10) +
												'WHERE	convert(date,Laaddatum) = '+''''+ FORMAT(@Peildatum, 'yyyyMMdd') +''''+ CHAR(10) +
												'and	fk_indicator_id = '+ FORMAT(@indicatorid, '#')+  CHAR(10) +
												'AND	fk_indicatordimensie_id = '+ FORMAT(@indicatordimensieid, '#')+  CHAR(10) +
												'GROUP BY [fk_indicator_id],[fk_indicatordimensie_id],[Laaddatum]'+';'
				
											IF @AlleenPrintenSQLNietUitvoeren= 1
												print (@sql)
											IF @AlleenPrintenSQLNietUitvoeren= 0
												EXEC (@sql)
	
											SET @AantalRecords = @@rowcount;
											SET @Bericht = 'Stap: ' + @Onderwerp + ' @Indicator: ' + FORMAT(@indicatorid,'#') + ' - records: ';
											SET @Bericht = @Bericht + format(@AantalRecords, '#');
											EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
														@Categorie = @Categorie
														,@DatabaseObject = @Bron
														,@Bericht = @Bericht
									END

									END TRY


									BEGIN CATCH

										SET		@Finish = CURRENT_TIMESTAMP

										DECLARE @ErrorProcedure AS NVARCHAR(255) = ERROR_PROCEDURE()
										DECLARE @ErrorLine AS INT = ERROR_LINE()
										DECLARE @ErrorNumber AS INT = ERROR_NUMBER()
										DECLARE @ErrorMessage AS NVARCHAR(255) = LEFT(ERROR_MESSAGE(),255)

										EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
														@Categorie = @Categorie
														, @DatabaseObject = @Bron
														, @Variabelen = @Variabelen
														, @Begintijd = @start
														, @Eindtijd = @finish
														, @ErrorProcedure =  @ErrorProcedure
														, @ErrorLine = @ErrorLine
														, @ErrorNumber = @ErrorNumber
														, @ErrorMessage = @ErrorMessage

										fetch next from kpi into @soortsql, @indicatorid, @indicatordimensieid, @frequentie, @berekeningswijze, @procedure, @argument			

									END CATCH					
		
							fetch next from kpi into @soortsql, @indicatorid, @indicatordimensieid, @frequentie, @berekeningswijze, @procedure, @argument
			
						END
	
				close kpi

				deallocate kpi

	SET		@Finish = CURRENT_TIMESTAMP
	
	--SELECT 1/0
-----------------------------------------------------------------------------------
SET @Onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@Begintijd = @Start
					,@Eindtijd = @Finish
					,@DatabaseObject = @Bron
					,@Variabelen = @Variabelen
					,@Bericht = @Onderwerp
					
GO
