SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--USE [staedion_dm]
--GO

--/****** Object:  View [Algemeen].[Budget]    Script Date: 22-4-2020 16:49:56 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO




CREATE view [Algemeen].[Budget waarderendement]
as
with cte_verdeel_totaal as (
  select 
    SUM([KVS-verdeelsleutel]) as totaal
  from Algemeen.verdeelsleutel
),
cte_verdeel_per_cluster as (
  select
    [FT-clusternummer],
    SUM([KVS-verdeelsleutel]) / cvt.totaal as deel
  from Algemeen.verdeelsleutel
  cross join cte_verdeel_totaal as cvt
  group by [FT-clusternummer], cvt.totaal
)
select
  [Datum]                                 = glbe.Date,
  [Sleutel grootboekrekening]             = gla.lt_id,
  [Sleutel cluster]                       = c.lt_id,
  [Cluster]                               = c.nr_,
  [Budget]                                = glbe.Amount * ISNULL(cvpc.deel,1),
  [Op basis van verdeelsleutel]           = case when isnull(glbe.Clusternr_,'') = '' then 'Ja' else 'Nee' end,
  [Budgetnaam]                            = glbe.[Budget Name],
  [Rekeningnummer]                        = gla.No_
from empire_data.dbo.vw_lt_mg_g_l_budget_entry as glbe
left join empire_data.dbo.vw_lt_mg_g_l_account as gla on 
  gla.mg_bedrijf = 'staedion' and
  gla.[No_] = glbe.[G_L Account No_]
left join cte_verdeel_per_cluster as cvpc on
  isnull(glbe.Clusternr_,'') = ''
left join empire_logic.dbo.lt_mg_cluster c on
  c.mg_bedrijf = 'staedion' and
  c.Nr_ = isnull(nullif(glbe.Clusternr_,''),cvpc.[FT-clusternummer])
where  gla.No_ like '%a8%'
and glbe.mg_bedrijf = 'staedion'
and glbe.[Budget Name] in ('BEGR 2021','BEGR 2022','BEGR 2023', 'BEGR 2024')
  

 





GO
