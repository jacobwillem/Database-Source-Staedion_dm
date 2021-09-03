SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--/****** Object:  View [Verkoop].[Verkoopresultaat]    Script Date: 15-07-21 19:53:32 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO






CREATE view [Verkoop].[Verkoopresultaat TEST]
as

WITH cte_basis
AS (
	SELECT [Datum] = gle.[Posting Date]
		,[Bedrag] = nullif((gle.Amount * - 1.00000), 0)
		,[Sleutel eenheid] = o.lt_id
		,[Sleutel grootboekrekening] = gla.lt_id
		,[Broncode] = gle.[Source Code]
		,o.[Reden in exploitatie]
		,gle.[Entry No_]
	FROM empire_data.dbo.vw_lt_mg_g_l_entry AS gle
	LEFT JOIN empire_data.dbo.vw_lt_mg_g_l_account AS gla ON gla.mg_bedrijf = gle.mg_bedrijf
		AND gla.No_ = gle.[G_L Account No_]
	LEFT JOIN empire_data.dbo.mg_g_l_entry__additional_data AS glea ON glea.mg_bedrijf = gle.mg_bedrijf
		AND glea.[G_L Entry No_] = gle.[Entry No_]
	LEFT JOIN empire_data.dbo.vw_lt_mg_oge AS o ON o.mg_bedrijf = glea.mg_bedrijf
		AND o.Nr_ = glea.[Realty Object No_]
	WHERE gle.[g_l account no_] IN (
			'A830100'
			,'A830300'
			)
		AND gle.[Source Code] NOT IN (
			'DAEBRC'
			,'DAEBVERD'
			,'EXTBEHEER'
			)
		AND gle.mg_bedrijf = 'Staedion'
		)
, cte_aanvulling
AS (
	SELECT [G_L Entry No_]
		,[Realty Object No_]
		,Volgnr = row_number() OVER (
			PARTITION BY [G_L Entry No_] ORDER BY [Allocation Entry No_]
			)
	FROM empire_data.dbo.Staedion$Allocated_G_L_Entries as ALLOC
	join cte_basis as CTE
	on CTE.[Entry No_] = ALLOC.[G_L Entry No_]
	WHERE CTE.[Sleutel eenheid] is null
			
	)
SELECT BASIS.*, ff = coalesce(BASIS.[Sleutel eenheid], O.lt_id), AANV.[Realty Object No_]
from   cte_basis as BASIS
left outer join cte_aanvulling as AANV
on AANV.[G_L Entry No_] = BASIS.[Entry No_] 
and AANV.Volgnr = 1
LEFT JOIN empire_data.dbo.vw_lt_mg_oge AS o ON o.mg_bedrijf = 'Staedion'
	AND o.Nr_ = AANV.[Realty Object No_]
-- where BASIS.[Sleutel eenheid] is null
--;
GO
