SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE view [Projecten].[vw_BudgetPrognose]
as 
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
JvdW 20210823 TBV PBI rapportage budgetrapportage planmatig onderhoud
JvdW 20210901 Dubbelingen per 31ste
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_BudgetPrognose'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    
SELECT [id]
	,[bedrijf_id]
	,[Project_id]
	,[Projectfase_id]
	,[Budgetregelnr_]
	,[Cluster]
	,[Werksoort_id]
	,[Startdatum]
	,[Opleverdatum]
	,[Werksoortboekingsgroep]
	,[Vrije code Budgetregel]
	,[Kostenrekening]
	,[Budget_incl_btw]
	,[Budget_excl_btw]
	,[Budgetstatus_id]
	,[Prognose_incl_btw]
	,[Prognose_excl_btw]
	,[Peildatum]
	,[Rekeningnr en naam]
--select count(*)
FROM [Projecten].[Budget en prognose incl historie]

UNION

SELECT [id]
	,[bedrijf_id]
	,[Project_id]
	,[Projectfase_id]
	,[Budgetregelnr_]
	,[Cluster]
	,[Werksoort_id]
	,[Startdatum]
	,[Opleverdatum]
	,[Werksoortboekingsgroep]
	,[Vrije code Budgetregel]
	,[Kostenrekening]
	,[Budget_incl_btw]
	,[Budget_excl_btw]
	,[Budgetstatus_id]
	,[Prognose_incl_btw]
	,[Prognose_excl_btw]
	,[peildatum] = (
		SELECT datum
		FROM empire_Dwh.dbo.tijd AS T
		WHERE T.last_loading_day = 1
		)
	,[Rekeningnr en naam]
FROM [Projecten].[Budget en prognose incl historie]
WHERE peildatum = (
		SELECT max(peildatum)
		FROM staedion_dm.[Projecten].[Budget en prognose incl historie]
		)
-- toegevoegd: dubbelingen per 31ste voorkomen
AND		peildatum not in (select distinct BUD1.[peildatum] from [Projecten].[Budget en prognose incl historie] as BUD1)

GO
