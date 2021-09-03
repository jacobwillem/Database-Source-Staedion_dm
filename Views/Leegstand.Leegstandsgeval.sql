SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Leegstand].[Leegstandsgeval]
as
select
  [Datum]                           = convert(date,dl.datum),
  [Leegstandsnummer]                = dl.leegstandsnummer,
  [Sleutel eenheid]                 = dl.fk_eenheid_id,
  [Reden leegstand]                 = rl.descr,
  [Datum ingang]                    = convert(date,dl.dt_ingang),
  [Datum einde]                     = convert(date,dl.dt_einde),
  [Datum ingang reden]              = convert(date,dl.dt_ingang_reden),
  [Datum einde reden]               = convert(date,dl.dt_einde_reden),
  [Dagen leegstand]                 = dl.dagenleegstand,
  [Derving netto]                   = dl.dervingnetto,
  [Derving bruto]                   = dl.dervingbruto,
  [Derving kale]                    = dl.dervingkale,
  [Heeft leegstand ultimo maand]    = case when isnull(dl.dt_einde,'99991231') >= dl.datum then 'Ja' else 'Nee' end,
  [Heeft momenteel leegstand]       = case when ISNULL(dl.dt_einde,'99991231') >= GETDATE() then 'Ja' else 'Nee' end,
  [Dagen leegstand vanaf ingang]    = DATEDIFF(dd,dl.dt_ingang, isnull(dl.dt_einde,getdate()))
from empire_dwh.dbo.d_leegstand as dl
left join empire_dwh.dbo.redenleegstand as rl on
  rl.id = dl.fk_redenleegstand_id
GO
