SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Autorisatie2C].[Toegangsrechten]
AS
/* #########################################################################################
-----------------------------------------------------------------------------------------
METADATA
-----------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Autorisatie2C', 'Toegangsrechten'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Addextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [Permission] + [Permission Set] + [Object]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Toegangsrechten'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Toegangsrechten'
;
EXEC sys.sp_Addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Autorisatie2C.[Toegangsrechten]',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Toegangsrechten'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Autorisatie2C',  
@level1type = N'VIEW',  @level1name = 'Toegangsrechten'
;  
######################################################################################### */

SELECT Organisatierol = P.[Role ID]
	,Omschrijving = PS.Name
	,[Object Type] = CASE P.[Object Type]
		WHEN 0
			THEN 'Table Data'
		WHEN 1
			THEN 'Table'
		WHEN 2
			THEN 'Report'
		WHEN 3
			THEN 'Codeunit'
		WHEN 4
			THEN 'XMLport'
		WHEN 5
			THEN 'MenuSuite'
		WHEN 6
			THEN 'Page'
		WHEN 7
			THEN 'Query'
		WHEN 8
			THEN 'System'
		END
	,P.[Object ID]
	,Objectnaam = O.[Name]
	,[Read Permission] = CASE P.[Read Permission]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Ja'
		WHEN 2
			THEN 'Indirect'
		END
	,[Insert Permission] = CASE P.[Insert Permission]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Ja'
		WHEN 2
			THEN 'Indirect'
		END
	,[Modify Permission] = CASE P.[Modify Permission]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Ja'
		WHEN 2
			THEN 'Indirect'
		END
	,[Delete Permission] = CASE P.[Delete Permission]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Ja'
		WHEN 2
			THEN 'Indirect'
		END
	,[Execute Permission] = CASE P.[Execute Permission]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'Ja'
		WHEN 2
			THEN 'Indirect'
		END
	,P.[Security Filter]
FROM [Empire].[Permission] AS P
LEFT OUTER JOIN Empire.[Permission Set] AS PS ON PS.[Role ID] = P.[Role ID]
LEFT OUTER JOIN Empire.[Object] AS O ON O.ID = P.[Object ID]
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Toegangsrechten', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Toegangsrechten', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [Permission] + [Permission Set] + [Object]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Toegangsrechten', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Autorisatie2C.[Toegangsrechten]', 'SCHEMA', N'Autorisatie2C', 'VIEW', N'Toegangsrechten', NULL, NULL
GO
