SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DatabaseBeheer].[sp_controleloop_database_objecten]
AS
BEGIN
/************************************************************************************************************
VAN				Roelof van Goor
BETREFT			Procedure om van een set databases (binnen dezelfde engine) de controle procedure aan te 
				roepen en de status van de databaseobjecten te controleren.

OPMERKING		Zorg dat de gebruiker waaronder de procedure wordt uitgevoerd voldoende rechten heeft in de 
				te controleren database. Er kunnen geen databases buiten de huidige server instantoe worden
				gecontroleerd!

TEST			exec staedion_dm.Databasebeheer.[sp_controleloop_database_objecten]
	
VERSIE			20200720 RvG Aangemaakt
AFHANKELIJK		de procedure is afhankelijk van de procedure staedion_dm.Databasebeheer.sp_controle_database_objecten

------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------
20211207 JvdW Overgezet naar staedion_dm + naar andere tabel tezamen met andere checks

************************************************************************************************************/

	DECLARE @database NVARCHAR(128)
	DECLARE @sql NVARCHAR(1000)

	SET NOCOUNT ON

	-- hier databases uitsluiten die niet hoeven te worden gecontroleerd zoals bijvoorbeeld systeemdatabases
	DECLARE dbase CURSOR FOR
		SELECT dbs.[name]
		FROM master.sys.databases dbs
		WHERE dbs.[name] NOT IN ('master', 'tempdb', 'model', 'msdb', 'DBCM_CM3_Staedion_PRD')
		ORDER BY dbs.[name]

	OPEN dbase

	FETCH NEXT FROM dbase INTO @database

	WHILE @@fetch_status = 0
	BEGIN

		SET @sql = 'exec staedion_dm.Databasebeheer.sp_controle_database_objecten ''' + @database + '''' 
		EXEC (@sql)

		FETCH NEXT FROM dbase INTO @database	
	END

	CLOSE dbase
	DEALLOCATE dbase
END
GO
