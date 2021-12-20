SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DatabaseBeheer].[sp_controle_database_objecten](@database NVARCHAR(128), @test INT = 0)
AS
BEGIN
/************************************************************************************************************
VAN				Roelof van Goor
BETREFT			Procedure om in een database te controleren of de gebruikers objecten nog geldig zijn
				Omdat de try .. catch geen waarschuwingen afvangt heb ik een extra controle toegevoegd die 
				de fictieve foutmelding 1 genereert als een object refereert aan een niet-bestaand object, 
				dexe objecten worden wel aangemaakt maar geven tijdens de uitvoering toch een foutmelding en
				worden hier daarom als fout gerapporteerd.
OPMERKING		Zorg dat de gebruiker waaronder de procedure wordt uitgevoerd voldoende rechten heeft in de 
				te controleren database. Er kunnen geen databases buiten de huidige server instantoe worden
				gecontroleerd!

TEST			exec staedion_dm.[DatabaseBeheer].[sp_controle_database_objecten] 'staedion_dm'
				exec staedion_dm.[DatabaseBeheer].[sp_controle_database_objecten] , 1
	
VERSIE			20200710 RvG Aangemaakt
				20200724 Rvg parameter @test toegevoegd, als waarde anders dan 0 dan wordet de uitvoer niet
				in de tabel weggeschreven maar als uitvoer naar het scherm gestuurd. Default waarde = 0

TABEL			create table empire_staedion_data.etl.CheckDatabaseObjecten
				(controledatum date,
				[database] sysname, 
				[schema] sysname, 
				[object] sysname, 
				[objtype] varchar(50), 
				errornr int, 
				errormessage nvarchar(4000))
				create index CheckDatabaseObjecten_01 on etl.CheckDatabaseObjecten (controledatum, [database], [schema], [object])


------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------
20211207 JvdW Overgezet naar staedion_dm + naar andere tabel tezamen met andere checks
************************************************************************************************************/
	-- declare @database nvarchar(128) = 'staedion_dm'
	-- controleren of de opgegeven database bestaat

	IF ((SELECT COUNT(*)
		FROM master.sys.databases dbs
		WHERE dbs.name = @database) > 0)
	BEGIN
		declare @sql nvarchar(max)
	
		set nocount on
	
		SET @sql = N'	set nocount on

		declare @result table ([database] sysname, [schema] sysname, [object] sysname, [objtype] varchar(50), errornr int, errormessage nvarchar(4000))
	
		declare @object sysname, @schema sysname, @objtype varchar(50), @fullname nvarchar(250)
	
		declare sqlobject cursor for
			select sch.[Name] [Schema], obj.[name], obj.[type_desc]
			from [' + @database + N'].sys.objects obj inner join [' + @database + N'].sys.schemas sch
			on obj.schema_id = sch.schema_id
			where obj.[is_ms_shipped] = 0 and
			obj.[type_desc] in (''VIEW'', ''SQL_STORED_PROCEDURE'', ''SQL_INLINE_TABLE_VALUED_FUNCTION'' , ''SQL_SCALAR_FUNCTION'')

		open sqlobject

		fetch next from sqlobject into @schema, @object, @objtype
	
		while @@fetch_status = 0
		begin
			begin transaction
			begin try
				set @fullname = concat(@schema, ''.'', @object)
				exec [' + @database + N'].sys.sp_refreshsqlmodule @name = @fullname
			
				insert into @result 
					select ''' + @database + N''', @schema, @object, @objtype, 1, ''Missende referenties: '' + string_agg(iif(dep.referenced_database_name is null, '''', ''['' + dep.referenced_database_name + ''].'') +
						iif(dep.referenced_schema_name is null, '''', ''['' + dep.referenced_schema_name + ''].'') + dep.referenced_entity_name, '', '')
					from [' + @database + N'].sys.sql_expression_dependencies dep inner join [' + @database + N'].sys.objects obj
					on dep.referencing_id = obj.[object_id]
					where schema_name(obj.[schema_id]) = @schema and
					obj.name = @object and
					dep.is_ambiguous = 0 and 
					dep.referenced_id is null and
					dep.referenced_server_name is null and
					case dep.referenced_class when 1 then object_id(isnull(quotename(dep.referenced_database_name), db_name()) + ''.'' + 
							isnull(quotename(dep.referenced_schema_name), schema_name()) + ''.'' + quotename(dep.referenced_entity_name))
						when 6 then type_id(isnull(dep.referenced_schema_name, schema_name()) + ''.'' + dep.referenced_entity_name)
						when 10 then (select 1 from [' + @database + N'].sys.xml_schema_collections xsc
							where xsc.name = dep.referenced_entity_name and
							xsc.[schema_id] = isnull(schema_id(dep.referenced_schema_name), schema_id())) end is null

				insert into @result 
					select ''' + @database + N''', @schema, @object, @objtype, 0, ''Ok''
			end try
			begin catch
				if @@trancount > 0 
					rollback transaction
				insert into @result 
					select ''' + @database + N''', @schema, @object, @objtype, ERROR_NUMBER(), ERROR_MESSAGE()
			end catch
			if @@trancount > 0 
				rollback transaction

			fetch next from sqlobject into @schema, @object, @objtype
		end

		close sqlobject
		deallocate sqlobject

		; with sel ([database], [schema], [object], [errornr])
		as (select [database], [schema], [object], max([errornr])
			from @result
			where [errormessage]is not null
			group by [database], [schema], [object]) 
			' + IIF(@test = 0, 
		N'insert into staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] (Begintijd, TijdMelding, Databaseobject, ErrorNumber, Errormessage, Categorie) 
			' , N'') +
			N'select convert(date, getdate()),convert(date, getdate()), res.[database] + ''.'' + res.[schema] + ''.''+ res.[object] + '' (''+ res.[objtype] + '')'', res.[errornr], res.[errormessage] , ''sp_controle_database_objecten'' 
			from @result res inner join sel
			on res.[database] = sel.[database] and res.[schema] = sel.[schema] and res.[object] = sel.[object] and res.[errornr] = sel.[errornr]'

		EXEC (@sql)
	END
	ELSE
		INSERT INTO staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] (Begintijd, TijdMelding, Databaseobject, ErrorNumber, Errormessage, Categorie) 
			SELECT CONVERT(DATE, GETDATE()), CONVERT(DATE, GETDATE()),'sp_controle_database_objecten', 3, 'Procedure aangeroepen met ongeldige databasenaam, geen resultaten opgehaald.', 'sp_controle_database_objecten'

END
GO
