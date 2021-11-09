SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Financieel].[Grootboekposten]
as
select
  [Sleutel grootboekrekening]               = gla.lt_id,
  [Rekeningnummer]                          = gla.No_,
  [Datum]                                   = convert(date,gle.[Posting Date]),
  [Bedrag geboekt]                          = gle.Amount,
  [Documentnummer]                          = gle.[document no_],
  [Werksoort]                               = ews.Omschrijving,
  [Projectnummer]                           = gle.[Empire Projectnr_],
  [Projecttype]                             = gle.[Empire Projecttype],
  [Clusternr]                               = gle.Clusternr_
from empire_data.dbo.Staedion$G_L_Entry as gle
join empire_logic.dbo.lt_mg_g_l_account as gla on
  gla.mg_bedrijf = 'Staedion' and
  gla.No_ = gle.[G_L Account No_]
left join empire_data.dbo.[Staedion$Empire_Werksoort] ews on
  ews.code = gle.[Empire Werksoort]
where gle.[G_L Account No_] like 'A8%'
and			gle.[Source Code] not in ('DAEBRC', 'DAEBVERD', 'EXTBEHEER' )


GO
