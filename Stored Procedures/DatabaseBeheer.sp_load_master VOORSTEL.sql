SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [DatabaseBeheer].[sp_load_master VOORSTEL] (
  @peildatum date = '20210131', @WelkeChildPackageUitvoeren AS NVARCHAR(MAX) =  N'[{"IndicatorID": 1, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 5, "UitvoerenJaNee": "Nee"}]'
)
as
/* #############################################################################################################################
<Bedoeling database vastleggen of in metadata van object, als je dat via onderstaand commando opvoert, is dat terug te vinden in de extended properties van het object en kun je het ook genereren in de database-documentatie>
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon voert andere procedures uit met dezelfde peildatum. Tbv uniformiteit + logging + kans op fouten verminderen.>'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'DatabaseBeheer'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_master VOORSTEL';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------
20211208 JvdW Opzet nav overleg met Martijn en Pepijn
			> zie aantekeningen Teams - data engineers - te ontsluiten databronnen - Stored Procedure.docs

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
<validatietest: indien relevant vermeld hier bijvoorbeeld een query die checkt op dubbele waarden>
EXEC staedion_dm.[DatabaseBeheer].[<databaseobject>] @IndicatorID  = 0, @Peildatum = null, @VerversenVanaf = null, @LoggingWegschrijvenOfNiet =1

-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%<objectnaam>%' ORDER BY begintijd desc

-- compileertest
EXEC empire_staedion_logic.dbo.dsp_controle_Database_objecten 'staedion_dm'

EXEC staedion_dm.[DatabaseBeheer].[sp_load_master VOORSTEL]
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load%VOORSTEL%' ORDER BY begintijd desc
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
SET @onderwerp = 'Variabelen definieren tbv logging ed';
----------------------------------------------------------------------------------- 
		DECLARE @_Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID)										-- om mee te geven bij loggen
		DECLARE @_Variabelen NVARCHAR(max)	= @WelkeChildPackageUitvoeren							-- om eenmalig mee te geven bij loggen
		DECLARE @_Categorie AS NVARCHAR(255) = 	COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'?')			-- om eenmalig mee te geven bij loggen: schema-naam om aan te geven dat het om dashboard-, datakwaliteit-procedures gaat of bijv PowerAutomate
		DECLARE @start as DATETIME																	-- om duur procedure te kunnen loggen
		DECLARE @finish as DATETIME																	-- om duur procedure te kunnen loggen

		SET	@start = CURRENT_TIMESTAMP;

		DROP TABLE IF EXISTS #Parameters;
		CREATE TABLE #Parameters (IndicatorID INT, UitvoerenJaNee NVARCHAR(3));

		INSERT INTO #Parameters (IndicatorID, UitvoerenJaNee)
		SELECT *
		FROM OPENJSON(@WelkeChildPackageUitvoeren)
		  WITH (
			id INT 'strict $.IndicatorID',				-- The optional strict prefix in the path specifies that values for the specified properties must exist in the JSON text
			UitvoerenJaNee NVARCHAR(50) '$.UitvoerenJaNee'
		  );

		SET @_Variabelen = '@IndicatorID = ' + COALESCE(@WelkeChildPackageUitvoeren,'null') + ' ; ' 
										+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null')
		
		IF @Peildatum IS NULL
			SET @Peildatum = EOMONTH(DATEADD(m, - 1, GETDATE()));

-----------------------------------------------------------------------------------
SET @onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @onderwerp
					,@Variabelen = @_Variabelen

-----------------------------------------------------------------------------------
SET @onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		
		IF EXISTS (SELECT 1 FROM #Parameters WHERE IndicatorId = 1 AND UitvoerenJaNee = 'Ja')
			BEGIN 
				EXEC staedion_dm.[DatabaseBeheer].[sp_load_kpi_sjabloon VOORSTEL] @IndicatorID  = 0, @Peildatum = null, @LoggingWegschrijvenOfNiet = 1
			END

		IF EXISTS (SELECT 1 FROM #Parameters WHERE IndicatorId = 1 AND UitvoerenJaNee = 'Ja')
			BEGIN 
				EXEC staedion_dm.[DatabaseBeheer].[sp_load_kpi_sjabloon VOORSTEL] @IndicatorID  = 0, @Peildatum = null, @LoggingWegschrijvenOfNiet = 1
			END

	SET		@finish = CURRENT_TIMESTAMP
	
	--SELECT 1/0
-----------------------------------------------------------------------------------
SET @onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @onderwerp

					
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
