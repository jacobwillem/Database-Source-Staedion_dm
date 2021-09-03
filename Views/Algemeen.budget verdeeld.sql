SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--USE [staedion_dm]
--GO

--/****** Object:  View [Algemeen].[budget verdeeld]    Script Date: 28-4-2020 15:04:21 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

CREATE view [Algemeen].[budget verdeeld]
as
with cte_verdeelsleutel
as(
   SELECT 
    [KVS-clusternummer], 
    [FT-clusternummer], 
    Verdeelsleutel                 = sum([KVS-verdeelsleutel]),
    s.sum_verdeelsleutel,
    verhouding                     = sum([KVS-verdeelsleutel])/s.sum_verdeelsleutel
   FROM staedion_dm.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN')
   cross apply (select sum_verdeelsleutel = sum([KVS-verdeelsleutel]) 
   FROM staedion_dm.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN')) as s
   WHERE [KVS-clusternummer] = 'KVS000001'
   group by [KVS-clusternummer], [FT-clusternummer],s.sum_verdeelsleutel
  ),
cte_budget
as(
  select
   [Datum]                      
  --,[Sleutel grootboekrekening]  
  ,cl.Clusternummer
  ,bud.[Rekeningnummer]                           
  ,[Budget]           = sum(budget)
  ,verhouding                       = ver.verhouding                        
  from [Algemeen].[Budget totaal_2020] as bud 
  cross join [staedion_dm].[Algemeen].[Cluster] as cl
  join cte_verdeelsleutel as ver on ver.[FT-clusternummer] = cl.clusternummer
  where bud.cluster is null
   and cl.clusternummer like '%FT%'
  group by 
   [Datum]                      
  --,[Sleutel grootboekrekening]  
  ,cl.Clusternummer
  ,[Rekeningnummer]   
  ,ver.verhouding
  )

 select
   [Datum]                      
  ,[Sleutel grootboekrekening]  = null
  ,[Sleutel cluster]            = null           
  ,[Cluster]                    = Clusternummer                 
  ,[budget]          = c1.verhouding * c1.budget                     
  ,[Budgetnaam] = 'Verdeelsleutel'                
  ,[Rekeningnummer] 
 from cte_budget as c1

GO
