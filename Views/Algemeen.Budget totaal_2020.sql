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




CREATE view [Algemeen].[Budget totaal_2020]
as

with cte_post
as
(
select
  [Datum]                                 = glbe.Date,
  [Sleutel grootboekrekening]             = gla.lt_id,
  [Sleutel cluster]                       = c.lt_id,
  [Cluster]                               = c.nr_,
  [Budget]                                = glbe.Amount,
  [Budgetnaam]                            = glbe.[Budget Name],
  [Rekeningnummer]                        = gla.No_
from empire_data.dbo.vw_lt_mg_g_l_budget_entry as glbe
left join empire_data.dbo.vw_lt_mg_g_l_account as gla on 
  gla.mg_bedrijf = 'staedion' and
  gla.[No_] = glbe.[G_L Account No_]

left join empire_logic.dbo.lt_mg_cluster c on
  c.mg_bedrijf = 'staedion' and
  c.Nr_ = glbe.Clusternr_
  where  gla.No_ like '%a8%'
  and year(glbe.Date) = 2020
  and glbe.mg_bedrijf = 'staedion'
  and  glbe.[Budget Name] = 'BEGR 2020'
  and gla.No_ not in(
'A810200',              
'A810300',
'A814100',
'A815220',
'A815320',
'A815640',
'A816340',
'A816380',
'A816410',
'A816620',

'A816640',
'A870500') 
  ),
cte_post_excel
as(
  select 
  [Datum]                      
  ,[Sleutel grootboekrekening]  
  ,[Sleutel cluster]            
  ,[Cluster]                    
  ,[Budget]                     
  ,[Budgetnaam]                 
  ,[Rekeningnummer]             
from cte_post
union all
select 
   [Datum]                      
  ,[Sleutel grootboekrekening]  
  ,[Sleutel cluster]            
  ,[Cluster]                    
  ,[Budget]                     
  ,[Budgetnaam] = 'Excel'                
  ,[Rekeningnummer] 
  from [Algemeen].[Budgetten_excel]
  where [Rekeningnummer] not in(
  'a816430',
  'a816440',
  'A815680',
  'A816250',
  'A816630'
   )
  )


  select * from cte_post_excel














GO
