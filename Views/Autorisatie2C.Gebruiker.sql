SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Autorisatie2C].[Gebruiker]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Gebruiker'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Addextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [User]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Gebruiker'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Gebruiker'
;
EXEC sys.sp_Addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Gebruiker]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Gebruiker'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Gebruiker'
;  
######################################################################################### */
SELECT [Gebruikersbeveiligings-id] = U.[User Security ID]
	,Gebruikersnaam = U.[User Name]
	,[Volledige naam] = U.[Full Name]
	,[Status] = CASE U.[State]
		WHEN 0
			THEN 'Geactiveerd'
		WHEN 1
			THEN 'Uitgeschakeld'
		END
	,Vervaldatum = U.[Expiry Date]
	,[Windows-beveiligings-id] = U.[Windows Security ID]
	,[Wachtwoord wijzigen] = U.[Change Password]
	,[Licentietype] = CASE U.[License Type]
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
	,[E-mailadres voor verificatie] = U.[Authentication Email]
	,U.[Contact Email]
	,U.[Exchange Identifier]
	,U.[Application ID]
FROM empire.[User] AS U
GO
