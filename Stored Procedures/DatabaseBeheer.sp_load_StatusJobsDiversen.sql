SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [DatabaseBeheer].[sp_load_StatusJobsDiversen] 
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Governance: Job actuele status databronnen en belangrijke ververs
----------------------------------------------------------------------------------------------------------------------------------
-- empire_data
-- verversen mutatiehuur
-- verversen verplichtingen
-- verversen topdesk 
-- meest recente bijwerking toegerekende posten
Zie table Databasebeheer.StatusJobsDiversen
Zie view Databasebeheer.vw_StatusJobsDiversen'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Databasebeheer'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_StatusJobsDiversen';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220303 JvdW aangemaakt
20220429 JvdW historie werd niet volledig bijgewerkt
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec [Databasebeheer].[sp_load_StatusJobsDiversen] 

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
SET @Onderwerp = 'Toevoegen regels staedion$Job Queue Log Entry voor zover nog niet opgevoerd vandaag';
----------------------------------------------------------------------------------- 
		WITH cte_alle_regels
		AS (SELECT LOGB.[Description] as Jobnaam,
				   CASE LOGB.[Status]
					   WHEN 0 THEN
						   'Klaar'
					   WHEN 1 THEN
						   'In verwerking'
					   WHEN 2 THEN
						   'Fout'
					   WHEN 3 THEN
						   'Afwachten'
					   WHEN 4 THEN
						   'Voltooid'
				   END AS [Status],
				   LOGB.[Start Date_Time],
				   LOGB.[End Date_Time] as [Meest recente tijdstip],
				   LOGB.[User ID],
				   LOGB.[Error message],
				   row_number() over (partition by LOGB.[Description]
									  order by LOGB.[Start Date_Time] desc
									 ) AS Volgnr,
				   DATEDIFF(SECOND, [Start Date_Time], [End Date_Time]) / 60 AS [Tijdsduur in minuten]
			-- select distinct Description 
			--FROM [s-logsh-prod].Empire.dbo.[staedion$Job Queue Log Entry] AS LOGB			-- foutmelding mogelijk vanwege "restore-actie"
			FROM [empire].[empire].dbo.[staedion$Job Queue Log Entry] AS LOGB		
		--WHERE LOGB.[Status] in (0,4)
		--and [Description] = 'Periodieke berekening mutatiehuur'
		)
		INSERT into Databasebeheer.StatusJobsDiversen
		(	Categorie,
			Omschrijving,
			Toelichting,
			[Status],
			[Tijdsduur in minuten],
			[Meest recente tijdstip],
			Laaddatum
		)
		SELECT 'Empire wachtrij',
			   COALESCE(NULLIF(Jobnaam, ''), ' Geen naam ?') AS Omschrijving,
			   NULL AS Toelichting,
			   Status,
			   [Tijdsduur in minuten],
			   [Meest recente tijdstip],
			   CAST(GETDATE() AS DATE) AS Laaddatum
		FROM cte_alle_regels AS CTE
		WHERE Volgnr = 1
			  AND NOT EXISTS
		(
			SELECT 1
			FROM DatabaseBeheer.StatusJobsDiversen AS KOPIE
			WHERE KOPIE.Laaddatum = CAST(GETDATE() AS DATE)
				  AND KOPIE.Omschrijving COLLATE DATABASE_DEFAULT = CTE.Jobnaam COLLATE DATABASE_DEFAULT
		)
		ORDER BY 3 DESC;

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Toevoegen regels SQL Agent jobs voor zover nog niet opgevoerd vandaag';
----------------------------------------------------------------------------------- 

		insert into Databasebeheer.StatusJobsDiversen
		(	Categorie, 
			Omschrijving,
			Toelichting,
			Status,
			[Tijdsduur in minuten],
			[Meest recente tijdstip],
			Laaddatum
		)
		SELECT	'SQL-agent-jobs dwh' as Categorie,
				 Jobnaam as Omschrijving,
				 null as toelichting,
				 iif(JobStatus=1, 'Ok ','?') as Status,
				 datediff(minute,'17530101 00:00:00',Duur),
				 Eindtijd as [Meest recente tijdstip],
				 --cast(getdate() as date) as Laaddatum
				 BASIS.Datum as Laaddatum
		FROM	staedion_dm.DatabaseBeheer.vw_VerwerkingSQLAgentJobs AS BASIS
		WHERE	NOT exists (SELECT  1 FROM  Databasebeheer.StatusJobsDiversen AS KOPIE WHERE KOPIE.Laaddatum = BASIS.Datum AND KOPIE.omschrijving = BASIS.Jobnaam)
		;

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


/*

USE staedion_Dm 
GO
CREATE TABLE Databasebeheer.StatusJobsDiversen
(id INT IDENTITY			(1,1),
Categorie					nvarchar(100),
Omschrijving				nvarchar(100),
Toelichting					nvarchar(255),
[Status]					nvarchar(10),
[Tijdsduur in minuten]		int,
[Meest recente tijdstip]	DATETIME,
Laaddatum					date
)
;

create VIEW [DatabaseBeheer].[vw_StatusJobsDiversen] AS 
SELECT	JOB.[id], JOB.[Categorie], JOB.[Omschrijving], JOB.[Toelichting], JOB.[Status], JOB.[Tijdsduur in minuten], JOB.[Meest recente tijdstip],JOB.[Laaddatum]
		, iif(Job.Laaddatum = cast(getdate() as date),1,0) as [Huidig]
		, DATEDIFF(d,JOB.[Meest recente tijdstip],GETDATE()) AS [Aantal dagen geleden], 
		CASE WHEN JOB.Omschrijving IN
						(
						N'Goedkeuring en vervallen berichtitems verwijderen',
						N'Rekening courant cumulatief',
						N'Controle-waarden OGE-tabel',
						N'Goedkeuringssamenvatting verzenden',
						N'Connect-It Import Order',
						N'Connect-It Import Hours',
						N'Connect-It Import Used Articles'
						) THEN 'Lightgrey'
			WHEN JOB.Status NOT IN ('Klaar','Ok') THEN '#FD625E' --red
			WHEN JOB.Categorie = 'Empire wachtrij' AND DATEDIFF(d,[Meest recente tijdstip],GETDATE()) > 7 THEN '#0072FF'
			WHEN JOB.Categorie = 'SQL-agent-jobs dwh' AND DATEDIFF(d,[Meest recente tijdstip],GETDATE()) > 1 THEN '#0072FF' --lichtblauw
			ELSE '#00FF27' END AS Signaleringskleur -- lichtgroen
FROM	staedion_Dm.Databasebeheer.StatusJobsDiversen AS JOB
--WHERE JOB.Huidig = 1
GO

*/


GO
EXEC sp_addextendedproperty N'MS_Description', N'Governance: Job actuele status databronnen en belangrijke ververs
----------------------------------------------------------------------------------------------------------------------------------
-- empire_data
-- verversen mutatiehuur
-- verversen verplichtingen
-- verversen topdesk 
-- meest recente bijwerking toegerekende posten
Zie table Databasebeheer.StatusJobsDiversen
Zie view Databasebeheer.vw_StatusJobsDiversenHuidig', 'SCHEMA', N'DatabaseBeheer', 'PROCEDURE', N'sp_load_StatusJobsDiversen', NULL, NULL
GO
