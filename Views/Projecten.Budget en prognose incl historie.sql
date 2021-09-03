SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Projecten].[Budget en prognose incl historie]
AS
SELECT BUDG.[id]
	,BUDG.[bedrijf_id]
	,BUDG.[Project_id]
	,BUDG.[Projectfase_id]
	,BUDG.[Budgetregelnr_]
	,BUDG.[Cluster]
	,BUDG.[Werksoort_id]
	,BUDG.[Startdatum]
	,BUDG.[Opleverdatum]
	,BUDG.[Werksoortboekingsgroep]
	,BUDG.[Vrije code Budgetregel]
	,BUDG.[Kostenrekening]
	,BUDG.[Budget_incl_btw]
	,BUDG.[Budget_excl_btw]
	,BUDG.[Budgetstatus_id]
	,BUDG.[Prognose_incl_btw]
	,BUDG.[Prognose_excl_btw]
	,BUDG.[Peildatum]
	,[Rekeningnr en naam] = Coalesce(BUDG.Kostenrekening, '') + ' ' + [GA].[Name]
	-- select count(*)
FROM staedion_dm.projecten.budget_historie AS BUDG
LEFT OUTER JOIN empire_data.dbo.Staedion$G_L_Account AS GA ON GA.No_ = BUDG.Kostenrekening
GO
