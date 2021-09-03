SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  view [Aankoop].[Aankoopresultaat]
as
select
  [Datum]                               = gle.[Posting Date],
  [Bedrag]                              = gle.Amount,
  [Sleutel eenheid]                     = o.lt_id,
  [Sleutel grootboekrekening]           = gla.lt_id,
  [Broncode]                            = gle.[Source Code],
  [Reden in exploitatie]                = rc.description

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
left join  [empire_data].[dbo].[mg_exploitation_reason_code] as rc on o.[Reden in exploitatie] = rc.Code
where   o.[Reden in exploitatie] = 1
and gle.[Source Code] not in ('DAEBRC','DAEBVERD','EXTBEHEER')
and gle.mg_bedrijf = 'Staedion'


GO
