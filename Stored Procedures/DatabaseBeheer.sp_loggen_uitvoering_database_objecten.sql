SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
   @Categorie nvarchar(40) = 'Onbekend', @DatabaseObject nvarchar(255) = 'Onbekend databaseobject', @Bericht nvarchar(2047) = 'Nvt' 
	, @Begintijd DATETIME = null, @Eindtijd DATETIME = NULL
	, @ErrorProcedure NVARCHAR(255) = null
	, @ErrorLine NVARCHAR(255) = null
	, @ErrorNumber NVARCHAR(255) = null
	, @ErrorMessage NVARCHAR(255) = NULL
    , @WegschrijvenOfNiet AS BIT = 1
	, @Variabelen NVARCHAR(255) = null
	

/* #######################################################################################
BETREFT	procedure waarmee uitvoering/foutmeldingen gelogd worden
> bedoeld om alles te gaan verzamelen en via Power BI doorlooptijd/foutmeldingen te kunnen rapporteren

alter table staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten add Stap nvarchar(255)

-------------------------------------------------------------------------------------------
20200205 JvdW, versie 3: @Bericht wegschrijven in Opmerking
-------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
20210929 JvdW, versie op basis van empire_staedion_data
NOG DOEN: de ETL-procedures loggen die 's nachts worden uitgevoerd (nu in empire_staedion_data.etl.LogboekMeldingenProcedures)
NOG DOEN: de ETL-procedures loggen die overdag voor rapportages worden uitgevoerd (nu in empire_staedion_data.etl.LogboekMeldingenProcedures)


--------------------------------------------------------------------------------------------------------------------------
AANTEKENINGEN
--------------------------------------------------------------------------------------------------------------------------
TEST		exec staedion_dm.DatabaseBeheer.[sp_LoggenUitvoeringDatabaseObjecten] 'This is the immediate message'

ZIE			https://www.mssqltips.com/sqlservertip/1660/using-the-nowait-option-with-the-sql-server-raiserror-statement/
				Send a message to the caller so that it's available 
				* immediately.

				* example
				print 'before the call'
				exec dbo.[hulp_log_nowait] 'This is the immediate message - 1'
				waitfor delay '00:00:05'
				exec dbo.[hulp_log_nowait] 'This is the immediate message - 2'
				waitfor delay '00:00:05'
				exec dbo.[hulp_log_nowait] 'This is the immediate message - 3'
				print 'This is after a 10 second delay'

				-- compare this to
				print 'before the call'
				raiserror ('this is the msg', 0, 1)
				waitfor delay '00:00:10'
				print 'This is after a 10 second delay'

####################################################################################### */
AS
begin
    DECLARE @tijdstip char(19)
	
		BEGIN TRY

		   SET @tijdstip= convert (varchar(19), getdate(), 121)
			 set @Bericht = @tijdstip + ': '  +@Bericht
			 RAISERROR (@Bericht, 0, 1) WITH NOWAIT 

			IF @WegschrijvenOfNiet = 1 
				BEGIN
					INSERT into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten
							(Categorie
								 ,[Databaseobject]
								 ,Variabelen
								 ,[Stap]
								 ,[Begintijd]
								 ,[Eindtijd]
								 ,[Tijdmelding]
								 ,[ErrorProcedure]
								 ,[ErrorLine]
								 ,[ErrorNumber]
								 ,[ErrorMessage]
								 )
					 VALUES (@Categorie
								 ,@DatabaseObject
								 ,@Variabelen
								 ,@Bericht
								 ,COALESCE(@Begintijd,@tijdstip)
								 ,@Eindtijd
								 ,@tijdstip
								 ,@ErrorProcedure 
								 ,@ErrorLine
								 ,@ErrorNumber
								 ,@ErrorMessage
								 )
				END
			END TRY

				BEGIN CATCH
					-- bijhouden aantal records
						insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten
							(Categorie
								 ,[Databaseobject]
								 ,Variabelen
								 ,[Stap]
								 ,[Begintijd]
								 ,[Eindtijd]
								 ,[TijdMelding]
								 ,[ErrorProcedure]
								 ,[ErrorLine]
								 ,[ErrorNumber]
								 ,[ErrorMessage])
						 VALUES (@Categorie
								 ,@DatabaseObject
								 ,@Variabelen
								 ,@Bericht
								 ,COALESCE(@Begintijd,@tijdstip)
								 ,@Eindtijd
								 ,getdate()
								 ,ERROR_PROCEDURE() 
								 ,ERROR_LINE() 
								 ,ERROR_NUMBER() 
								 ,ERROR_MESSAGE())

									
				END CATCH;


end


GO
