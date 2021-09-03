SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Autorisatie2C].[Normatieve bevoegdheid]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Normatieve bevoegdheid'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Addextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [2C Standard Competence]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Normatieve bevoegdheid'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Normatieve bevoegdheid'
;
EXEC sys.sp_Addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Normatieve bevoegdheid]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Normatieve bevoegdheid'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Normatieve bevoegdheid'
;  
######################################################################################### */
SELECT SC.[Code]
	,Omschrijving = SC.[Description]
	,Soort = CASE SC.[Type]
		WHEN 0
			THEN 'Beschikken'
		WHEN 1
			THEN 'Bewaren'
		WHEN 2
			THEN 'Registreren'
		WHEN 3
			THEN 'Uitvoeren'
		WHEN 4
			THEN 'Controleren'
		END
	,[Organisatieimpact] = CASE SC.[Business Impact]
		WHEN 0
			THEN 'Hoog'
		WHEN 1
			THEN 'Gemiddeld'
		WHEN 2
			THEN 'Laag'
		END
	,[Organisatierisico] = SC.[Business Risk]
	,[Aantal conflicten] = (
		SELECT count(*)
		FROM empire.[2C Conflicting Competence] AS CC
		WHERE CC.Competence = SC.Code
		)
	,[Actie bij accorderen organisatierol] = CASE SC.[Action by Agreeing Profile]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Gebruikers accorderen'
		WHEN 2
			THEN 'Machtigingensets accorderen'
		WHEN 3
			THEN 'Beide accorderen'
		END
	,[Controlemethode] = CASE SC.[Check Method]
		WHEN 0
			THEN 'Norm'
		WHEN 1
			THEN 'Object'
		END
	,[Status] = CASE SC.[Status]
		WHEN 0
			THEN 'Open'
		WHEN 1
			THEN 'Vrijgegeven'
		END
	,SC.[Process]
	,SC.[Sub Process]
	,SC.[Last Date Modified]
	,Verantwoordelijke = SC.[Responsible]
	,[Standaard beoordeling voor bevinding Geaccepteerd] = CASE SC.[Def_ Eval_ for Acc_ Finding]
		WHEN 0
			THEN 'Akkoord'
		WHEN 1
			THEN 'Te beoordelen'
		END
FROM empire.[2C Standard Competence] AS SC
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Normatieve bevoegdheid', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Normatieve bevoegdheid', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [2C Standard Competence]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Normatieve bevoegdheid', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Autorisatie2C.[Normatieve bevoegdheid]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Normatieve bevoegdheid', NULL, NULL
GO
