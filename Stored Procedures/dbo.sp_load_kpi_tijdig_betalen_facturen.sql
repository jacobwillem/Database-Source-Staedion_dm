SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_kpi_tijdig_betalen_facturen] 
			( @Peildatum AS DATE = NULL, 
			  @fk_indicator_id AS INT = NULL) 
AS
/* #############################################################################################################################
KPI tijdig betalen facturen bepaald het percentage facturen dat in de periode betaald is binnen 30 dagen (inclusief) gerekend vanaf de documentdatum.

EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'KPI tijdig betalen facturen bepaald het percentage facturen dat in de periode betaald is binnen 30 dagen (inclusief) gerekend vanaf de documentdatum.
Logging van de procedure vindt plaats door de aanroep van staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten].
Dit schrijft de stappen weg naar tabel staedion_dm.[DatabaseBeheer].[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] met parameters
@Bron => Databaseobject
@Variabelen => eventuele parameters bijv peildatum
@Categorie => schemanaam dashboard bijv of kpi of ETL maatwerk, ETL datamart, Power Automate, ETL oud maatwerk, Dataset rapport laden, DatabaseBeheer
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'dbo'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_tijdig_betalen_facturen';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
<20220121> <RvG> <Proceduure aangemaakt>


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

		SET @Variabelen = '@fk_indicator_id = ' + COALESCE(CAST(@fk_indicator_id AS NVARCHAR(10)),'null') + ' ; ' 
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
SET @Onderwerp = 'Ophalen data in tijdelijke tabel';
----------------------------------------------------------------------------------- 
		-- declare @fk_indicator_id int = 2600, @peildatum date = '2022-01-31'
		drop table if exists #det

		select 
			@fk_indicator_id [fk_indicator_id],
			eomonth(fac.[Afgesloten op]) [Datum],
			convert(date, getdate()) [Laaddatum],
			iif(datediff(d, fac.[Boekdatum], fac.[Afgesloten op]) <= 30, 1, 0) [Waarde],
			iif(datediff(d, fac.[Boekdatum], fac.[Afgesloten op]) <= 30, 1, 0) [Teller],
			1 [Noemer],
			concat_ws(';', fac.Factuurnr, fac.Leveranciernr, fac.[Naam leverancier], convert(varchar(10), fac.[Documentdatum], 105)) [Omschrijving],
			format(fac.Documentdatum, 'dd-MM-yyyy') [Detail_01], 
			format(fac.Boekdatum, 'dd-MM-yyyy') [Detail_02], 
			format(fac.[Eerste goedkeuring], 'dd-MM-yyyy HH:mm') [Detail_03], 
			format(fac.[Laatste goedkeuring], 'dd-MM-yyyy HH:mm') [Detail_04], 
			format(fac.[Afgesloten op], 'dd-MM-yyyy') [Detail_05], 
			format(fac.[Aantal geboekte goedkeuringsposten], '#0') [Detail_06], 
			format(fac.Factuurbedrag, '€ #,##0.00', 'nl-NL') [Detail_07],
			format(datediff(d, fac.Documentdatum, fac.[Afgesloten op]), '#0') [Detail_08],
			left(fac.[Geboekte goedkeurders], 255) [Detail_09],
			fac.goedkeuringssoort [Detail_10],
			fac.Factuurnr [documentnummer] ,
			fac.Leveranciernr [leveranciernummer]
		into #det
		from staedion_dm.Financieel.Facturen fac left outer join empire_data.dbo.salesperson_purchaser wkn
		on fac.Inkoper = wkn.Code
		where fac.bedrijf_id = 1 and fac.Documentsoort_id = 2 and
		fac.[Afgesloten op] between dateadd(d, 1 - day(@Peildatum), @peildatum) and eomonth(@Peildatum)

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Wissen detailregels';
----------------------------------------------------------------------------------- 
		-- declare @fk_indicator_id int = 2600, @peildatum date = '2021-03-31'
		DELETE	
		FROM	staedion_dm.dashboard.realisatiedetails  
		WHERE	fk_indicator_id  = @fk_indicator_id
		AND		Datum = @Peildatum;

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Toevoegen detailregels';
----------------------------------------------------------------------------------- 

		INSERT INTO [Dashboard].[RealisatieDetails]
					([fk_indicator_id],
					[Datum],
					[Laaddatum],
					[Waarde],
					[Teller],
					[Noemer],
					[Omschrijving],
					[Detail_01], 
					[Detail_02], 
					[Detail_03], 
					[Detail_04], 
					[Detail_05], 
					[Detail_06], 
					[Detail_07],
					[Detail_08],
					[Detail_09],
					[Detail_10],
					[documentnummer],
					[leveranciernummer])
			SELECT	det.[fk_indicator_id],
				det.[Datum],
				det.[Laaddatum],
				det.[Waarde],
				det.[Teller],
				det.[Noemer],
				det.[Omschrijving],
				det.[Detail_01], 
				det.[Detail_02], 
				det.[Detail_03], 
				det.[Detail_04], 
				det.[Detail_05], 
				det.[Detail_06], 
				det.[Detail_07],
				det.[Detail_08],
				det.[Detail_09],
				det.[Detail_10],
				det.[documentnummer],
				det.[leveranciernummer]
			from #det det

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
SET @Onderwerp = 'Wissen realisatieregels';
----------------------------------------------------------------------------------- 
		DELETE	
		FROM	staedion_dm.dashboard.realisatie 
		WHERE	fk_indicator_id  = @fk_indicator_id
		AND		Datum = @Peildatum;

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Toevoegen realisatieregel';
----------------------------------------------------------------------------------- 
		
		INSERT INTO [Dashboard].[Realisatie]
					([fk_indicator_id],
					[Datum],
					[Waarde],
					[Laaddatum])
			SELECT	det.[fk_indicator_id],
				det.[Datum],
				1.0 * sum(det.[Teller]) / sum(det.[Noemer]),
				det.[Laaddatum]
			from #det det
			group by det.[fk_indicator_id],
				det.[Datum],
				det.[Laaddatum]

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
EXEC sp_addextendedproperty N'MS_Description', N'KPI tijdig betalen facturen bepaald het percentage facturen dat in de periode betaald is binnen 30 dagen (inclusief) gerekend vanaf de documentdatum.
Logging van de procedure vindt plaats door de aanroep van staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten].
Dit schrijft de stappen weg naar tabel staedion_dm.[DatabaseBeheer].[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] met parameters
@Bron => Databaseobject
@Variabelen => eventuele parameters bijv peildatum
@Categorie => schemanaam dashboard bijv of kpi of ETL maatwerk, ETL datamart, Power Automate, ETL oud maatwerk, Dataset rapport laden, DatabaseBeheer
', 'SCHEMA', N'dbo', 'PROCEDURE', N'sp_load_kpi_tijdig_betalen_facturen', NULL, NULL
GO
