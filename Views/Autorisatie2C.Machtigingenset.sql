SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Autorisatie2C].[Machtigingenset]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Machtigingenset'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Updateextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [2C User Role] + info uit [Permission Set]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Machtigingenset'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Machtigingenset'
;
EXEC sys.sp_Updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Machtigingenset]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Machtigingenset'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Machtigingenset'
;  
######################################################################################### */
SELECT [Machtigingenset-id] = UR.[Role ID]
	,Naam = PS.[Name]
	,[Status] = CASE UR.[Status]
		WHEN 0
			THEN 'Open'
		WHEN 1
			THEN 'Vrijgegeven'
		END
	,Bereik = CASE UR.[Scope]
		WHEN 0
			THEN 'Systeem'
		WHEN 1
			THEN 'Tenant'
		END
	,[Veldbeveiliging] = (
		SELECT count(*)
		FROM empire.[2C Secured Field Per Source] AS TS
		WHERE TS.[Source No_] = UR.[Role ID]
		)
	,[Datasetbeveiliging] = (
		SELECT count(*)
		FROM empire.[2C Secured Dataset Per Source] AS TS
		WHERE TS.[Source No_] = UR.[Role ID]
		)
	,[Aantal gekoppelde organisatierollen] = (
		SELECT count(*)
		FROM empire.[2C User Role per User Profile] AS URUP
		WHERE URUP.[User Role ID] = UR.[Role ID]
		)
	,[Aantal gekoppelde gebruikers] = (
		SELECT count(DISTINCT [User Name])
		FROM [Empire].[2C User per User Profile] AS UUP
		WHERE UUP.[User Profile] IN (
				SELECT [User Profile]
				FROM empire.[2C User Role per User Profile] AS URUP
				WHERE URUP.[User Role ID] = UR.[Role ID]
				)
		)
FROM empire.[2C User Role] AS UR
LEFT OUTER JOIN EMPIRE.[Permission Set] AS PS ON UR.[Role ID] = PS.[Role ID]
--WHERE UR.[Role ID] = 'ST-ALG-ALLEN'
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Machtigingenset', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Machtigingenset', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [2C User Role] + info uit [Permission Set]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Machtigingenset', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Autorisatie2C.[Machtigingenset]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Machtigingenset', NULL, NULL
GO
