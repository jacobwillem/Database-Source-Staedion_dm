SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Dashboard].[sp_load_kpi_projecten_onderhanden_werk] 
			( @Peildatum AS DATE = NULL
			, @IndicatorID AS INT = 220
			, @LoggingWegschrijven AS BIT = 1) 
AS
/* #############################################################################################################################
EXEC sys.sp_updateextendedproperty @name = N'MS_Description'
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
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv eerdere functie het kpi-framework 
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Dashboard'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_projecten_onderhanden_werk';
GO
exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'Dashboard','sp_load_kpi_projecten_onderhanden_werk'

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220118 JvdW Opzet specificaties voor 2022 + bestaande datastructuur Microsoft Lists
20210119 JvdW Toevoeging
20220204 JvdW Toevoeging prognoses voor resterend deel van het jaar
20220207 JvdW Onderliggende functie bevatte gekke telfout bij dubbele regels in brontabel - andere opzet + extra kolommen voor detailvelden
Details te vullen: Project, TypeProject, Projectmanager 
20220216 JvdW Prognose einde jaar in bijv peilmaand jan moet je ook wegschrijven met peildatum januari om 'm in dashboard terug te zien
20220308 JvdW: prognose werkt anders dan ik dacht
> huidige maand moet totaal geven per 31-12 ipv elke komende maand een berekening van wat er nu in staat (kan toevallig met deze kpi wel)
20220511 JvdW kpi 225 nieuw toegevoegd in deze (teveel moeite om toe te voegen in sp_load_kpis_projecten)
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_kpi_projecten_onderhanden_werk%' ORDER BY begintijd desc
exec staedion_dm.[Dashboard].[sp_load_kpi_projecten_onderhanden_werk] '20220131'
############################################################################################################################# */
;

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
				@Finish as DATETIME,
				@Maandnummer AS smallint

		IF @Peildatum IS NULL
			SET @Peildatum = EOMONTH(DATEADD(m, - 1, GETDATE()));

		SET @Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(10)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
											--+ '@LoggingWegschrijven = ' + COALESCE(CAST(@LoggingWegschrijven AS NVARCHAR(1)),'null')													

		SET	@Start = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
SET @Onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Variabelen = @Variabelen
					,@Bericht = @Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijven

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
					(MONTH(T.datum) = MONTH(@Peildatum) AND COALESCE(freq.Omschrijving, 'Maandelijks') IN ('Dagelijks', 'Maandelijks'))
			OR		(DATEPART(ISO_WEEK,T.datum) = DATEPART(ISO_WEEK,@Peildatum) AND COALESCE(freq.Omschrijving, 'Wekelijks') ='Wekelijks')
				)

		SET @Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
											+ 'Datumreeks ' + FORMAT((SELECT MIN(datum) FROM #DatumReeks), 'dd-MM-yyyy','nl-NL') + ' - '  + FORMAT((SELECT MAX(datum) FROM #DatumReeks), 'dd-MM-yyyy','nl-NL') + ' ; ' 
											+ '@LoggingWegschrijven = ' + COALESCE(CAST(@LoggingWegschrijven AS NVARCHAR(1)),'null')	

		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Variabelen
					,@WegschrijvenOfNiet = @LoggingWegschrijven

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
					,@WegschrijvenOfNiet = @LoggingWegschrijven

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Toevoegen regels';
----------------------------------------------------------------------------------- 
		INSERT INTO [Dashboard].[RealisatieDetails]
					([Laaddatum]
					,[Waarde]
					,Datum
					,[Omschrijving]
					,fk_indicator_id
					,Detail_01
					,Detail_02
					,Detail_03
					,Detail_04
					,Detail_05
					,Detail_06
					,Detail_07
					,Detail_08
					,Detail_09
					,Detail_10
					,eenheidnummer
					,bouwbloknummer
					,clusternummer 
					,klantnummer 
					,volgnummer
					,relatienummer
					,dossiernummer
					,betalingsregelingnummer
					,rekeningnummer
					,documentnummer
					,leveranciernummer
					,werknemernummer
					,projectnummer
					,verzoeknummer
					,ordernummer
					,taaknummer
					,overig
					)
			SELECT	[Laaddatum] = CONVERT(DATETIME ,GETDATE(), 120)
					,[Waarde] = BRON.Onderhandenwerk
					,[Datum] = @Peildatum
					,[Omschrijving] = BRON.Omschrijving
					,@IndicatorID
					,BRON.Projectnummer AS Detail_01
					,BRON.Projectmanager AS Detail_02
					,BRON.Typeproject AS Detail_03
					,NULL AS Detail_04
					,NULL AS Detail_05
					,NULL AS Detail_06
					,NULL AS Detail_07
					,NULL AS Detail_08
					,NULL AS Detail_09
					,NULL AS Detail_10
					,NULL AS eenheidnummer
					,NULL AS bouwbloknummer
					,LEFT(BRON.[FT-cluster],7) AS clusternummer 
					,NULL AS klantnummer 
					,NULL AS volgnummer
					,NULL AS relatienummer
					,NULL AS dossiernummer
					,NULL AS betalingsregelingnummer
					,NULL AS rekeningnummer
					,NULL AS documentnummer
					,NULL AS leveranciernummer
					,NULL AS werknemernummer
					,BRON.Projectnummer AS projectnummer
					,NULL AS verzoeknummer
					,NULL AS ordernummer
					,NULL AS taaknummer
					,NULL AS overig
					-- select * 
			FROM	staedion_dm.Projecten.fn_AantallenOnderhandenWerkMicrosoftList (@Peildatum) AS BRON		
			WHERE	(
						([TypeProject] IN ( 'Nieuwbouw', 'Transformatie') and @IndicatorID = 220 )
						or
						([TypeProject] IN ( 'Renovatie') and @IndicatorID = 225 )
					)
			AND		BRON.Onderhandenwerk IS NOT NULL
			AND		YEAR(@Peildatum)>= 2022
            ;

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijven

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Wissen prognoses dit jaar';
----------------------------------------------------------------------------------- 
		-- Prognose wissen
		delete
		FROM Dashboard.Prognose 
		WHERE fk_indicator_id = @IndicatorID 
		AND YEAR(Datum) = YEAR(@Peildatum)
		AND MONTH(Datum) = MONTH(@Peildatum)
		;

				SET @AantalRecords = @@rowcount;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = @Categorie
							,@DatabaseObject = @Bron
							,@Bericht = @Bericht
							,@WegschrijvenOfNiet = @LoggingWegschrijven
-----------------------------------------------------------------------------------
SET @Onderwerp = 'Toevoegen prognoses voor resterend deel van het jaar';
----------------------------------------------------------------------------------- 
		-- prognose einde jaar in huidige maand vastleggen
		SET @Maandnummer = MONTH(@Peildatum);
				
				INSERT INTO Dashboard.Prognose (fk_indicator_id,datum, waarde,laaddatum, omschrijving)
				SELECT	@IndicatorID
						,@Peildatum
						,Waarde =  SUM(COALESCE(BRON.Onderhandenwerk,0))
						,Laaddatum = CONVERT(DATE,GETDATE())
						,'Ontleend aan Aantallen Start Bouw & Oplevering'	
				--FROM	staedion_dm.Projecten.fn_AantallenOnderhandenWerkMicrosoftList (EOMONTH(DATEFROMPARTS(YEAR(@Peildatum),@Maandnummer,1))) AS BRON	
				FROM	staedion_dm.Projecten.fn_AantallenOnderhandenWerkMicrosoftList (DATEFROMPARTS(YEAR(@Peildatum),12,31)) AS BRON	
				WHERE BRON.Onderhandenwerk IS not NULL
					and (
							([TypeProject] IN ( 'Nieuwbouw', 'Transformatie') and @IndicatorID = 220 )
							or
							([TypeProject] IN ( 'Renovatie') and @IndicatorID = 225 )
						)
                AND		YEAR(@Peildatum)>= 2022
				;
				SET @AantalRecords = @@rowcount;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
				SET @Variabelen = '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null')  + ' @Indicator = '+ format(@IndicatorID,'N0')
				SET @Bericht = @Bericht + ' ' +@Variabelen;

				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = @Categorie
							,@DatabaseObject = @Bron
							,@Bericht = @Bericht
							,@WegschrijvenOfNiet = @LoggingWegschrijven
							,@Variabelen = @Variabelen

		SET @Maandnummer =@Maandnummer + 1;

		---- prognoses in resterende maanden vastleggen
		--WHILE @Maandnummer <= 12
			
		--	BEGIN
		--		SET @Peildatum = EOMONTH(DATEFROMPARTS(YEAR(@Peildatum),@Maandnummer,1))
		--		;
		--		INSERT INTO Dashboard.Prognose (fk_indicator_id,datum, waarde,laaddatum, omschrijving)
		--		SELECT	@IndicatorID
		--				,@Peildatum
		--				,Waarde =  SUM(COALESCE(BRON.Onderhandenwerk,0))
		--				,Laaddatum = CONVERT(DATE,GETDATE())
		--				,'Ontleend aan Aantallen Start Bouw & Oplevering'	
		--		FROM	staedion_dm.Projecten.fn_AantallenOnderhandenWerkMicrosoftList (@Peildatum) AS BRON	
		--		WHERE BRON.Onderhandenwerk IS not NULL
  --              AND		YEAR(@Peildatum)>= 2022
		--		;
		--		SET @AantalRecords = @@rowcount;
		--		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		--		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		--		SET @Variabelen = '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') 
		--		SET @Bericht = @Bericht + ' ' +@Variabelen;

		--		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
		--					@Categorie = @Categorie
		--					,@DatabaseObject = @Bron
		--					,@Bericht = @Bericht
		--					,@WegschrijvenOfNiet = @LoggingWegschrijven
		--					,@Variabelen = @Variabelen

		--		SET @Maandnummer = @Maandnummer + 1

		--	end

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
					,@WegschrijvenOfNiet = @LoggingWegschrijven

					
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
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv eerdere functie het kpi-framework 
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen', 'SCHEMA', N'Dashboard', 'PROCEDURE', N'sp_load_kpi_projecten_onderhanden_werk', NULL, NULL
GO
