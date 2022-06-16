SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Dashboard].[sp_load_kpis_serviceabonnementen] (
  @peildatum DATE = '20220131', @WelkeChildPackageUitvoeren AS NVARCHAR(MAX) =  N'[{"IndicatorID": 2200, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 2220, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 2240, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 2260, "UitvoerenJaNee": "Nee"}]'
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
20220429 RST Initieele versie
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
-- meerdere id's + deel wekelijks en deel maandelijks
exec staedion_dm.[Dashboard].[sp_load_kpis_serviceabonnementen] '20220131', N'[{"IndicatorID": 2200, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 2220, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 2240, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 2260, "UitvoerenJaNee": "Nee"}]'
update staedion_dm.dashboard.indicator set fk_frequentie_id = 2 where id in (510,520,530) -- wekelijks
update staedion_dm.dashboard.indicator set fk_frequentie_id = 1 where id in (510,520,530) -- dagelijks
update staedion_dm.dashboard.indicator set fk_frequentie_id = 3 where id in (520) -- maandelijks
update staedion_dm.dashboard.indicator set fk_frequentie_id = 4 where id in (510,520,530) -- 4-maandelijks

select * from staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] order by Begintijd desc

select top 10 * from staedion_dm.dashboard.realisatiedetails where fk_indicator_id in (2200,2220,2240,2260) and year(datum) = 2022 


select 'accp', fk_indicator_id, avg(waarde),count(*) from staedion_dm.dashboard.realisatiedetails where fk_indicator_id in (2200,2220,2240,2260) and year(datum) = 2022 group by fk_indicator_id 
union
select 'prod', fk_indicator_id, avg(waarde),count(*) from [s-dwh2012-db].staedion_dm.dashboard.realisatiedetails where fk_indicator_id in (510,520,530) and year(datum) = 2022 group by fk_indicator_id 
order by 2,1
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
		DECLARE @Bron NVARCHAR(255) = OBJECT_NAME(@@PROCID)										
		DECLARE @Variabelen NVARCHAR(MAX) = @WelkeChildPackageUitvoeren							
		DECLARE @Categorie AS NVARCHAR(255) = COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'?')			
		DECLARE @Start AS DATETIME																	
		DECLARE @Finish AS DATETIME			
		DECLARE @Cursor_indicatorid AS int
		DECLARE @Cursor_begin_datum AS DATE
		DECLARE @Cursor_eind_datum AS DATE
		DECLARE @AantalRecords AS INT
        DECLARE @Bericht AS NVARCHAR(255)
		DECLARE @BerichtInclVariabelen AS NVARCHAR(510)

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
		SELECT IND.id AS IndicatorID, T.datum, IND.Details
		INTO #DatumReeks
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
		DROP TABLE IF Exists #boekingen_serviceabonnementen;

    SELECT 
      Rekeningnr = GA.No_
     ,Rekeningnaam = GA.NAME
     ,Broncode = GL.[Source Code]
     ,Boekdatum = GL.[Posting Date]
     ,Clusternummer = GL.Clusternr_
     ,Bedrag = convert(FLOAT, sum(GL.Amount))
    INTO #boekingen_serviceabonnementen
    FROM empire_data.dbo.[Staedion$G_L_Entry] AS GL
    JOIN empire_data.dbo.[Staedion$G_L_Account] AS GA ON 
      GA.No_ = GL.[G_L Account No_]
    WHERE EOMONTH(GL.[Posting Date]) = EOMONTH(@peildatum)
    AND GA.No_ IN ('A815380','A816340','A815400','A816380')
    AND GL.[Source Code] in ('DO','FDAGB','INKOOP','PROLON','RESDAGB','TEGENBOEK','VOORWDEBKN')
    GROUP BY 
        GA.No_
      , GA.NAME
	    , GL.[Source Code]
	    , GL.[Posting Date]
      , GL.Clusternr_
    ORDER BY
        GA.No_

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(COALESCE(@AantalRecords,0), 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
			@Categorie = @Categorie
			,@DatabaseObject = @Bron
			,@Bericht = @Bericht
                  
-----------------------------------------------------------------------------------
SET @onderwerp = 'Loop door indicatoren';
----------------------------------------------------------------------------------- 
		
		Declare kpi CURSOR FOR 
			SELECT  ind.IndicatorID, MIN(T.datum) AS begin_datum, MAX(T.datum) AS eind_datum
			FROM	#Parameters AS IND
			JOIN	#DatumReeks AS T
			ON		IND.IndicatorID = T.IndicatorID
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
			SELECT
          CONVERT(DATETIME ,GETDATE(), 120) AS [Laaddatum]
			  , case when @Cursor_indicatorid = 2220 then bs.Bedrag * -1.00000 else bs.bedrag end as [Waarde]
				, NULL AS [Teller]
				, NULL AS [Noemer]
				, @Peildatum AS [Datum]
				, @Cursor_indicatorid AS [fk_indicator_id]
				, Rekeningnr + ' - ' + Rekeningnaam + ' - ' + Broncode + ' - ' + Clusternummer AS omschrijving
				, Rekeningnr + ' - ' + Rekeningnaam AS [Detail_01]
				, Broncode AS [Detail_02]
				, Clusternummer AS [Detail_03]
				, null AS [Detail_04]
				, null AS [Detail_05]
				, null AS [Detail_06] 
				, null AS [Detail_07]
				, null AS [Detail_08]
				, null AS [Detail_09]
				, null AS [Detail_10]
				, null AS [eenheidnummer]
				, null AS [bouwbloknummer]
				, clusternummer AS [clusternummer]
				, NULL AS [klantnummer]
				, NULL AS [volgnummer]
				, NULL AS [relatienummer]
				, NULL AS [dossiernummer]
				, NULL AS [betalingsregelingnummer]
				, bs.rekeningnr AS [rekeningnummer]
				, NULL AS [documentnummer]
				, NULL AS [leveranciernummer]
				, NULL AS [werknemernummer]
				, NULL AS [projectnummer]
				, NULL AS [verzoeknummer]
				, NULL AS [ordernummer]
				, NULL AS [taaknummer]
				, NULL AS [overig]
			FROM #boekingen_serviceabonnementen AS bs
			WHERE @Cursor_indicatorid = 2220
      OR (@Cursor_indicatorid = 2240 and Rekeningnr = 'A815380')
            			   
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

END CATCH



GO
