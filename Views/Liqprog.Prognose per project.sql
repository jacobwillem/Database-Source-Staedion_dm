SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Liqprog].[Prognose per project]
as
with cte_totaal as (
  select 
    Projectnummer,
    totaal = SUM(waarde)
  from Liqprog.Projectgegevens_unpvt
  where soort = 'maand'
  group by Projectnummer
)
select
  [Datum] = d.datum,
  pg.Projectnummer,
  Bedrag =  case
              when year(d.datum) - year(GETDATE()) = 0 and lp_mnd.nummer > month(getdate()) then lp_mnd.waarde
              else ([Bedrag project budget] - isnull(ct.totaal,0.00)) * lp_jaar.waarde
            end
from Liqprog.Projectgegevens as pg
join empire_dwh.dbo.tijd as d on 
  d.datum between [Datum start bouw PROG] and isnull(pg.[Datum oplevering PROG],'99991231') and
  d.dag_vd_maand = 1
  left join Liqprog.Projectgegevens_unpvt as lp_mnd on
    lp_mnd.Projectnummer = pg.Projectnummer and
    lp_mnd.nummer = d.maand_value and
    lp_mnd.soort = 'Maand'
  left join Liqprog.Projectgegevens_unpvt as lp_jaar on
    lp_jaar.Projectnummer = pg.Projectnummer and
    lp_jaar.nummer = (year(d.datum) - year(GETDATE())) and
    lp_jaar.soort = 'JAAR'
  left join cte_totaal as ct on ct.Projectnummer = pg.Projectnummer
where Projectfase not in ('initiatief','verkenning')



--select * from Liqprog.[Prognose per project] where [Bedrag]> 0
GO
