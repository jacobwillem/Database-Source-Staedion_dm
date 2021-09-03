SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Projecten].[vw_WerksoortInclRekening] as 
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
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_WerksoortInclRekening'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    
					
WITH cte_kostenrekening
AS (
	SELECT Werksoortcode
		,Kostenrekening
		,Volgnr = row_number() OVER (
			PARTITION BY Werksoortcode ORDER BY [Projecttype]
				,Kostenrekening
			)
	FROM empire_Data.dbo.[staedion$Projecttype_werksoort_instell] AS INST
	)
--and INST.Werksoortcode = '904405'
SELECT WS.id
	,WS.bedrijf_id
	,WS.Werksoort
	,WS.Omschrijving
	,Rekening = coalesce(INST.Kostenrekening, 'Onbekend') + ' ' + coalesce(GA.[Name], 'Onbekend')
-- select *
FROM Projecten.Werksoort AS WS
LEFT OUTER JOIN cte_kostenrekening AS INST ON INST.Werksoortcode = WS.Werksoort
	AND INST.Volgnr = 1
LEFT OUTER JOIN empire_data.dbo.[Staedion$G_L_Account] AS GA ON GA.No_ = INST.Kostenrekening
GO
