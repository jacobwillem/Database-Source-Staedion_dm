SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Eenheden].[BIK]
as
with cte_bik as (
  select 
    jaar = convert(int,right(bikjaar,4)),
    cluster = Clusternummer,
    Overlast = OverlastWoonfraudeCijfer,
    Teamscore = TeamscoreCijfer,
    Klanttevredenheid = KCMCijfer,
    Leefbaarometer = LeefbaarometerCijferCluster
  from Leefbaarheid.BIKOpCluster 
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
