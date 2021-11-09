SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Liqprog].[Prognose per project]
as
with cte_totaal as (
  select 
    sleutel,
    totaal = SUM(waarde)
  from Liqprog.Projectgegevens_unpvt
  where soort = 'maand'
  group by sleutel
)
select
  [Datum] = d.datum,
  [Sleutel project] = pg.Sleutel,
  [Datum start bouw PROG],
  Bedrag =  case
              when year(d.datum) = year(GETDATE()) and lp_mnd.nummer <= month(getdate()) then fep.kosten
              when year(d.datum) = year(GETDATE()) and lp_mnd.nummer > month(getdate()) then lp_mnd.waarde
              when 
                EOMONTH(d.datum) between [Datum start bouw PROG] and isnull(EOMONTH(pg.[Datum oplevering PROG]),'99991231') then 
                  (([Bedrag project prognose] - isnull(ct.totaal,0.00)) * lp_jaar.waarde) 
                  / 
                  (DATEDIFF(
                    mm,
                    empire_logic.dbo.dlf_maxdate(DATEADD(yy, DATEDIFF(yy, 0, d.datum), 0), [Datum start bouw PROG]), 
                    empire_logic.dbo.dlf_mindate(DATEADD(yy, DATEDIFF(yy, 0, d.datum) + 1, -1), isnull(pg.[Datum oplevering PROG],'99991231'))) + 1
                   )
            end
from Liqprog.Projectgegevens as pg
join empire_dwh.dbo.tijd as d on 
  d.dag_vd_maand = 1 and
  d.datum >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
  left join Liqprog.Projectgegevens_unpvt as lp_mnd on
    lp_mnd.sleutel = pg.Sleutel and
    lp_mnd.nummer = d.maand_value and
    lp_mnd.soort = 'Maand'
  left join Liqprog.Projectgegevens_unpvt as lp_jaar on
    lp_jaar.sleutel = pg.sleutel and
    lp_jaar.nummer = (year(d.datum) - (year(GETDATE()))) and
    lp_jaar.soort = 'JAAR'
  left join cte_totaal as ct on ct.sleutel = pg.sleutel
  left join empire_dwh.dbo.emp_project as ep on
    ep.bk_nr_ = pg.Projectnummer
  left join empire_dwh.dbo.f_emp_projectposten as fep on
    fep.fk_emp_project_id = ep.id and
    eomonth(d.datum ) = eomonth(fep.datum)
where Projectfase not in ('initiatief','verkenning')
--and pg.sleutel = 73

--select * from Liqprog.[Prognose per project] where [Bedrag]> 0
GO
