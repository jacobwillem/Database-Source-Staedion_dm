SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_load_kpi_verhuringen_doelgroep] 
			( @Peildatum AS DATE = NULL,
			  @IndicatorID AS INT = NULL) 
AS
/* #############################################################################################################################
<Bedoeling database vastleggen of in metadata van object, als je dat via onderstaand commando opvoert, is dat terug te vinden in de extended properties van het object en kun je het ook genereren in de database-documentatie>
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon kan gebruikt worden voor nieuwe procedures of het omzetten van oude procedures. 
Tbv uniformiteit + logging + kans op fouten verminderen.>
Logging van de procedure vindt plaats door de aanroep van staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten].
Dit schrijft de stappen weg naar tabel staedion_dm.[DatabaseBeheer].[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] met parameters
@Bron => Databaseobject
@Variabelen => eventuele parameters bijv peildatum
@Categorie => schemanaam dashboard bijv of kpi of ETL maatwerk, ETL datamart, Power Automate, ETL oud maatwerk, Dataset rapport laden, DatabaseBeheer
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'DatabaseBeheer'
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
<validatietest: indien relevant vermeld hier bijvoorbeeld een query die checkt op dubbele waarden>

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
<voeg desgewenst handige queries toe die je gebruikt hebt bij het bouwen en die je bij beheer wellicht nodig kunt hebben>

############################################################################################################################# */


BEGIN TRY
		SET NOCOUNT on
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
SET @Onderwerp = 'Wissen regels';
----------------------------------------------------------------------------------- 
		DELETE	
		FROM	staedion_dm.dashboard.realisatiedetails  
		WHERE	fk_indicator_id  = @IndicatorID
		AND		YEAR(Datum) =YEAR(@Peildatum)
		AND		EOMONTH(Datum) = EOMONTH(@Peildatum);

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
					([fk_indicator_id],
					[Datum],
					[Laaddatum], 
					[Waarde],
					[Omschrijving],
					[Detail_01],
					[Detail_02],
					[Detail_03],
					[Detail_04],
					[Detail_05],
					[Detail_06],
					[Detail_07],
					[Detail_08],
					[eenheidnummer],
					[bouwbloknummer],
					[clusternummer]
					)
			SELECT  [fk_indicator_id] = @IndicatorID,
					[Datum] = FORMAT([svh_huurcontract_getekend], 'yyyyMMdd'), 
					[Laaddatum] = CONVERT(DATETIME, GETDATE(), 120), 
					[Waarde] = [svh_aantal],
					[Omschrijving] = CONCAT_WS(';', FORMAT([svh_huurcontract_getekend], 'dd-MM-yyyy'), 
										--[emp_oge], REPLACE(CONCAT([emp_straatnaam], ' ', [emp_huisnr], ' ', [emp_toevoegsel]), '  ', ' '),
										[emp_postcode], [emp_plaats], [svh_verhuur_doelstelling]
										),
					[Detail_01] = [svh_verhuur_doelstelling],
					[Detail_02] = [svh_matching_reden],
					[Detail_03] = [emp_plaats],
					[Detail_04] = [emp_ft_cluster],
					[Detail_05] = [emp_eenheid_omschrijving],
					[Detail_06] = [svh_woning_type],
					[Detail_07] = [svh_huishoud_grootte],
					[Detail_08] = CASE
									WHEN [svh_huishoud_grootte] = 1 THEN '1'
									WHEN [svh_huishoud_grootte] = 2 THEN '2'
									WHEN [svh_huishoud_grootte] = 3 THEN '3'
									WHEN [svh_huishoud_grootte] = 4 THEN '4'
									WHEN [svh_huishoud_grootte] > 4 THEN '4+'
									ELSE 'Onbekend'
								  END,
					[eenheidnummer] = [emp_oge],
					[bouwbloknummer] = [emp_bb_cluster],
					[clusternummer] = [emp_ft_cluster]
			FROM [staedion_dm].[Verhuur].[Doelgroep]
			WHERE EOMONTH([svh_huurcontract_getekend]) = EOMONTH(@peildatum) AND 
			(
			 (
			  (@IndicatorID = 180 AND [svh_verhuur_doelstelling] IN ('Statushouder', 'Convenant') AND emp_plaats IN ('DEN HAAG', '''S-GRAVENHAGE', '''S GRAVENHAGE')) OR
			  (@IndicatorID = 180 AND [svh_verhuur_doelstelling] IN ('Statushouder') AND emp_plaats IN ('PIJNACKER', 'NOOTDORP', 'PIJNACKER-NOOTDORP', 'PIJNACKER NOOTDORP'))
			 ) OR 
			 (@IndicatorID = 181 AND [svh_verhuur_doelstelling] = 'Statushouder' AND emp_plaats IN ('DEN HAAG', '''S-GRAVENHAGE', '''S GRAVENHAGE', 'PIJNACKER', 'NOOTDORP', 'PIJNACKER-NOOTDORP', 'PIJNACKER NOOTDORP')) OR 
			 (@IndicatorID = 182 AND [svh_verhuur_doelstelling] = 'Statushouder' AND emp_plaats IN ('DEN HAAG', '''S-GRAVENHAGE', '''S GRAVENHAGE')) OR 
			 (@IndicatorID = 183 AND [svh_verhuur_doelstelling] = 'Statushouder' AND emp_plaats IN ('PIJNACKER', 'NOOTDORP', 'PIJNACKER-NOOTDORP', 'PIJNACKER NOOTDORP')) OR 
			 (@IndicatorID = 185 AND [svh_verhuur_doelstelling] = 'Convenant' AND emp_plaats IN ('DEN HAAG', '''S-GRAVENHAGE', '''S GRAVENHAGE', 'PIJNACKER', 'NOOTDORP', 'PIJNACKER-NOOTDORP', 'PIJNACKER NOOTDORP')) OR 
			 (@IndicatorID = 186 AND [svh_verhuur_doelstelling] = 'Convenant' AND emp_plaats IN ('DEN HAAG', '''S-GRAVENHAGE', '''S GRAVENHAGE')) OR 
			 (@IndicatorID = 187 AND [svh_verhuur_doelstelling] = 'Convenant' AND emp_plaats IN ('PIJNACKER', 'NOOTDORP', 'PIJNACKER-NOOTDORP', 'PIJNACKER NOOTDORP'))
			 )



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
