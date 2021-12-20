SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [DatabaseBeheer].[sp_load_kpi_sjabloon VOORSTEL] 
			( @IndicatorID AS INT = NULL
			, @Peildatum AS DATE = NULL
			, @LoggingWegschrijvenOfNiet AS BIT = 1) 
AS
/* #############################################################################################################################
<Bedoeling database vastleggen of in metadata van object, als je dat via onderstaand commando opvoert, is dat terug te vinden in de extended properties van het object en kun je het ook genereren in de database-documentatie>
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon kan gebruikt worden voor nieuwe procedures of het omzetten van oude procedures. Tbv uniformiteit + logging + kans op fouten verminderen.>'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'DatabaseBeheer'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_sjabloon VOORSTEL';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
<JJJJMMDD> <Initialen> <Toelichting>
20211207 JvdW Opzet nav overleg met Martijn en Pepijn
			> zie aantekeningen Teams - data engineers - te ontsluiten databronnen - Stored Procedure.docs
			> oude verwijzingen naar functies/procedures andere database vervangen door verwijzing naar procedures binnen deze database
20211208 JvdW
			> @VerversenVanaf niet gebruiken 
			> Toegevoegd DatabaseBeheer.[sp_load_master VOORSTEL], vergelijk [dbo].[sp_load_kpi], incl:
			> Aldaar verwijzen naar extra kolom(men) indicator-tabel: verversen_vanaf_1_1 | aantal_maanden_te_verversen

Attentiepunten
> check snippet
> check databasebeheer-documentatie
> check kpi-queries die meerdere indicatoren omvatten: bedrijfslasten + sp_load_kpi_energie 
> schaduwdraaien fk_indicator_id 110
> Syntax Postgresql DB proef ?
> Syntax Azure DB proef ?

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
<validatietest: indien relevant vermeld hier bijvoorbeeld een query die checkt op dubbele waarden>
EXEC staedion_dm.[DatabaseBeheer].[<databaseobject>] @IndicatorID  = 0, @Peildatum = null, @VerversenVanaf = null, @LoggingWegschrijvenOfNiet =1

-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%<objectnaam>%' ORDER BY begintijd desc

-- compileertest
EXEC empire_staedion_logic.dbo.dsp_controle_Database_objecten 'staedion_dm'

EXEC staedion_dm.[DatabaseBeheer].[sp_load_kpi_sjabloon VOORSTEL]  @IndicatorID  = 0, @Peildatum = null, @VerversenVanaf = null, @LoggingWegschrijvenOfNiet = 1
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_kpi_sjabloon VOORSTEL%' ORDER BY begintijd desc
delete FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_kpi_sjabloon VOORSTEL%' 
select * from staedion_dm.dashboard.realisatiedetails where fk_indicator_id = 0

--------------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------------
-- Toevoeging info over tabel/view
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Bedoeling databaseobject .....>'
       ,@level0type = N'SCHEMA'
       ,@level0name = '<schemanaam>'
       ,@level1type = N'PROCEDURE'
       ,@level1name = '<databaseobject>';
GO

exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'DatabaseBeheer','sp_load_kpi_sjabloon VOORSTEL'

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
<voeg desgewenst handige queries toe die je gebruikt hebt bij het bouwen en die je bij beheer wellicht nodig kunt hebben>

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
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

-----------------------------------------------------------------------------------
SET @onderwerp = 'Wissen regels';
----------------------------------------------------------------------------------- 
		DELETE	
		from	staedion_dm.dashboard.realisatiedetails  
		WHERE	fk_indicator_id  = @IndicatorID
		and		YEAR(Datum) =YEAR(@Peildatum)
		AND		Datum = @Peildatum
		;

		SET @_AantalRecords = @@rowcount;
		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

-----------------------------------------------------------------------------------
SET @onderwerp = 'Toevoegen regels';
----------------------------------------------------------------------------------- 
		INSERT INTO [Dashboard].[RealisatieDetails]
					([Laaddatum]
					,[Waarde]
					,Datum
					,[Omschrijving]
					,fk_indicator_id
					)
			SELECT	[Laaddatum] = CONVERT(date,GETDATE())
					,[Waarde] = 1
					,[Datum] = @Peildatum
					,[Omschrijving] = 'TEST sjabloon'
					,@IndicatorID

		SET @_AantalRecords = @@rowcount;
		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet


	SET		@finish = CURRENT_TIMESTAMP
	
	--SELECT 1/0
-----------------------------------------------------------------------------------
SET @onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
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

	EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
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
EXEC sp_addextendedproperty N'MS_Description', N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon kan gebruikt worden voor nieuwe procedures of het omzetten van oude procedures. Tbv uniformiteit + logging + kans op fouten verminderen.>', 'SCHEMA', N'DatabaseBeheer', 'PROCEDURE', N'sp_load_kpi_sjabloon VOORSTEL', NULL, NULL
GO
