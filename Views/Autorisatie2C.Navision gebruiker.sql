SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Autorisatie2C].[Navision gebruiker]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Navision gebruiker'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Addextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [2C Navision User]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Navision gebruiker'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Navision gebruiker'
;
EXEC sys.sp_Addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Navision gebruiker]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Navision gebruiker'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Navision gebruiker'
;  
######################################################################################### */
SELECT [Gebruikersbeveiligings-id] = N.[User Security ID]
	,Gebruikersnaam = N.[User Name]
	,[Volledige naam] = N.[Full Name]
	,[Status] = CASE N.[State]
		WHEN 0
			THEN 'Geactiveerd'
		WHEN 1
			THEN 'Uitgeschakeld'
		END
	,Vervaldatum = N.[Expiry Date]
	,[Windows-beveiligings-id] = N.[Windows Security ID]
	,[Wachtwoord wijzigen] = N.[Change Password]
	,[Licentietype] = CASE N.[License Type]
		WHEN 0
			THEN 'Volwaardige gebruiker'
		WHEN 1
			THEN 'Beperkte gebruiker'
		WHEN 2
			THEN 'Alleen apparaat'
		WHEN 3
			THEN 'Windows-groep'
		WHEN 4
			THEN 'Externe gebruiker'
		END
	,[E-mailadres voor verificatie] = N.[Authentication Email]
	,[Aantal gekoppelde machtigingensets] = (select count(*) from empire.[Access Control] as AC where AC.[User Security ID] = N.[User Security ID])
	,[Aantal gekoppelde organisatierollen] = (select count(*) from empire.[2C User per User Profile] as UUP where UUP.[User Security ID] = N.[User Security ID])
FROM empire.[2C Navision User] AS N
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Navision gebruiker', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Navision gebruiker', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [2C Navision User]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Navision gebruiker', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Autorisatie2C.[Navision gebruiker]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Navision gebruiker', NULL, NULL
GO
