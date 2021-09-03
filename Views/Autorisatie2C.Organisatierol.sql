SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Autorisatie2C].[Organisatierol]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Organisatierol'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Addextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [2C User Profile] + [2C User per User Profile] + [2C User Role per User Profile]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Organisatierol'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Organisatierol'
;
EXEC sys.sp_Addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Organisatierol]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Organisatierol'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Organisatierol'
;  
######################################################################################### */
SELECT Organisatierol = UP.[User Profile]
	,Omschrijving = UP.[Description]
	,[Status] = CASE UP.[Status]
		WHEN 0
			THEN 'Open'
		WHEN 1
			THEN 'Vrijgegeven'
		WHEN 2
			THEN 'Gesynchroniseerd'
		END
	,[Gewijzigd op] = UP.[Last Date Modified]
	,Verantwoordelijke = UP.[Responsible]
	,[Aantal gekoppelde machtigingensets] = (
		SELECT count(*)
		FROM empire.[2C User Role per User Profile] AS UR
		WHERE UR.[User Profile] = UP.[User Profile]
		)
	,[Aantal gekoppelde organisatierollen] = (
		SELECT count(*)
		FROM empire.[2C User per User Profile] AS UUP
		WHERE UUP.[User Profile] = UP.[User Profile]
		)
FROM empire.[2C User Profile] AS UP
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Organisatierol', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Organisatierol', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [2C User Profile] + [2C User per User Profile] + [2C User Role per User Profile]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Organisatierol', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Autorisatie2C.[Organisatierol]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Organisatierol', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: ...', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Organisatierol', 'COLUMN', N'Omschrijving'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: ...', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Organisatierol', 'COLUMN', N'Verantwoordelijke'
GO
