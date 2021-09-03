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

SELECT VERPL.[id]
	,VERPL.[bedrijf_id]
	,VERPL.[peildatum]
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

UNION

SELECT VERPL.[id]
	,VERPL.[bedrijf_id]
	,[peildatum] = (
		SELECT datum
		FROM empire_Dwh.dbo.tijd AS T
		WHERE T.last_loading_day = 1
		)
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

WHERE VERPL.peildatum = (
		SELECT max(peildatum)
		FROM staedion_dm.[Projecten].Verplichting_historie
		)
-- toegevoegd: dubbelingen per 31ste voorkomen
AND		VERPL.peildatum not in (select distinct VERPL2.[peildatum] from [Projecten].Verplichting_historie as VERPL2)
GO
