SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Projecten].[ProjectKoppelingGrootboek]
as 
/* ################################################################################## 



-- check dubbele regels ?
select [Projecttype code],[Werksoort code], count(distinct Kostenrekening)
from [Projecten].[ProjectKoppelingGrootboek]
group by [Projecttype code],[Werksoort code]
having count(distinct Kostenrekening)>1

################################################################################## */ 

with  cte_instelling as (
select Projecttype, Werksoortcode, Kostenrekening,volgnr = row_number() over (partition by Projecttype, Werksoortcode order by Projecttype, Werksoortcode)
from empire_data.dbo.[Staedion$Projecttype_werksoort_instell] 
where Kostenrekening <> '' 
--and Projecttype = 'POCO'
--and Werksoortcode= '919000'
)

SELECT PTW.[bedrijf_id]
      ,PTW.[projecttype_id]
      ,PTW.[werksoort_id]
      ,PTW.[werksoortboekingsgroep]
	  ,[Werksoort code] = W.Werksoort
	  ,[Werksoort omschrijving] = W.Omschrijving
	  ,[Projecttype code] = PT.Projecttype
	  ,[Projecttype omschrijving] = PT.Omschrijving
	  ,INST.Kostenrekening
	  --,INST.volgnr
	  -- select count(*)
  FROM [staedion_dm].[Projecten].[Projecttype_werksoort] as PTW
  left outer join [staedion_dm].[Projecten].[Werksoort] as W 
  on PTW.werksoort_id = W.id
  left outer join [staedion_dm].[Projecten].[ProjectType] as PT
  on PT.id = PTW.[projecttype_id]
  left outer join cte_instelling as INST
  on INST.Werksoortcode = W.Werksoort
  and INST.Projecttype = PT.Projecttype
  and INST.volgnr = 1
GO
