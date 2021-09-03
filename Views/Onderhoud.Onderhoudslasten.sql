SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE view [Onderhoud].[Onderhoudslasten]
as
select
  [Datum]                               = gle.[Posting Date],
  [Bedrag]                              = gle.Amount * -1.00000,
  [Sleutel eenheid]                     = o.lt_id,
  [Sleutel grootboekrekening]           = gla.lt_id,
  [Rekeningnummer]						= gle.[g_l account no_],
  [Broncode]                            = gle.[Source Code],
  [Boekingsgroep]                       = gle.[Gen_ Prod_ Posting Group],
  [Bedrijf]                             = gle.mg_bedrijf
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
where gle.[g_l account no_] in 
(
'A815120', --NPO
'A815320', 
'A815340', 
'A815360',
'A810200',
'A816640',
'A810300', -- PO
'A815500',
'A815520',
'A815540',
'A815599',
'A815680',
'A815640'
)


and gle.[Source Code] not in ('DAEBRC','DAEBVERD','EXTBEHEER')



GO
