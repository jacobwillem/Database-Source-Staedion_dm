SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DatabaseBeheer].[sp_info_object_en_velden] (@Database NVARCHAR(128) = 'empire_staedion_data', @Schema NVARCHAR(128), @ObjectNaam NVARCHAR(128))
AS  
/*#################################################################################
VAN 		JvdW 
BETREFT		Tonen van tabel of view definitie, incl toegevoegde beschrijvingen via extendend property 
STATUS		Productie
VERSIE		4

RECHTEN		grant exec on [dbo].[dsp_info_object_en_velden] to public
ZIE         SQL Server: Extract Table Meta-Data (description, fields and their data types)
            http://stackoverflow.com/questions/887370/sql-server-extract-table-meta-data-description-fields-and-their-data-types
----------------------------------------------------------------------------------		
TESTEN		
----------------------------------------------------------------------------------
EXEC [staedion_dm].[Databasebeheer].[sp_info_object_en_velden] 'empire_staedion_data', 'svh', 'OgeBestandAanteleveren'
EXEC [staedion_dm].[Databasebeheer].[sp_info_object_en_velden] 'empire_staedion_data', 'check', 'EI afmelding'
-- met kenmerken anders dan MS_Description (alleen voor object zelf, niet voor kolommen)
EXEC [staedion_dm].[Databasebeheer].[sp_info_object_en_velden] 'empire_dwh', 'dbo', 'ITVF_grootboekdetails_derving'	
EXEC [staedion_dm].[Databasebeheer].[sp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Thuisgevoel'

----------------------------------------------------------------------------------
WIJZIGING	
----------------------------------------------------------------------------------
20211118 JvdW Aangemaakt vanuit empire_staedion_data zoals die door Roelof is opgebouwd en gekopieerd naar staedion_dm
-------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
TESTEN <validatietest: bijvoorbeeld geen dubbele waarden>
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE <voeg desgewenst handige queries toe die je gebruikt hebt bij het bouwen en die je bij beheer wellicht nodig kunt hebben>
--------------------------------------------------------------------------------------------------------------------------------
-- Toevoeging info over tabel/view
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Diverse kenmerken van de eenheden, zoals hoodzakelijk in Empire staat geregistreerd, worden in deze tabel getoond.
			 Dagelijks worden alle eenheden opgehaald van bedrijf Staedion met een datum in exploitatie voor dag van ophalen gegevens en een datum uit exploitatie die daarna ligt.
			 Van elke dag wordt de data bewaard: dat wordt aangegeven met het veld datum_gegenereerd.'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'dbo'
       ,@level1type = N'TABLE'
       ,@level1name = 'ELS';
GO

-- TE GENEREREN STATEMENTS
-- NB: Toevoegen omschrijving gaat zo. NB: als je het twee keer doet, past ie 'm wel aan maar je ziet dat niet in SSMS
-- NB: Drop an extended property, does not work if extended property is not present

declare @SoortWijziging nvarchar(20)
set @SoortWijziging = 'drop'

select  case @SoortWijziging
        when 'add' then
                'EXECUTE sp_addextendedproperty @level2name = N'''
                + [column_name]
                + ''', @value = N''...'', @name =  N''MS_Description'', @level0type = N''SCHEMA'',@level0name = N'''
                + [table_schema]
                + ''',@level1type = N''TABLE'',@level1name = N'''
                + [table_name]
                + ''',@level2type = N''COLUMN'''
        when 'update' then
                'EXECUTE sp_updateextendedproperty @level2name = N'''
                + [column_name]
                + ''', @value = N''...'', @name =  N''MS_Description'', @level0type = N''SCHEMA'',@level0name = N'''
                + [table_schema]
                + ''',@level1type = N''TABLE'',@level1name = N'''
                + [table_name]
                + ''',@level2type = N''COLUMN'''
        when 'drop' then 
                'EXECUTE sp_dropextendedproperty @level2name = N'''
                + [column_name]
                + ''', @name =  N''MS_Description'', @level0type = N''SCHEMA'',@level0name = N'''
                + [table_schema]
                + ''',@level1type = N''TABLE'',@level1name = N'''
                + [table_name]
                + ''',@level2type = N''COLUMN'''                                    
        else 'nvt' end as [Uit te voeren statements]
from    information_schema.columns
where   table_catalog = 'empire_staedion_data'
and     table_name = 'OgeBestandAanTeLeveren'
and     table_schema = 'svh'
and     @SoortWijziging in ('add','update','drop')

			
##################################################################################*/
BEGIN

	-- declare @Database nvarchar(128), @Schema nvarchar(128), @ObjectNaam nvarchar(128)
	-- select @Database = N'empire_data', @Schema = N'dbo', @ObjectNaam = N'Staedion$OGE'

	set nocount on

	declare @sql nvarchar(max)

	-- afvangen foutmelding als database niet bestaat
	IF (SELECT COUNT(*)
		FROM master.sys.databases dbs
		WHERE dbs.name = @Database) = 0
		SET @sql = N'select obj.Name NaamTabel,
			'''' Kenmerk ,
			'''' OmschrijvingTabel,
			'''' NaamVeld,
			'''' OmschrijvingVeld,
			'''' DataTypeVeld,
			'''' MaximaleLengteVeld,
			'''' collation_name,
			'''' Volgorde
		from sys.objects obj where 1 = 2'
	ELSE
		SET @sql = N'select concat(db_name(), ''.'', schema_name(obj.schema_id), ''.'', obj.Name) NaamTabel,
			Kenmerk = replace(tpr.[name],''MS_Description'',''Omschrijving''),
			tpr.value OmschrijvingObject,
			obj.[type_desc] [Soort_object],
			col.name NaamVeld,
			cpr.value OmschrijvingVeld,
			isnull(type_name(col.system_type_id), typ.name)	DataTypeVeld,
			isnull(columnproperty(col.object_id, col.name, ''charmaxlen''), '''') MaximaleLengteVeld,
			col.collation_name,
			Volgorde =2
	  from [' + @Database+ N'].sys.objects obj left outer join [' + @Database+ N'].sys.columns col
		on obj.object_id = col.object_id
		left outer join [' + @Database+ N'].sys.types typ 
		on col.user_type_id = typ.user_type_id
		-- extended properties tabel
		left outer join [' + @Database+ N'].sys.extended_properties tpr 
		on obj.object_id = tpr.major_id and tpr.minor_id = 0 and tpr.name = ''MS_Description''
		-- extended properties col.name
		left outer join [' + @Database+ N'].sys.extended_properties cpr 
		on obj.object_id = cpr.major_id and cpr.minor_id = col.column_id and cpr.name = ''MS_Description''
		where obj.name = '''+ @ObjectNaam + N''' and
		schema_name(obj.schema_id) = '''+ @Schema + N'''
		union
		select concat(db_name(), ''.'', schema_name(obj.schema_id), ''.'', obj.Name) NaamTabel,
			Kenmerk = tpr.[name],
			tpr.value OmschrijvingObject,
			obj.[type_desc] [Soort_object],
			NaamVeld = null ,
			OmschrijvingVeld = null ,
			DataTypeVeld = null	,
			MaximaleLengteVeld = null ,
			collation_name = NULL ,
			Volgorde =1
	  from [' + @Database+ N'].sys.objects obj 
		join [' + @Database+ N'].sys.extended_properties tpr 
		on obj.object_id = tpr.major_id and tpr.minor_id = 0 and tpr.name <> ''MS_Description'' 
		where obj.name = '''+ @ObjectNaam + N''' and
		schema_name(obj.schema_id) = '''+ @Schema + N'''
		order by Volgorde, NaamTabel, NaamVeld' 

	SET @sql = ' USE ' + @Database+ CHAR(10) + CHAR(13) + 
	@sql

    PRINT @sql			-- Debug
	EXEC (@sql)
END

GO
