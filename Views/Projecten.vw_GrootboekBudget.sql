SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Projecten].[vw_GrootboekBudget]
as
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
JvdW 20210823 TBV PBI rapportage budgetrapportage planmatig onderhoud
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_GrootboekBudget'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    
SELECT [Budget] = e.[Budget Name]
	,[Rekeningnummer] = a.[No_]
	,[Rekeningnaam] = a.[Name]
	,[Rekening] = a.[No_] + ' ' + a.[Name]
	,[Kostenplaatscode] = e.[Global Dimension 1 Code]
	,[Kostenplaatsnaam] = d.[Name]
	,[Kostenplaats] = e.[Global Dimension 1 Code] + ' ' + d.[Name]
	,[Datum] = convert(DATE, e.[Date])
	,[Bedrag] = sum(convert(FLOAT, e.[Amount]))
FROM empire_data.dbo.Staedion$G_L_Account a
INNER JOIN empire_data.dbo.Staedion$G_L_Budget_Entry e ON e.[G_L Account No_] = a.[No_]
LEFT JOIN empire_data.dbo.Staedion$Dimension_Value d ON d.[Code] = e.[Global Dimension 1 Code]
	AND d.[Dimension Code] = 'KOSTENPLAATS'
WHERE (
		year(e.[Date]) >= year(getdate()) - 2
		AND e.[Budget Name] LIKE 'BEGR 202_'
		AND a.No_ IN (
			'A815520'
			,'A021302'
			,'A021304'
			,'A021308'
			,'A815640'
			)
		)
	OR (
		a.No_ = 'A021300'
		AND e.[Budget Name] = 'BEGR 2021'
		AND e.description = 'Verbeteringen vanuit PO'
		)
	OR (
		a.No_ = 'A021306'
		AND e.[Budget Name] = 'BEGR 2021'
		AND e.[Global Dimension 1 Code] = '2617504'
		)
GROUP BY e.[Budget Name]
	,a.[No_]
	,a.[Name]
	,e.[Global Dimension 1 Code]
	,d.[Name]
	,e.[Date]
GO
