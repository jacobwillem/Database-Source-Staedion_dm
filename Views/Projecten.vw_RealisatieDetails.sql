SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Projecten].[vw_RealisatieDetails]
AS
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
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_RealisatieDetails'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    
	
SELECT REA.[id]
	,REA.[bedrijf_id]
	,REA.[project_id]
	,REA.[cluster]
	,REA.[Budget_id]
	,Budgetregelnr = REA.[Budgetregelnr_]
	,REA.[Werksoort_id]
	,[Volgnr Empire projectpost] = REA.[Job Ledger Entry No_]
	,REA.[Resource No_]
	,REA.[Item No_]
	,Rekeningnr = REA.[G_L Account No_]
	,[Leveranciersnr] = REA.[Vendor No_]
	,[Documentnr] = REA.[Document No_]
	,REA.[Boekdatum]
	,[Realisatie incl BTW] = REA.[Realisatie incl_ BTW]
	,[Realisatie excl BTW] = REA.[Realisatie excl_ BTW]
	,[Leveranciersnaam] = LEV.[Name]
	,[Rekeningnr en naam] = Coalesce(REA.[G_L Account No_], '') + ' ' + [GA].[Name]
-- select count(*) 
FROM staedion_dm.projecten.Realisatie AS REA
LEFT OUTER JOIN empire_data.dbo.Staedion$G_L_Account AS GA ON GA.No_ = REA.[G_L Account No_]
left outer join empire_data.dbo.Vendor as LEV on LEV.No_ = REA.[Vendor No_]
GO
