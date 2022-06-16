SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Dashboard].[sp_load_kpis_projecten] (
  @peildatum DATE = '20220131', @WelkeChildPackageUitvoeren AS NVARCHAR(MAX) =  N'[{"IndicatorID": 200, "UitvoerenJaNee": "Ja"},{"IndicatorID": 210, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 400, "UitvoerenJaNee": "Ja"}]'
)
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
BRON: Microsoft list (https://staedionict.sharepoint.com/sites/onderhoud-vastgoed/afdelingprojecten/Lists/Aantallen Start Bouw%20 Oplevering)
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Functie [Projecten].[fn_AantallenProjectenMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en en haalt start- en oplever-aantallen op project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum.
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv functie fn_AantallenOnderhandenWerkMicrosoftList het kpi-framework incl prognoses voor resterende maanden
* Stored procedure [Dashboard].[sp_load_kpis_projecten]
Vult adhv functie fn_AantallenProjectenMicrosoftList het kpi-framework voor meerdere kps incl prognoses voor resterende maanden
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen'
		,@level0type = N'SCHEMA'
       ,@level0name = 'Dashboard'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpis_projecten';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
20220308 JvdW: prognose werkt anders dan ik dacht
> huidige maand moet totaal geven per 31-12 ipv elke komende maand een berekening van wat er nu in staat (kan toevallig met deze kpi wel)
20220318 JvdW: realisatie/prognose voor 210 Oplevering nieuwbouw toegevoegd
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Dashboard].[sp_load_kpis_projecten] '20220131', N'[{"IndicatorID": 200, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 400, "UitvoerenJaNee": "Ja"}]'
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
				 @BerichtInclVariabelen AS NVARCHAR(510),
				 @Maandnummer AS SMALLINT,
                 @PeildatumPrognose AS date

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
		DROP TABLE IF EXISTS ##DatumReeks
		;
		SELECT IND.id, T.datum
		INTO ##DatumReeks
		FROM [Dashboard].[Indicator] AS IND
			LEFT OUTER JOIN Dashboard.Frequentie AS FREQ
				ON IND.fk_frequentie_id = FREQ.id
			JOIN empire_dwh.dbo.tijd AS T
				ON 1 = 1
		WHERE 1=1
		AND		YEAR(T.datum) = YEAR(GETDATE())
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
			JOIN	##DatumReeks AS T
			ON		1=1
			WHERE	UitvoerenJaNee = 'Ja'
			GROUP BY ind.IndicatorID
			ORDER BY ind.IndicatorID

			OPEN kpi

			FETCH NEXT FROM kpi INTO @Cursor_indicatorid, @Cursor_begin_datum, @Cursor_eind_datum

			WHILE @@FETCH_STATUS = 0

			BEGIN         
				-----------------------------------------------------------------------------------
				SET @Onderwerp = 'Wissen regels realisatiedetails';
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
				SET @Onderwerp = 'Toevoegen regels realisatiedetails';
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
					,[aantal] AS [Waarde]
					,NULL AS [Teller]
					,NULL AS [Noemer]
					,@Peildatum AS [Datum]
					,@Cursor_indicatorid AS [fk_indicator_id]
					,BASIS.Omschrijving as [Omschrijving] 
					,BASIS.Projectnummer AS [Detail_01]
					,BASIS.Projectmanager AS [Detail_02]
					,BASIS.TypeProject AS [Detail_03]
					,NULL AS [Detail_04]
					,NULL AS [Detail_05]
					,NULL AS [Detail_06] 
					,NULL AS [Detail_07]
					,NULL AS [Detail_08]
					,NULL AS [Detail_09]
					,NULL AS [Detail_10]
					,NULL AS [eenheidnummer]
					,NULL AS [bouwbloknummer]
					,case when left(BASIS.[FT-cluster],7) like 'FT-[0-9][0-9][0-9][0-9]%' then left(BASIS.[FT-cluster],7) else '' end     AS [clusternummer]
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
			--declare @Peildatum as date = '20220131' SELECT * 
			FROM	[Projecten].fn_AantallenProjectenMicrosoftList (@peildatum) AS BASIS
			WHERE	(
						(BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') and BASIS.StartOplevering = 'Start' and @Cursor_indicatorid = 200 )
					OR	(BASIS.[TypeProject] NOT IN ('Nieuwbouw','Transformatie') and BASIS.StartOplevering = 'Start' and @Cursor_indicatorid = 400)
					OR  (BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') and  StartOplevering = 'Oplevering' and @Cursor_indicatorid = 210)
						)
					and		BASIS.Jaar = YEAR(@Peildatum)
					and		BASIS.Peildatum = @Peildatum			-- data ophalen van de laatste peildatum uit Microsoft Lists (deze tabel wordt gesnapshot)

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
					SET @Onderwerp = 'Wissen prognose';
					----------------------------------------------------------------------------------- 
					-- Prognose wissen
					delete
					FROM Dashboard.Prognose 
					WHERE fk_indicator_id = @Cursor_indicatorid 
					AND YEAR(Datum) = YEAR(@Peildatum)
					AND MONTH(Datum) = MONTH(@Peildatum)
					;
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
					SET @Onderwerp = 'Toevoegen prognose huidige maand (Einde jaar)';
					-----------------------------------------------------------------------------------
					SET @PeildatumPrognose = @Peildatum
					SET @Maandnummer = MONTH(@PeildatumPrognose);

							INSERT INTO Dashboard.Prognose (fk_indicator_id,datum, waarde,laaddatum, omschrijving)
							SELECT	@Cursor_indicatorid
									,@PeildatumPrognose
									,Waarde =  SUM(BASIS.Aantal)
									,Laaddatum = CONVERT(DATE,GETDATE())
									,'Ontleend aan Aantallen Start Bouw & Oplevering'	
							--FROM	[Projecten].fn_AantallenProjectenMicrosoftList (EOMONTH(DATEFROMPARTS(YEAR(@Peildatum),@Maandnummer,1))) AS BASIS
							FROM	[Projecten].fn_AantallenProjectenMicrosoftList (DATEFROMPARTS(YEAR(@Peildatum),12,31)) AS BASIS
							WHERE	(
										(BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') and BASIS.StartOplevering = 'Start' and @Cursor_indicatorid = 200 )
									OR	(BASIS.[TypeProject] NOT IN ('Nieuwbouw','Transformatie') and BASIS.StartOplevering = 'Start' and @Cursor_indicatorid = 400)
									OR  (BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') and  StartOplevering = 'Oplevering' and @Cursor_indicatorid = 210)
										)
							;
							SET @AantalRecords = @@rowcount;
							SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
							SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
							SET @Variabelen = '@PeildatumPrognose = ' + COALESCE(format(@PeildatumPrognose,'dd-MM-yyyy','nl-NL'),'null') 
							SET @Bericht = @Bericht + ' ' +@Variabelen;

							EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
										@Categorie = @Categorie
										,@DatabaseObject = @Bron
										,@Bericht = @Bericht
										,@Variabelen = @Variabelen

					--SET @Maandnummer = @Maandnummer+1;

					--WHILE @Maandnummer <= 12
			
					--	BEGIN
					--		SET @PeildatumPrognose = EOMONTH(DATEFROMPARTS(YEAR(@PeildatumPrognose),@Maandnummer,1))
					--		;
					--		INSERT INTO Dashboard.Prognose (fk_indicator_id,datum, waarde,laaddatum, omschrijving)
					--		SELECT	@Cursor_indicatorid
					--				,@PeildatumPrognose
					--				,Waarde =  SUM(BASIS.Aantal)
					--				,Laaddatum = CONVERT(DATE,GETDATE())
					--				,'Ontleend aan Aantallen Start Bouw & Oplevering'	
					--		FROM	[Projecten].fn_AantallenProjectenMicrosoftList (@PeildatumPrognose) AS BASIS
					--		WHERE	(
					--					(BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') and  @Cursor_indicatorid = 200 )
					--				OR	(BASIS.[TypeProject] NOT IN ('Nieuwbouw','Transformatie') and  @Cursor_indicatorid = 400)
					--					)
					--		and		BASIS.StartOplevering = 'Start'
					--		;
					--		SET @AantalRecords = @@rowcount;
					--		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
					--		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
					--		SET @Variabelen = '@PeildatumPrognose = ' + COALESCE(format(@PeildatumPrognose,'dd-MM-yyyy','nl-NL'),'null') 
					--		SET @Bericht = @Bericht + ' ' +@Variabelen;

					--		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					--					@Categorie = @Categorie
					--					,@DatabaseObject = @Bron
					--					,@Bericht = @Bericht
					--					,@Variabelen = @Variabelen

					--		SET @Maandnummer = @Maandnummer + 1

					--	END

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

END CATCH



GO
EXEC sp_addextendedproperty N'MS_Description', N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
BRON: Microsoft list (https://staedionict.sharepoint.com/sites/onderhoud-vastgoed/afdelingprojecten/Lists/Aantallen Start Bouw%20 Oplevering)
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Functie [Projecten].[fn_AantallenProjectenMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en en haalt start- en oplever-aantallen op project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum.
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv functie fn_AantallenOnderhandenWerkMicrosoftList het kpi-framework incl prognoses voor resterende maanden
* Stored procedure [Dashboard].[sp_load_kpis_projecten]
Vult adhv functie fn_AantallenProjectenMicrosoftList het kpi-framework voor meerdere kps incl prognoses voor resterende maanden
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen', 'SCHEMA', N'Dashboard', 'PROCEDURE', N'sp_load_kpis_projecten', NULL, NULL
GO
