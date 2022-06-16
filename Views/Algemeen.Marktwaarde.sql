SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Algemeen].[Marktwaarde]


as



with cte_basis as (
  select
    eenheidnr = mw.bk_nr_,
    marktwaarde = mw.[Netto marktwaarde],
    leegwaarde = mw.[Leegwaarde],
    markthuur = mw.[Markthuur per maand],
    beleidswaarde = null,
    datum = mw.Peildatum
  from empire_staedion_data.tms.marktwaardeoverzicht_31122018 as mw
  union all
  select
    eenheidnr = mw.Eenheidnr,
    marktwaarde = mw.[Netto marktwaarde],
    leegwaarde = mw.Leegwaarde,
    markthuur = mw.[Markthuur per maand],
    beleidswaarde = null,
    datum = '20191231'
  from empire_staedion_data.tms.marktwaardeoverzicht_31122019 as mw
  union all
  select
    eenheidnr = mw.Eenheidnr,
    marktwaarde = mw.[Netto marktwaarde],
    leegwaarde = mw.Leegwaarde,
    markthuur = mw.[Markthuur per maand],
    Beleidswaarde = mw.Beleidswaarde,
    datum = '20201231'
  from empire_staedion_data.tms.marktwaardeoverzicht_31122020 as mw
  union all
  select
    eenheidnr = mw.Eenheidnr,
    marktwaarde = mw.[Netto marktwaarde],
    leegwaarde = mw.Leegwaarde,
    markthuur = mw.[Markthuur per maand],
    Beleidswaarde = mw.Beleidswaarde,
    datum = '20211231'
  from empire_staedion_data.tms.marktwaardeoverzicht_31122021 as mw
)
select
  [Datum]               = cb.datum,
  [Sleutel eenheid]     = o.lt_id,
  [Marktwaarde]         = cb.marktwaarde,
  [Leegwaarde]          = cb.leegwaarde,
  [Markthuur]           = cb.markthuur,
  [Beleidswaarde]       = cb.beleidswaarde
from cte_basis as cb
LEFT join empire_data.dbo.vw_lt_mg_oge as o on  
  o.mg_bedrijf = 'Staedion' and
  o.Nr_ = cb.eenheidnr


GO
