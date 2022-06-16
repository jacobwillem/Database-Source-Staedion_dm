SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Dashboard].[sp_load_kpis_sjabloon] (
  @peildatum DATE = '20210131', 
  @WelkeChildPackageUitvoeren AS NVARCHAR(MAX) =  
  N'[{"IndicatorID": 1, "UitvoerenJaNee": "Ja"}, 
  {"IndicatorID": 5, "UitvoerenJaNee": "Nee"}]'
)
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon kan gebruikt worden voor nieuwe procedures of het omzetten van oude procedures. 
Tbv uniformiteit + logging + kans op fouten verminderen.>
Logging van de procedure vindt plaats door de aanroep van staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten].
Dit schrijft de stappen weg naar tabel staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] met parameters
@Bron => Databaseobject
@Variabelen => eventuele parameters bijv peildatum
@Categorie => schemanaam dashboard bijv of kpi of ETL maatwerk, ETL datamart, Power Automate, ETL oud maatwerk, Dataset rapport laden, DatabaseBeheer
'      ,@level0type = N'SCHEMA'
       ,@level0name = 'Dashboard'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_master_sjabloon';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Dashboard].[sp_load_kpi_master_sjabloon] '20220131', N'[{"IndicatorID": 0, "UitvoerenJaNee": "Ja"}, {"IndicatorID": -1, "UitvoerenJaNee": "Ja"}]'
select * from staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] order by Begintijd desc
--------------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
BEGIN TRY
		SET NOCOUNT ON
		DECLARE @onderwerp NVARCHAR(100);

-----------------------------------------------------------------------------------
SET @onderwerp = 'Variabelen definieren tbv logging ed';
----------------------------------------------------------------------------------- 
		DECLARE  @Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID),										
				 @Variabelen NVARCHAR(MAX)	= @WelkeChildPackageUitvoeren,							
				 @Categorie AS NVARCHAR(255) = 	COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'?'),			
				 @Start AS DATETIME,														
				 @Finish AS DATETIME	,		
				 @Cursor_indicatorid AS INT,
				 @Cursor_begin_datum AS DATE,
				 @Cursor_eind_datum AS DATE,
				 @AantalRecords AS INT,
				 @Bericht AS NVARCHAR(255),
				 @BerichtInclVariabelen AS NVARCHAR(510)

		SET	@Start = CURRENT_TIMESTAMP;

		DROP TABLE IF EXISTS #Parameters;
		CREATE TABLE #Parameters (IndicatorID INT, UitvoerenJaNee NVARCHAR(3));

		INSERT INTO #Parameters (IndicatorID, UitvoerenJaNee)
		SELECT *
		FROM OPENJSON(@WelkeChildPackageUitvoeren)
		  WITH (
			id INT 'strict $.IndicatorID',				
			UitvoerenJaNee NVARCHAR(50) '$.UitvoerenJaNee'
		  );

		SET @Variabelen = '@IndicatorID = ' + COALESCE(@WelkeChildPackageUitvoeren,'null') + ' ; ' 
										+ '@Peildatum = ' + COALESCE(FORMAT(@Peildatum,'dd-MM-yyyy','nl-NL'),'null')
		
		IF @Peildatum IS NULL
			SET @Peildatum = EOMONTH(DATEADD(m, - 1, GETDATE()));

-----------------------------------------------------------------------------------
SET @onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @onderwerp
					,@Variabelen = @Variabelen

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Welke datumreeks te wissen en te vullen (per indicator) ?';
----------------------------------------------------------------------------------- 
		DROP TABLE IF EXISTS #DatumReeks
		;
		SELECT IND.id, T.datum
		INTO #DatumReeks
		FROM [Dashboard].[Indicator] AS IND
			LEFT OUTER JOIN Dashboard.Frequentie AS FREQ
				ON IND.fk_frequentie_id = FREQ.id
			JOIN empire_dwh.dbo.tijd AS T
				ON 1 = 1
		WHERE 1=1
		AND		YEAR(T.datum) = YEAR(@Peildatum)
		AND		IND.id IN (SELECT IndicatorID FROM #Parameters) 
		AND		(
					(MONTH(T.datum) = MONTH(@Peildatum) AND COALESCE(freq.Omschrijving, 'Maandelijks') IN ('Dagelijks', 'Maandelijks'))
			OR		(DATEPART(ISO_WEEK,T.datum) = DATEPART(ISO_WEEK,@Peildatum) AND COALESCE(freq.Omschrijving, 'Wekelijks') ='Wekelijks')
				)

-----------------------------------------------------------------------------------
SET @onderwerp = 'Tijdelijke tabel genereren die voor set aan kpis kan gelden';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @onderwerp
					,@Variabelen = @Variabelen
                  
-----------------------------------------------------------------------------------
SET @onderwerp = 'Loop door indicatoren';
----------------------------------------------------------------------------------- 
		
		Declare kpi CURSOR FOR 
			SELECT  ind.IndicatorID, MIN(T.datum) AS begin_datum, MAX(T.datum) AS eind_datum
			FROM	#Parameters AS IND
			JOIN	#DatumReeks AS T
			ON		1=1
			WHERE	UitvoerenJaNee = 'Ja'
			GROUP BY ind.IndicatorID
			ORDER BY ind.IndicatorID

			OPEN kpi

			FETCH NEXT FROM kpi INTO @Cursor_indicatorid, @Cursor_begin_datum, @Cursor_eind_datum

			WHILE @@FETCH_STATUS = 0

			BEGIN         
				-----------------------------------------------------------------------------------
				SET @Onderwerp = 'Wissen regels';
				----------------------------------------------------------------------------------- 
				DELETE	
				FROM	staedion_dm.dashboard.realisatiedetails  
				WHERE	fk_indicator_id  = @Cursor_indicatorid
				AND		Datum BETWEEN  @Cursor_begin_datum AND @Cursor_eind_datum
				;
				SET @AantalRecords = @@rowcount;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
				SET @Variabelen = '@Indicator = '+ FORMAT(@Cursor_indicatorid,'N0') +  ' ; Datum tussen ' + FORMAT(@Cursor_begin_datum, 'dd-MM-yyyy en ') +FORMAT(@Cursor_eind_datum, 'dd-MM-yyyy')
				SET @BerichtInclVariabelen = @Bericht + ' ; '+ @Variabelen

				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @BerichtInclVariabelen
					,@Variabelen = @Variabelen
				-----------------------------------------------------------------------------------
				SET @Onderwerp = 'Toevoegen regels';
				----------------------------------------------------------------------------------- 
				INSERT INTO [Dashboard].[RealisatieDetails]
					([Laaddatum]
					,[Waarde]
					,[Teller]
					,[Noemer]
					,[Datum]
					,[fk_indicator_id]
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
					,[eenheidnummer]
					,[bouwbloknummer]
					,[clusternummer]
					,[klantnummer]
					,[volgnummer]
					,[relatienummer]
					,[dossiernummer]
					,[betalingsregelingnummer]
					,[rekeningnummer]
					,[documentnummer]
					,[leveranciernummer]
					,[werknemernummer]
					,[projectnummer]
					,[verzoeknummer]
					,[ordernummer]
					,[taaknummer]
					,[overig]
					)
			SELECT	CONVERT(DATETIME ,GETDATE(), 120) AS [Laaddatum]
					,1 AS [Waarde]
					,NULL AS [Teller]
					,NULL AS [Noemer]
					,@Cursor_eind_datum AS [Datum]
					,@Cursor_indicatorid AS [fk_indicator_id]
					,'TEST sjabloon' [Omschrijving] 
					,NULL AS [Detail_01]
					,NULL AS [Detail_02]
					,NULL AS [Detail_03]
					,NULL AS [Detail_04]
					,NULL AS [Detail_05]
					,NULL AS [Detail_06] 
					,NULL AS [Detail_07]
					,NULL AS [Detail_08]
					,NULL AS [Detail_09]
					,NULL AS [Detail_10]
					,NULL AS [eenheidnummer]
					,NULL AS [bouwbloknummer]
					,NULL AS [clusternummer]
					,NULL AS [klantnummer]
					,NULL AS [volgnummer]
					,NULL AS [relatienummer]
					,NULL AS [dossiernummer]
					,NULL AS [betalingsregelingnummer]
					,NULL AS [rekeningnummer]
					,NULL AS [documentnummer]
					,NULL AS [leveranciernummer]
					,NULL AS [werknemernummer]
					,NULL AS [projectnummer]
					,NULL AS [verzoeknummer]
					,NULL AS [ordernummer]
					,NULL AS [taaknummer]
					,NULL AS [overig]

					SET @AantalRecords = @@rowcount;
					SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
					SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
					SET @Variabelen = '@Indicator = '+ FORMAT(@Cursor_indicatorid,'N0') +  ' ; @Peildatum = ' + FORMAT(@Peildatum, 'dd-MM-yyyy')
					SET @BerichtInclVariabelen = @Bericht + ' ; '+ @Variabelen

					EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
						@Categorie = @Categorie
						,@DatabaseObject = @Bron
						,@Bericht = @BerichtInclVariabelen
						,@Variabelen = @Variabelen

					-----------------------------------------------------------------------------------
					SET @Onderwerp = 'Update details';
					----------------------------------------------------------------------------------- 

					FETCH NEXT FROM kpi INTO @Cursor_indicatorid, @Cursor_begin_datum, @Cursor_eind_datum
					
					END

	SET		@Finish = CURRENT_TIMESTAMP
	
	--SELECT 1/0
-----------------------------------------------------------------------------------
SET @onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @onderwerp

					
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
					--, @Bericht = 'Nvt' 		
					, @Begintijd = @Start
					, @Eindtijd = @Finish
					, @ErrorProcedure =  @ErrorProcedure
					, @ErrorLine = @ErrorLine
					, @ErrorNumber = @ErrorNumber
					, @ErrorMessage = @ErrorMessage
					, @Bericht = @ErrorMessage

END CATCH



GO
