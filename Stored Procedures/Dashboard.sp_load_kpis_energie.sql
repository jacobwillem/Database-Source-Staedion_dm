SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [Dashboard].[sp_load_kpis_energie] (
  @peildatum DATE = '20220531', @WelkeChildPackageUitvoeren AS NVARCHAR(MAX) =  N'[{"IndicatorID": 510, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 520, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 521, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 530, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 540, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 541, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 542, "UitvoerenJaNee": "Nee"}, {"IndicatorID": 560, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 580, "UitvoerenJaNee": "Ja"}]'
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
20220202 JvdW logica van dbo.sp_load_kpi_energie omgezet naar sjabloon Dashboard.sp_load_kpis_energie
+ Details: obv Deelvoorraad,Assetmanager,Doelgroep,Huurbeleid,bouwjaar,bouwbloknummer,clusternummer
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
-- meerdere id's + deel wekelijks en deel maandelijks
exec staedion_dm.[Dashboard].[sp_load_kpis_energie] '20220131', N'[{"IndicatorID": 510, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 520, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 521, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 530, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 560, "UitvoerenJaNee": "Ja"}]'
update staedion_dm.dashboard.indicator set fk_frequentie_id = 2 where id in (510,520,530) -- wekelijks
update staedion_dm.dashboard.indicator set fk_frequentie_id = 1 where id in (510,520,530) -- dagelijks
update staedion_dm.dashboard.indicator set fk_frequentie_id = 3 where id in (520) -- maandelijks
update staedion_dm.dashboard.indicator set fk_frequentie_id = 4 where id in (510,520,530) -- 4-maandelijks

select * from staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] order by Begintijd desc

select top 10 * from staedion_dm.dashboard.realisatiedetails where fk_indicator_id in (510,520,530) and year(datum) = 2022 


select 'accp', fk_indicator_id, avg(waarde),count(*) from staedion_dm.dashboard.realisatiedetails where fk_indicator_id in (510,520,530) and year(datum) = 2022 group by fk_indicator_id 
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
		DROP TABLE IF EXISTS #Eenheden
		;
		SELECT eenheidnummer = OGE.Nr_
			   ,CLUS.Clusternr AS clusternummer
			   ,CLUS.Bouwblok AS bouwbloknummer
			   ,CONT.Assetmanager
			   ,Peildatum = getdate()
			   ,OGE.[Construction year] AS bouwjaar
			   ,Huurbeleid = CASE OGE.huurbeleid
					  WHEN 0
							 THEN 'Hoogste bedrag'
					  WHEN 1
							 THEN 'Streefhuur'
					  WHEN 2
							 THEN 'Elementsjabloon'
					  WHEN 3
							 THEN 'Huidige huur'
					  WHEN 4
							 THEN 'Markthuurwaarde'
					  END
			   ,Doelgroep = OGE.[Target Group Code]
         ,Eenheidtype = AE.[Technische type omschrijving]
		into #Eenheden
		FROM empire_data.dbo.Staedion$oge AS OGE
    LEFT JOIN Algemeen.Eenheid as AE ON
      AE.Eenheidnummer = OGE.Nr_ and
      AE.Bedrijf = 'staedion'
		OUTER APPLY empire_staedion_data.[dbo].ITVfnCLusterBouwblok(OGE.Nr_) AS CLUS
		OUTER APPLY staedion_dm.[Eenheden].[fn_ContactbeheerInclNaam](OGE.Nr_) AS CONT
		WHERE OGE.[Common Area] = 0
			   AND OGE.[Begin exploitatie] <> '17530101'
			   AND OGE.[Begin exploitatie] <= getdate()
			   AND (
					  OGE.[Einde exploitatie] = '17530101'
					  OR OGE.[Einde exploitatie] > getdate()
					  )
					  ;
		DROP TABLE IF Exists #energie;
		
		SELECT NULLIF(ELA.[EP1 energiebehoefte],0) AS [EP1 energiebehoefte],
			   NULLIF(ELA.[EP2 fossielenergiegebruik],0) AS [EP2 fossielenergiegebruik],
			   NULLIF(ELA.[CO2 uitstoot],0) AS [CO2 uitstoot],
			   NULLIF(ELA.[EPA Energielabel],'') AS [EPA Energielabel],
         NULLIF(ELA.[EPA Energielabel afgemeld],'') AS [EPA Energielabel afgemeld],
         NULLIF(ELA.[EPA Energielabel pre],'') AS [EPA Energielabel pre],
         NULLIF(ELA.[EP2 EMG Forfaitair],0) AS [EP2 EMG Forfaitair],
         NULLIF(ELA.[Nettowarmtebehoefte],0) AS [Nettowarmtebehoefte],
         NULLIF(ELA.[Nettowarmtebehoefte standaard],0) AS [Nettowarmtebehoefte standaard],
         ELA.[Gasverbruik m3 per jaar] AS [Gasverbruik m3 per jaar],
         ELA.[Status label],
			   Deelvoorraad AS detail_01,
			   Assetmanager AS detail_02,
			   Doelgroep AS detail_03,
			   EENH.Huurbeleid AS detail_04,
			   EENH.bouwjaar AS detail_05,
			   EENH.bouwbloknummer AS detail_06,
			   EENH.clusternummer AS detail_07,
			   NULLIF(ELA.[EPA Energielabel afgemeld],'') AS detail_08,
			   NULLIF(ELA.[EPA Energielabel pre],'') AS detail_09,
			   EENH.Eenheidtype AS detail_10,
			   ELA.[Eenheidnummer],
			   EENH.clusternummer,
			   EENH.bouwbloknummer,
			   EENH.Assetmanager,
			   EENH.Huurbeleid,
			   EENH.Doelgroep
		INTO #Energie
		--select top 10 *
		FROM [s-dwh2012-db].staedion_dm.[Algemeen].[Vabi Energielabel eenheden] AS ELA
			JOIN empire_data.dbo.[Staedion$OGE] AS OGE
				ON OGE.[Nr_] = ELA.[Eenheidnummer]
			JOIN [empire_data].dbo.[Staedion$type] AS TT
				ON TT.[Code] = OGE.[Type]
				   AND TT.Soort = 0
		LEFT OUTER JOIN #Eenheden AS EENH
			ON EENH.[Eenheidnummer] = ELA.[Eenheidnummer]
		WHERE EOMONTH(ELA.Datum) = EOMONTH(@Peildatum)
			  AND TT.[Analysis Group Code] = 'WON ZELF'
			  AND OGE.[Begin exploitatie] <> '17530101'
			  AND OGE.[Begin exploitatie] <= @Peildatum
			  AND
			  (
				  OGE.[Einde exploitatie] >= @Peildatum
				  OR OGE.[Einde exploitatie] = '17530101'
			  )

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
			SELECT	CONVERT(DATETIME ,GETDATE(), 120) AS [Laaddatum]
					,CASE @Cursor_indicatorid 
						WHEN 510 THEN [EP1 energiebehoefte]
						WHEN 520 THEN [EP2 fossielenergiegebruik]
            WHEN 521 THEN [EP2 EMG Forfaitair]
						WHEN 530 THEN [CO2 uitstoot]
            WHEN 541 THEN CASE WHEN [Status label] = 'Afgemeld' AND [EPA Energielabel afgemeld] IN ('E','F','G') THEN 1 ELSE 0 END
            WHEN 542 THEN CASE WHEN [Status label] = 'Pre-label' AND [EPA Energielabel pre] IN ('E','F','G') THEN 1 ELSE 0 END
            WHEN 540 THEN CASE 
                            WHEN [Status label] = 'Afgemeld' AND [EPA Energielabel afgemeld] IN ('E','F','G') THEN 1 
                            WHEN [Status label] = 'Pre-label' AND [EPA Energielabel pre] IN ('E','F','G') THEN 1 
                            ELSE 0
                          END
            WHEN 560 THEN [Nettowarmtebehoefte] - [Nettowarmtebehoefte standaard]
            WHEN 580 THEN CASE WHEN [Gasverbruik m3 per jaar] = 0 then 1 else 0 end
						END AS [Waarde]
					,NULL AS [Teller]
					,NULL AS [Noemer]
					,@Peildatum AS [Datum]
					,@Cursor_indicatorid AS [fk_indicator_id]
					,REPLACE(CONCAT(detail_01,';',detail_02,';',detail_03,';',detail_04,';',detail_05,';',detail_06,';',detail_07,';',detail_08,';',detail_09,';',detail_10), ';;','') AS omschrijving
					,detail_01 AS [Detail_01]
					,detail_02 AS [Detail_02]
					,detail_03 AS [Detail_03]
					,detail_04 AS [Detail_04]
					,detail_05 AS [Detail_05]
					,detail_06 AS [Detail_06] 
					,detail_07 AS [Detail_07]
					,detail_08 AS [Detail_08]
					,detail_09 AS [Detail_09]
					,detail_10 AS [Detail_10]
					,eenheidnummer AS [eenheidnummer]
					,bouwbloknummer AS [bouwbloknummer]
					,clusternummer AS [clusternummer]
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
			FROM #Energie
			WHERE ([EP1 energiebehoefte] IS NOT NULL AND @Cursor_indicatorid = 510)
			OR	  ([EP2 fossielenergiegebruik] IS NOT NULL AND @Cursor_indicatorid = 520)
      OR	  ([EP2 EMG Forfaitair] IS NOT NULL AND @Cursor_indicatorid = 521)
      OR	  ([CO2 uitstoot] IS NOT NULL AND @Cursor_indicatorid = 530)
      OR    ([Status label] = 'Afgemeld' AND [EPA Energielabel afgemeld] IN ('E','F','G') and @Cursor_indicatorid = 541)
      OR    ([Status label] = 'Pre-label' AND [EPA Energielabel pre] IN ('E','F','G') and @Cursor_indicatorid = 542)
      OR    (CASE 
               WHEN [Status label] = 'Afgemeld' and [EPA Energielabel afgemeld] IN ('E','F','G') THEN 1 
               WHEN [Status label] = 'Pre-label' and [EPA Energielabel pre] IN ('E','F','G') THEN 1 
               ELSE 0
             END = 1 and @Cursor_indicatorid = 540
            )
      OR	  ([Nettowarmtebehoefte] IS NOT NULL AND [Nettowarmtebehoefte standaard] IS NOT NULL AND @Cursor_indicatorid = 560)
      OR	  ([Gasverbruik m3 per jaar] is not null AND @Cursor_indicatorid = 580)
            			   
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
