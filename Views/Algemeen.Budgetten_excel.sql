SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Algemeen].[Budgetten_excel]
as
with cte_excel
as(
select
rekening,
[FT-nummer],
budget,
maand
from [empire_staedion_data].[excel].[Budgetten_2020] as b

union all

select 
grootboekrekening,
clusternummer,
bedrag,
maand
from [empire_staedion_data].[excel].[NPO_budgetten_2020] as nb 
where grootboekrekening in ('A810300','A810200')
)
select
  [Datum]                             = ex.maand,              
  [Sleutel grootboekrekening]         = gla.lt_id,
  [Sleutel cluster]                   = null,
  [Cluster]                           = ex.[FT-nummer],  
  [Budget]                            = ex.budget,             
  [Budgetnaam]                        = null,           
  [Rekeningnummer]                    = ex.rekening
from cte_excel as ex
join empire_data.dbo.vw_lt_mg_g_l_account as gla on 
  gla.mg_bedrijf = 'Staedion' and
  gla.[No_] = ex.rekening




GO
