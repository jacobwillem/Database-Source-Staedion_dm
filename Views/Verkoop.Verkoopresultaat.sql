SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Verkoop].[Verkoopresultaat]
as
select
  [Datum]                               = gle.[Posting Date],
  [Bedrag]                              = nullif((gle.Amount * -1.00000),0),
  [Sleutel eenheid]                     = o.lt_id,
  [Sleutel grootboekrekening]           = gla.lt_id,
  [Broncode]                            = gle.[Source Code],
  o.[Reden in exploitatie]
from empire_data.dbo.vw_lt_mg_g_l_entry as gle
left join empire_data.dbo.vw_lt_mg_g_l_account as gla on
  gla.mg_bedrijf = gle.mg_bedrijf and
  gla.No_ = gle.[G_L Account No_]
left join empire_data.dbo.mg_g_l_entry__additional_data as glea on
  glea.mg_bedrijf = gle.mg_bedrijf and
  glea.[G_L Entry No_] = gle.[Entry No_]
left join empire_data.dbo.vw_lt_mg_oge as o on
  o.mg_bedrijf = glea.mg_bedrijf and
  o.Nr_ = glea.[Realty Object No_]
where gle.[g_l account no_] in ('A830100', 'A830300')
and gle.[Source Code] not in ('DAEBRC','DAEBVERD','EXTBEHEER')
and gle.mg_bedrijf = 'Staedion'


GO
