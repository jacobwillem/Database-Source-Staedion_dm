SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Contracten].[Beeindigde contracten]
as
select
  Datum                  = c.[Datum einde],
  [Sleutel contract]     = c.[Sleutel],
  [Sleutel eenheid]      = c.[Sleutel eenheid],
  [Sleutel klant]        = c.[Sleutel klant],
  [Kalehuur op einde]    = hpr.kalehuur,
  [Mutatiehuur op einde] = isnull(hpr.streefhuur_oud, hpr.markthuur),
  [Kalehuur nieuw]       = ndc.kale_huur_bij_ingang
from Algemeen.Contract as c
left join empire_dwh.dbo.contract as dc on
  dc.id = c.Sleutel
left join empire_dwh.dbo.contract ndc on 
  ndc.id = dc.volgend_contract
inner join empire_dwh.dbo.eenheid as e on
  e.id = c.[Sleutel eenheid]
outer apply empire_staedion_data.[dbo].[ITVfnHuurprijs](e.bk_nr_, c.[Datum einde]) as hpr
where c.[Datum einde] is not null
GO
