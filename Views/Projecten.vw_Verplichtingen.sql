SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE   view [Projecten].[vw_Verplichtingen]
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
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_Projectgegevens'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    
					

as 
WITH cte_laaddatum
AS (
	SELECT Laaddatum = datum, Peildatum = eomonth(datum)
	FROM empire_dwh.dbo.tijd
	WHERE last_loading_day = 1
	)
SELECT VERPL.[id]
	,VERPL.[bedrijf_id]
	,Peildatum = coalesce(CTE_L.Laaddatum, VERPL.Peildatum)
	,VERPL.[Project_id]
	,VERPL.[Budget_id]
	,VERPL.[Budgetregelnr_]
	,VERPL.[Werksoort_id]
	,VERPL.[Cluster]
	,VERPL.[Order status]
	,VERPL.[Document No_]
	,VERPL.[Inkoopregelnr_]
	,VERPL.[Orderbedrag]
	,VERPL.[Orderbedrag incl. btw]
	,VERPL.[verplicht_incl_btw]
	,VERPL.[verplicht_excl_btw]
	,VERPL.Leveranciersnr
	,Leveranciersnaam  = LEV.[Name]
FROM [Projecten].Verplichting_historie as VERPL
left outer join empire_data.dbo.vendor as LEV
on VERPL.Leveranciersnr = LEV.No_
LEFT OUTER JOIN cte_laaddatum AS CTE_L ON CTE_L.Peildatum = VERPL.Peildatum


GO
