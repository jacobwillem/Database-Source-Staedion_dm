SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Autorisatie2C].[Beveiligde tabel]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Beveiligde tabel'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Updateextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [2C Secured Table]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Beveiligde tabel'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Beveiligde tabel'
;
EXEC sys.sp_Updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Beveiligde tabel]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Beveiligde tabel'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Beveiligde tabel'
;  
######################################################################################### */
SELECT Soort = CASE ST.[Type]
		WHEN 0
			THEN 'Veldbeveiliging'
		WHEN 1
			THEN 'Datasetbeveiliging'
		END
	,Nr = ST.[No_]
	,Omschrijving = ST.[Description]
	,[Tabel-id] = ST.[Table ID]
	,Tabelnaam = ST.[Table Name]
	,[Tabelbijschrift] = ST.[Table Caption]
	,Begindatum = ST.[Starting Date]
	,Einddatum = ST.[Ending Date]
	,Gegevenseigenaar = ST.[Data Owner]
	,[Standaard muteerbaar] = ST.[Default Editable]
	,Bereik = CASE ST.[Scope]
		WHEN 0
			THEN 'Systeem'
		WHEN 1
			THEN 'Tenant'
		END
	,ST.[App ID]
	,ST.[Module]
	,Tabelsoort = CASE ST.[Table Type]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Instellingen'
		WHEN 2
			THEN 'Stamgegeven'
		WHEN 3
			THEN 'Document/Dagboek'
		WHEN 4
			THEN 'Geb.doc./Geb.dagb.'
		WHEN 0
			THEN 'Post'
		WHEN 6
			THEN 'Intern'
		WHEN 7
			THEN 'Overig'
		END
	,[Nr.-reeks] = ST.[No_ Series]
	,[Invoegcontrole FS] = ST.[FS_Insert Check]
	,[Wijzigcontrole FS]= ST.[FS_Modify Check]
	,[Verwijdercontrole FS] = ST.[FS_Delete Check]
	,[Invoegcontrole DS] = ST.[DS_Insert Check]
	,[Wijzigcontrole huidige waarde] = ST.[DS_Modify Check Current Value]
	,[Wijzigcontrole nieuwe waarde] = ST.[DS_Modify Check New Value]
	,[Verwijdercontrole DS] = ST.[DS_Delete Check]
	,Filterveldnummer = ST.[Filter Field No_]
	,Filterveldnaam = ST.[Filter Field Name]
	,Filterveldbijschrift = ST.[Filter Field Caption]
	,Filterwaarde = ST.[Filter Value]
	,[Interne filterwaarde] = ST.[Internal Filter Value]
FROM [Empire].[2C Secured Table] AS ST
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Beveiligde tabel', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Beveiligde tabel', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [User]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Beveiligde tabel', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Autorisatie2C.[Gebruiker]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Beveiligde tabel', NULL, NULL
GO
