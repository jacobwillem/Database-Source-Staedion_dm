SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Algemeen].[Budget]
as
select
  [Datum]                                 = glbe.Date,
  [Sleutel grootboekrekening]             = gla.lt_id,
  [Sleutel cluster]                       = c.lt_id,
  [Budget]                                = Case when gla.No_ in (
'A810200',
'A810300',
'A810300',
'A815120',
'A815320',
'A815340',
'A816630',
'A816640') and year(glbe.Date) =2020 then 0 
                                                  else glbe.Amount end,
  [Budgetnaam]                            = glbe.[Budget Name],
  [Rekeningnummer]                        = gla.No_
from empire_data.dbo.vw_lt_mg_g_l_budget_entry as glbe
left join empire_data.dbo.vw_lt_mg_g_l_account as gla on 
  gla.mg_bedrijf = glbe.mg_bedrijf and
  gla.[No_] = glbe.[G_L Account No_]
left join empire_logic.dbo.lt_mg_cluster c on
  c.mg_bedrijf = glbe.mg_bedrijf and
  c.Nr_ = glbe.Clusternr_



GO
