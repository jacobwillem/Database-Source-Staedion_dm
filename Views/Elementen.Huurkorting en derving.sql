SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Elementen].[Huurkorting en derving]
as
select
  [Datum]                               = gle.[Posting Date],
  [Bedrag]                              = gle.Amount * -1.00000,
  [Sleutel eenheid]                     = o.lt_id,
  [Sleutel grootboekrekening]           = gla.lt_id,
  [Broncode]                            = gle.[Source Code],
  [Reden leegstand]                     = gbpg.Description
  
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
left join empire_data.dbo.vw_lt_mg_gen_business_posting_group as gbpg on
  gbpg.Code = gle.[Gen_ Bus_ Posting Group] and
  gbpg.mg_bedrijf = gle.mg_bedrijf
where gle.[g_l account no_] in ('A810350','A810400','A810450','A810500','A810200','A810250','A810300','A810400')
and gle.[Source Code] not in ('DAEBRC','DAEBVERD','EXTBEHEER')
and gle.mg_bedrijf = 'Staedion'

GO
