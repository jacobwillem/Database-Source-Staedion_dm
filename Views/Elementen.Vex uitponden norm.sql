SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Elementen].[Vex uitponden norm]
as

select
  [Sleutel eenheid]                     = o.lt_id,
  [Sleutel cluster]                     = cl.lt_id,
  [VEX norm]                            = [TOT_25],
  [Datum]                               = convert(date,'2019-1-1')
from [empire_staedion_data].[excel].[vex_uitponden] as vd
left join empire_logic.dbo.lt_mg_oge as o on
    o.Nr_ = vd.[check VHE] and
    o.mg_bedrijf = 'Staedion'
left join empire_logic.dbo.lt_mg_cluster as cl on
  cl.Nr_ = vd.[FT-nummer] and
  cl.mg_bedrijf = 'Staedion'

GO
