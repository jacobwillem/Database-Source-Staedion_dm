SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Contracten].[Gestarte contracten]
as
select
  Datum                  = c.dt_ingang,
  [Sleutel contract]     = c.id,
  [Sleutel eenheid]      = c.fk_eenheid_id,
  [Sleutel klant]        = c.fk_klant_id,
  [Kalehuur op einde]    = hpr.kalehuur,
  [Mutatiehuur op einde] = isnull(hpr.streefhuur_oud, hpr.markthuur),
  [Kalehuur nieuw]       = c.kale_huur_bij_ingang
from empire_dwh.dbo.contract as c
inner join empire_dwh.dbo.eenheid as e on
  e.id = c.fk_eenheid_id
left join empire_dwh.dbo.contract as vc on 
  vc.id = c.voorgaand_contract
outer apply empire_staedion_data.[dbo].[ITVfnHuurprijs](e.bk_nr_, vc.dt_einde) as hpr
where c.dt_ingang is not null
GO
