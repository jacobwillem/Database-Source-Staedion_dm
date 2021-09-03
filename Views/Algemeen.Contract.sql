SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Algemeen].[Contract]
as
with cte_leegstand as (
  select
    c.id as fk_contract_id,
    c.dt_ingang,
    c.dt_einde,
    c.dt_ingang_volgend_contract,
    dl.fk_redenleegstand_id,
    rl.descr as redenleegstand,
    dl.dt_ingang_reden,
    dl.dt_einde_reden,
    prio = ROW_NUMBER() over (partition by c.id order by dl.dt_ingang_reden desc)
  from empire_dwh.dbo.contract as c
  join empire_dwh.dbo.d_leegstand as dl on
    dl.fk_eenheid_id = c.fk_eenheid_id and
    dl.dt_ingang > c.dt_einde and
    dl.dt_ingang < isnull(c.dt_ingang_volgend_contract,'99991231')
  join empire_dwh.dbo.redenleegstand as rl on rl.id = dl.fk_redenleegstand_id
),
cte_laatste_huur as (
select 
  fk_contract_id,
  kalehuur,
  prio = ROW_NUMBER() over (partition by fk_contract_id order by datum desc)
from empire_dwh.dbo.d_bestand_contract
where kalehuur <> 0
)
select
  [Sleutel]                       = c.id,
  [Contractnummer]                = c.bk_contractnr,
  [Datum ingang]                  = c.dt_ingang,
  [Datum einde]                   = c.dt_einde,
  [Reden leegstand]               = cl.redenleegstand,
  [Sleutel eenheid]               = c.fk_eenheid_id,
  [Sleutel klant]                 = c.fk_klant_id,
  [Laatste kalehuur]              = clh.kalehuur
from empire_dwh.dbo.contract as c
left join cte_leegstand as cl on 
  cl.fk_contract_id = c.id and
  cl.prio = 1
left join cte_laatste_huur as clh on 
  clh.fk_contract_id = c.id and
  clh.prio = 1

GO
