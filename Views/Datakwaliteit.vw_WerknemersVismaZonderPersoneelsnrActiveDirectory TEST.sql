SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Datakwaliteit].[vw_WerknemersVismaZonderPersoneelsnrActiveDirectory TEST]
as 
-- testopzet = 22 05 130

SELECT VIS.Personeelsnr
	,VIS.[Volledige Naam]
	,VIS.Werknemersgroep
	,VIS.Inlognaam
	,AD.employeeNumber AS [AD personeelsnr]
	,AD.displayName AS [AD naam]
	,[Teller inlognaam incompleet in view visma] = iif(nullif(VIS.Inlognaam, 'STAEDION\') IS NULL, 1, 0)
	,[Teller personeelsnr niet gevonden in AD] = iif(AD.displayName IS NOT NULL
		AND AD.employeeNumber IS NULL, 1, 0)
	,[Teller match obv werkmail of inlognaam met AD] = iif(AD.[sAMAccountName] IS NOT NULL, 1, 0)
FROM empire_staedion_data.visma.werknemers AS VIS
LEFT OUTER JOIN [Medewerker].[ActiveDirectory] AS AD ON CASE 
		WHEN lower(VIS.Inlognaam) = 'staedion\'
			THEN lower(replace(VIS.[Werk email], '@staedion.nl', ''))
		ELSE replace(lower(VIS.Inlognaam), 'staedion\', '')
		END = lower(AD.[sAMAccountName])
-- replace(lower(VIS.Inlognaam),'staedion\','') = lower(AD.[sAMAccountName])
--or convert(nvarchar(10),VIS.Personeelsnr) = convert(nvarchar(10),AD.employeeNumber) 
WHERE (
		VIS.[Datum uit dienst] IS NULL
		OR VIS.[Datum uit dienst] > getdate()
		)
	AND VIS.Werknemersgroep IN (
		'Werknemer (tijdelijk contract)'
		,'Werknemer (vast contract)'
		)
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nav mailwisseling tussen Rene en Edwin: personeelsnr zou gevuld moeten zijn in AD maar is dat niet
Wellicht kan het ook anders 
Wellicht is deze view bruikbaar

=> gemaild aan Marieke - Rene - Edwin 19-05-2022
	  ', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'vw_WerknemersVismaZonderPersoneelsnrActiveDirectory TEST', NULL, NULL
GO
