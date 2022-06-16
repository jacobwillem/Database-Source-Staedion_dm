SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Dashboard].[sp_load_kpi_gemiddelde_leeftijd_cvketel] 
			( @IndicatorID AS INT = 590
			, @Peildatum AS DATE = '20220131') 
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
		SELECT IND.id, T.datum
		INTO #DatumReeks
		FROM [Dashboard].[Indicator] AS IND
			LEFT OUTER JOIN Dashboard.Frequentie AS FREQ
				ON IND.fk_frequentie_id = FREQ.id
			JOIN empire_dwh.dbo.tijd AS T
				ON 1 = 1
		WHERE 1=1
		AND		YEAR(T.datum) = YEAR(@Peildatum)
		AND		IND.id = @IndicatorID
		AND		(
					(MONTH(T.datum) = MONTH(@Peildatum) AND COALESCE(freq.Omschrijving, 'Maandelijks') IN ('Dagelijks', 'Maandelijks'))
			OR		(DATEPART(ISO_WEEK,T.datum) = DATEPART(ISO_WEEK,@Peildatum) AND COALESCE(freq.Omschrijving, 'Wekelijks') ='Wekelijks')
				)

		SET @Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
											+ 'Datumreeks ' + FORMAT((SELECT MIN(datum) FROM #DatumReeks), 'dd-MM-yyyy','nl-NL') + ' - '  + FORMAT((SELECT MAX(datum) FROM #DatumReeks), 'dd-MM-yyyy','nl-NL') 

		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Variabelen


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
					,DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) / 12 AS [Waarde]
					,NULL AS [Teller]
					,NULL AS [Noemer]
					,@Peildatum AS [Datum]
					,@IndicatorID AS [fk_indicator_id]
					,e.eenheidnummer + ';' + i.description + ';Geinstalleerd op ' + convert(varchar, f.[Install_ Date], 105) as  [Omschrijving] 
					,e.clusternummer AS [Detail_01]
					,e.bouwbloknummer AS [Detail_02]
					,null AS [Detail_03]
					,case
             when i.Description like '%individueel%' then 'Individueel'
             when i.Description like '%collectief%' then 'Collectief'
             else 'Onbekend'
           end AS [Detail_04]
					,e.Eenheidtype AS [Detail_05]
					,NULL AS [Detail_06] 
					,NULL AS [Detail_07]
					,case 
             when DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) < 36 then '01. jonger dan 3 jaar'
             when DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) < 72 then '02. 3 tot 6 jaar'
             when DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) < 108 then '03. 6 tot 9 jaar'
             when DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) < 144 then '04. 9 tot 12 jaar'
             when DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) < 180 then '05. 12 tot 15 jaar'
             when DATEDIFF(mm,nullif(f.[Install_ Date],'17530101'),@Peildatum) >= 180 then '06. 15 jaar of ouder'
           end AS [Detail_08]
					,NULL AS [Detail_09]
					,NULL AS [Detail_10]
					,e.eenheidnummer AS [eenheidnummer]
					,e.bouwbloknummer AS [bouwbloknummer]
					,e.clusternummer AS [clusternummer]
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
      from empire_data.dbo.Staedion$Fixture as f
      join #Eenheden as e on e.eenheidnummer = f.no_
      left outer join empire_data.dbo.[Staedion$Fixture_Item]  as I on 
        I.[Fixture Category]= F.[Category] and 
        I.[Fixture Item] = F.[Fixture Type Code]
      where i.Description like '%ketel%'
      and f.[Install_ Date] > '19000101'
      
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
