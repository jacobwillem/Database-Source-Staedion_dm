SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view  [Projecten].[vw_GrootboekFinancieelPerspectief] 
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
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_GrootboekFinancieelPerspectief'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */  
SELECT Budget = [Budget Name]
	,Begrotingsjaar = year([Date])
	,Rekeningnr = [G_L Account No_]
	,Omschrijving = [Description]
	,Bedrag = sum(Amount)
FROM empire_data.dbo.Staedion$G_L_Budget_Entry
WHERE year([Date]) >= 2021
	AND [Budget Name] LIKE 'BEGR 20__'
	AND [G_L Account No_] IN (
		SELECT DISTINCT Rekeningnummer
		FROM staedion_dm.Projecten.[vw_GrootboekBudget]
		)
GROUP BY [Budget Name]
	,[G_L Account No_]
	,[Description]
	,year([Date])
GO
