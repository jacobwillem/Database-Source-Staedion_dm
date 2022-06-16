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
20210823 JvdW TBV PBI rapportage budgetrapportage planmatig onderhoud
20210901 JvdW Dubbelingen per 31ste
20210906 JvdW Laatste snapshot-datum moet laaddatum zijn en niet einde van de maand
	select Peildatum, count(*) 
	from  [Projecten].[vw_BudgetPrognose]
	group by Peildatum
	order by Peildatum desc
20220428 JvdW Nav Topdesk 22 03 323
> toegevoegd [Verwachte ontvangstdatum] (ook in ETL) + [Order status]
20220512 JvdW PLOH-2200222 kwam in rapportage niet naar voren, was nog geen verplichting opgevoerd
> gecheckt of er nu verplichtingen wegvallen die hiervoor wel werden getoond: verplichtingen van inmiddels verwijderde projecten werden wel getoond, nu niet meer
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
SELECT coalesce(VERPL.[id],-1) as [id]
	,PROJ.[bedrijf_id]
	,Peildatum = coalesce(CTE_L.Laaddatum, VERPL.Peildatum)
	,PROJ.[Project_id]
	,coalesce(VERPL.[Budget_id],-1) as [Budget_id]
	,coalesce(VERPL.[Budgetregelnr_],-1) as [Budgetregelnr_]
	,coalesce(VERPL.[Werksoort_id],-1) as [Werksoort_id]
	,WS.Omschrijving as [Werksoort]
	,VERPL.[Cluster]
	,VERPL.[Order status]
	,VERPL.[Document No_]
	,VERPL.[Inkoopregelnr_]
	,coalesce(VERPL.[Orderbedrag],0) as [Orderbedrag]
	,VERPL.[Verwachte ontvangstdatum]
	,coalesce(VERPL.[Orderbedrag incl. btw],0) as [Orderbedrag incl. btw]
	,coalesce(VERPL.[verplicht_incl_btw],0) as [verplicht_incl_btw]
	,coalesce(VERPL.[verplicht_excl_btw],0) as [verplicht_excl_btw]
	,VERPL.Leveranciersnr
	,Leveranciersnaam  = LEV.[Name]
	,VERPL.[Omschrijving]
	,VERPL.[Omschrijving 2]
	,PROJ.Projectleider
	,PROJ.[Projectmanager]
FROM staedion_dm.projecten.vw_Projectgegevens as PROJ
left outer join [Projecten].Verplichting_historie as VERPL
on PROJ.project_id = VERPL.Project_id
left outer join staedion_dm.projecten.Werksoort as WS
on WS.id = VERPL.Werksoort_id
left outer join empire_data.dbo.vendor as LEV
on VERPL.Leveranciersnr = LEV.No_
LEFT OUTER JOIN cte_laaddatum AS CTE_L ON CTE_L.Peildatum = VERPL.Peildatum
GO
