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
JvdW 20210906 Laatste snapshot-datum moet laaddatum zijn en niet einde van de maand
		select Peildatum, count(*) 
		from  [Projecten].[vw_BudgetPrognose]
		group by Peildatum
		order by Peildatum desc
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
WITH cte_laaddatum
AS (
	SELECT Laaddatum = datum, Peildatum = eomonth(datum)
	FROM empire_dwh.dbo.tijd
	WHERE last_loading_day = 1
	)
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
	,Peildatum = coalesce(CTE_L.Laaddatum, BUD.Peildatum)
	,[Rekeningnr en naam]
--select count(*)
-- select distinct peildatum
FROM [Projecten].[Budget en prognose incl historie] AS BUD
LEFT OUTER JOIN cte_laaddatum AS CTE_L ON CTE_L.Peildatum = BUD.Peildatum


--UNION

--SELECT [id]
--	,[bedrijf_id]
--	,[Project_id]
--	,[Projectfase_id]
--	,[Budgetregelnr_]
--	,[Cluster]
--	,[Werksoort_id]
--	,[Startdatum]
--	,[Opleverdatum]
--	,[Werksoortboekingsgroep]
--	,[Vrije code Budgetregel]
--	,[Kostenrekening]
--	,[Budget_incl_btw]
--	,[Budget_excl_btw]
--	,[Budgetstatus_id]
--	,[Prognose_incl_btw]
--	,[Prognose_excl_btw]
--	,[peildatum] = (
--		SELECT datum
--		FROM empire_Dwh.dbo.tijd AS T
--		WHERE T.last_loading_day = 1
--		)
--	,[Rekeningnr en naam]
--FROM [Projecten].[Budget en prognose incl historie]
--WHERE peildatum = (
--		SELECT max(peildatum)
--		FROM staedion_dm.[Projecten].[Budget en prognose incl historie]
--		)
---- toegevoegd: dubbelingen per 31ste voorkomen - omdat ID uniek is blijf je anders dubbele regels houden met UNION
--AND		(SELECT datum
--		FROM empire_Dwh.dbo.tijd AS T
--		WHERE T.last_loading_day = 1
--		)
--		not in (select distinct BUD1.[peildatum] from [Projecten].[Budget en prognose incl historie] as BUD1)

--GO


GO
