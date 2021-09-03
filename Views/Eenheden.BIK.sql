SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Eenheden].[BIK]
as
with cte_bik as (
  select
    2019 as jaar,
    cluster,
    Overlast = [Eindcijfer overlast & wooonfraude],
    Teamscore = teamscore,
    Klanttevredenheid = [kcm rapportcijfer],
    Leefbaarometer = [Rapport cijfer-op complexniveau]
  from excel.tmp_bik_2019
  union all
  select
    2020 as jaar,
    cluster,
    Overlast = [Eindcijfer overlast & wooonfraude],
    Teamscore = teamscore,
    Klanttevredenheid = [kcm rapportcijfer],
    Leefbaarometer = [Rapport cijfer-op complexniveau]
  from excel.tmp_bik_2020
),
cte_datums as (
  select distinct datum from empire_dwh.dbo.d_bestand where datum >= '20190101'
)
select
  d.datum,
  [Sleutel eenheid] = ae.Sleutel,
  bik.*
from cte_datums as d
join cte_bik as bik on bik.jaar = YEAR(d.datum)
join Algemeen.eenheid ae on
  ae.[FT-Clusternummer] = bik.Cluster
  
GO
