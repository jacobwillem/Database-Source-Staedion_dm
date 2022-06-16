SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Dashboard].[sp_load_kpi_financiele_ratios] 
			( @Peildatum AS DATE = NULL							-- JvdW 20220317 omgedraaid, foute afhandeling namelijk bij sp_load_kpi_financiele_ratios '2022-03-31'
			, @IndicatorID AS INT = NULL
			, @LoggingWegschrijvenOfNiet AS BIT = 1) 
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = 
N'Laadprocedure: excelbestand wordt vanuit de oude rapportageportal gekopieerd naar de s-dwh2012-sp. Daar verwijst een linked server naar en die haalt de diverse rijen op en zet ze om naar meerdere financiele kpis.
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Dashboard'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_financiele_ratios';
GO
exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'Dashboard','sp_load_kpi_financiele_ratios'

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220421 JvdW aanpassing na mail Martijn + toepassing schemanaam Dashboard
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
EXEC [Dashboard].[sp_load_kpi_financiele_ratios] '20220228'

-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_kpi_financiele_ratios%' ORDER BY begintijd desc

############################################################################################################################# */


BEGIN TRY
		SET NOCOUNT on
		DECLARE @onderwerp NVARCHAR(100);

-----------------------------------------------------------------------------------
SET @onderwerp = 'Variabelen definieren';
----------------------------------------------------------------------------------- 
		DECLARE @_Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID),										-- om mee te geven bij loggen
				@_Variabelen NVARCHAR(255),															-- om eenmalig mee te geven bij loggen
				@_Categorie AS NVARCHAR(255) = 	COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'?'),			-- om eenmalig mee te geven bij loggen: schema-naam om aan te geven dat het om dashboard-, datakwaliteit-procedures gaat of bijv PowerAutomate
				@_AantalRecords DECIMAL(12, 0),														-- om in uitvoerscherm te kunnen zien hoeveel regels er gewist/toegevoegd zijn
				@_Bericht NVARCHAR(255),															-- om tussenstappen te loggen
				@start as DATETIME,																	-- om duur procedure te kunnen loggen
				@finish as DATETIME																	-- om duur procedure te kunnen loggen

		IF @Peildatum IS NULL
			SET @Peildatum = EOMONTH(DATEADD(m, - 1, GETDATE()));

		SET @_Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
											+ '@LoggingWegschrijvenOfNiet = ' + COALESCE(CAST(@LoggingWegschrijvenOfNiet AS NVARCHAR(1)),'null')													

		SET	@start = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
SET @onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC [staedion_dm].[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet


-----------------------------------------------------------------------------------
SET @onderwerp = 'Data voorbereiden';
----------------------------------------------------------------------------------- 
		DROP TABLE IF EXISTS ##RATIO;

		;WITH 
		XLS AS 
			(SELECT TOP (18) [Categorie] = [Categorie]
							,[Omschrijving] = [F1]
							,[Naam] = IIF(CHARINDEX(' ', [F1]) > 0, LEFT([F1], CHARINDEX(' ', [F1])), [F1])
							,[Type] = IIF(PATINDEX('%(%',[F1]) > 0, REPLACE(SUBSTRING([F1], (PATINDEX('%(%',[F1]) + 1), (PATINDEX('%)%',[F1]))), ')', ''), '')
							,[Waarde]
			FROM [EXCEL_Kengetallen_Tertaalrapportage_2022]...['Kengetallen T-rapportage$']
			UNPIVOT ([Waarde] FOR [Categorie] IN (DAEB, [Niet-DAEB], [Geconsolideerd])) AS unpvt
			WHERE [Waarde] < 1 AND [Waarde] <> 0
			),
		DAT AS
			(
			SELECT TOP (1) [Datum] = CONVERT(DATE, [Laatste bijgewerkt:])
			FROM [EXCEL_Kengetallen_Tertaalrapportage_2022]...['Kengetallen T-rapportage$']
			)

		SELECT   [Laaddatum] = CONVERT(DATETIME, GETDATE(), 120)
				,[Waarde] = XLS.[Waarde]
				,[Datum] = @Peildatum
				,[Omschrijving] = XLS.[Categorie] + '; ' + XLS.[Omschrijving] + '; Ratio bijgewerkt op: ' + CONVERT(NVARCHAR, DAT.[Datum])
				,[fk_indicator_id] = I.[id]
				,[Detail_01] = XLS.[Categorie]
				,[Detail_02] = XLS.[Omschrijving]
				,[Detail_03] = 'Ratio bijgewerkt op: ' + CONVERT(NVARCHAR, DAT.[Datum])
		INTO ##RATIO
		FROM XLS
		INNER JOIN [staedion_dm].[Dashboard].[Indicator] AS I
			ON I.[Omschrijving]  LIKE XLS.[Categorie] + ': %'
			AND I.[Omschrijving] LIKE '%' + XLS.[Naam] + '%'
			AND I.[Omschrijving] LIKE '%' + XLS.[Type] + '%'
		CROSS JOIN DAT;


-----------------------------------------------------------------------------------
SET @onderwerp = 'Wissen regels';
----------------------------------------------------------------------------------- 
		DELETE	RD
		FROM	[staedion_dm].[Dashboard].[RealisatieDetails] AS RD
		JOIN	##RATIO AS FR ON FR.[fk_indicator_id] = RD.[fk_indicator_id]
		WHERE	eomonth(RD.[Datum]) = eomonth(@Peildatum);					-- JvdW 21042022 eomonth()

		SET @_AantalRecords = @@rowcount;

		DELETE	RD
		FROM	[staedion_dm].[Dashboard].[RealisatieDetails] AS RD
		WHERE	RD.[fk_indicator_id] = 3000
		and		eomonth(RD.[Datum]) = eomonth(@Peildatum);					-- JvdW 21042023 toegevoegd

		SET @_AantalRecords = @_AantalRecords + @@rowcount;

		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC [staedion_dm].[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet;
					
-----------------------------------------------------------------------------------
SET @onderwerp = 'Toevoegen regels';
----------------------------------------------------------------------------------- 
		INSERT INTO [staedion_dm].[Dashboard].[RealisatieDetails]
					([Laaddatum]
					,[Waarde]
					,[Datum]
					,[Omschrijving]
					,[fk_indicator_id]
					,[Detail_01]
					,[Detail_02]
					,[Detail_03]
					)
			SELECT [Laaddatum]
				  ,[Waarde]
				  ,[Datum]
				  ,[Omschrijving]
				  ,[fk_indicator_id]
				  ,[Detail_01]
				  ,[Detail_02]
				  ,[Detail_03]
			FROM ##RATIO

			UNION

			SELECT [Laaddatum] = CONVERT(DATETIME, GETDATE(), 120)
				  ,[Waarde] = SUM(CASE
									WHEN I.[fk_schaalsoort_id] = 1 AND FR.[Waarde] > N.[Waarde] THEN 1
									WHEN I.[fk_schaalsoort_id] = 2 AND FR.[Waarde] < N.[Waarde] THEN 1
									ELSE 0
								END
								)
				  ,[Datum] = @Peildatum
				  ,[Omschrijving] = COALESCE(STRING_AGG(CASE
													WHEN I.[fk_schaalsoort_id] = 1 AND FR.[Waarde] <= N.[Waarde] THEN I.[Omschrijving] + ' voldoet niet aan norm (realisatie: ' + FORMAT(FR.[Waarde], I.[Weergaveformat]) + ', norm: ' + FORMAT(N.[Waarde], I.[Weergaveformat]) + ')'
													WHEN I.[fk_schaalsoort_id] = 2 AND FR.[Waarde] >= N.[Waarde] THEN I.[Omschrijving] + ' voldoet niet aan norm (realisatie: ' + FORMAT(FR.[Waarde], I.[Weergaveformat]) + ', norm: ' + FORMAT(N.[Waarde], I.[Weergaveformat]) + ')'
													ELSE NULL
												END, '; '), 'Alle ratio''s voldoen aan de norm')
				  ,[fk_indicator_id] = 3000
				  ,[Detail_01] = NULL
				  ,[Detail_02] = NULL
				  ,[Detail_03] = NULL
		FROM ##RATIO FR
		INNER JOIN [Dashboard].[Indicator] AS I
			 ON FR.[fk_indicator_id] = I.[id]
		INNER JOIN [Dashboard].[Normen] AS N
			 ON FR.[fk_indicator_id] = N.[fk_indicator_id]
			AND YEAR(FR.[Datum]) = YEAR(N.[Datum])
			AND MONTH(FR.[Datum]) = MONTH(N.[Datum])

		SET @_AantalRecords = @@rowcount;
		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC [staedion_dm].[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

		DROP TABLE IF EXISTS ##RATIO;

	SET		@finish = CURRENT_TIMESTAMP
	
	--SELECT 1/0
-----------------------------------------------------------------------------------
SET @onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC [staedion_dm].[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Variabelen = @_Variabelen
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

					
END TRY

BEGIN CATCH

	SET		@finish = CURRENT_TIMESTAMP

	DECLARE @_ErrorProcedure AS NVARCHAR(255) = ERROR_PROCEDURE()
	DECLARE @_ErrorLine AS INT = ERROR_LINE()
	DECLARE @_ErrorNumber AS INT = ERROR_NUMBER()
	DECLARE @_ErrorMessage AS NVARCHAR(255) = LEFT(ERROR_PROCEDURE(),255)

	EXEC [staedion_dm].[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					, @DatabaseObject = @_Bron
					, @Variabelen = @_Variabelen
					--, @Bericht = 'Nvt' 		
					, @Begintijd = @start
					, @Eindtijd = @finish
					, @ErrorProcedure =  @_ErrorProcedure
					, @ErrorLine = @_ErrorLine
					, @ErrorNumber = @_ErrorNumber
					, @ErrorMessage = @_ErrorMessage

END CATCH



GO
EXEC sp_addextendedproperty N'MS_Description', N'Laadprocedure: excelbestand wordt vanuit de oude rapportageportal gekopieerd naar de s-dwh2012-sp. Daar verwijst een linked server naar en die haalt de diverse rijen op en zet ze om naar meerdere financiele kpis.
', 'SCHEMA', N'Dashboard', 'PROCEDURE', N'sp_load_kpi_financiele_ratios', NULL, NULL
GO
