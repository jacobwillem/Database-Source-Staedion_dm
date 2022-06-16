SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Dashboard].[sp_load_kpi_rookmelders_aantal_geplaatst] 
			( @IndicatorID AS INT = NULL
			, @Peildatum AS DATE = NULL) 
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
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Dashboard'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_sjabloon';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
<JJJJMMDD> <Initialen> <Toelichting>


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */


BEGIN TRY
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
				@Finish as DATETIME																

		IF @Peildatum IS NULL
			SET @Peildatum = EOMONTH(DATEADD(m, - 1, GETDATE()));

		SET @Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 

		SET	@Start = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
SET @Onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Variabelen = @Variabelen
					,@Bericht = @Onderwerp

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Welke datumreeks te wissen en te vullen ?';
----------------------------------------------------------------------------------- 

		DROP TABLE IF EXISTS #DatumReeks
		;
		SELECT T.datum
		INTO #DatumReeks
		FROM [Dashboard].[Indicator] AS IND
			LEFT OUTER JOIN Dashboard.Frequentie AS FREQ
				ON IND.fk_frequentie_id = FREQ.id
			JOIN empire_dwh.dbo.tijd AS T
				ON 1 = 1
		WHERE 1=1
		AND		YEAR(T.datum) = YEAR(GETDATE())
		AND		IND.id = @IndicatorID
		AND		(
					(MONTH(T.datum) = MONTH(GETDATE()) AND COALESCE(freq.Omschrijving, 'Maandelijks') IN ('Dagelijks', 'Maandelijks'))
			OR		(DATEPART(ISO_WEEK,T.datum) = DATEPART(ISO_WEEK,GETDATE()) AND COALESCE(freq.Omschrijving, 'Wekelijks') ='Wekelijks')
				)

		SET @Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
											+ 'Datumreeks ' + FORMAT((SELECT MIN(datum) FROM #DatumReeks), 'dd-MM-yyyy','nl-NL') + ' - '  + FORMAT((SELECT MAX(datum) FROM #DatumReeks), 'dd-MM-yyyy','nl-NL') 

		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Variabelen

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Wissen regels';
----------------------------------------------------------------------------------- 
		DELETE	
		FROM	staedion_dm.dashboard.realisatiedetails  
		WHERE	fk_indicator_id  = @IndicatorID
		AND		Datum IN (SELECT datum FROM #DatumReeks)
		;

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

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
					,IIF([Rookmelders (aanwezigheid,locatie)] = 'Aanwezig', 1, 0) AS [Waarde]
					,NULL AS [Teller]
					,NULL AS [Noemer]
					,IIF([Plaatsingsdatum rookmelder] <> '', 
					 CONVERT(DATE, NULLIF(CONCAT(RIGHT(NULLIF([Plaatsingsdatum rookmelder], ''), 4), '-',
							RIGHT(CONCAT(0, SUBSTRING(NULLIF([Plaatsingsdatum rookmelder], ''),CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))+1, 
							CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''),CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))+1) -CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))-1)), 2),
							'-', LEFT([Plaatsingsdatum rookmelder], CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))-1)), '-0'), 120)
					,NULL) AS [Datum]
					,@IndicatorID AS [fk_indicator_id]
					,CONCAT([clusternummer], '; ', [straat], '; ', [huisnummer], '; ', [toevoegsel], '; ', [postcode], '; ', [plaats]) AS [Omschrijving] 
					,NULLIF([corpodata type], '') AS [Detail_01]
					,NULLIF([Werkgebied], '') AS [Detail_02]
					,NULLIF([Werkgebied Electra], '') AS [Detail_03]
					,IIF([Rookmelders (aanwezigheid,locatie)] = 'Aanwezig', 'Ja', 'Nee') AS [Detail_04]
					,NULLIF([Garantiepartij rookmelder], '') AS [Detail_05]
					,NULLIF([Merk rookmelder], '') AS [Detail_06]
					,NULLIF([Type rookmelder], '') AS [Detail_07] 
					,NULLIF(CONCAT(RIGHT(NULLIF([Plaatsingsdatum rookmelder], ''), 4), '-',
							RIGHT(CONCAT(0, SUBSTRING(NULLIF([Plaatsingsdatum rookmelder], ''),CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))+1, 
							CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''),CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))+1) -CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))-1)), 2)), '-0') AS [Detail_08]
					,NULLIF([Aantal rookmelders], '') AS [Detail_09]
					,[clusternummer] AS [Detail_10]
					,[eenheidnr] AS [eenheidnummer]
					,NULL AS [bouwbloknummer]
					,[clusternummer] AS [clusternummer]
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
			FROM [Algemeen].[Rookmelders]
			WHERE EOMONTH(IIF([Plaatsingsdatum rookmelder] <> '', 
					 CONVERT(DATE, NULLIF(CONCAT(RIGHT(NULLIF([Plaatsingsdatum rookmelder], ''), 4), '-',
							RIGHT(CONCAT(0, SUBSTRING(NULLIF([Plaatsingsdatum rookmelder], ''),CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))+1, 
							CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''),CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))+1) -CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))-1)), 2),
							'-', LEFT([Plaatsingsdatum rookmelder], CHARINDEX('-',NULLIF([Plaatsingsdatum rookmelder], ''))-1)), '-0'), 120)
					,NULL)) = EOMONTH(@Peildatum)

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

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

END CATCH



GO
