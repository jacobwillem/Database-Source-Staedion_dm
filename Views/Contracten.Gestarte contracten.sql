SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Contracten].[Gestarte contracten]
AS
SELECT
  Datum                  = c.dt_ingang,
  [Sleutel contract]     = c.id,
  [Sleutel eenheid]      = c.fk_eenheid_id,
  [Sleutel klant]        = c.fk_klant_id,
  [Kalehuur op einde]    = hpr.kalehuur,
  [Mutatiehuur op einde] = ISNULL(hpr.streefhuur_oud, hpr.markthuur),
  [Kalehuur nieuw]       = c.kale_huur_bij_ingang
FROM empire_dwh.dbo.[contract] AS c
INNER JOIN empire_dwh.dbo.eenheid AS e ON
  e.id = c.fk_eenheid_id
LEFT JOIN empire_dwh.dbo.[contract] AS vc ON 
  vc.id = c.voorgaand_contract
OUTER APPLY empire_staedion_data.[dbo].[ITVfnHuurprijs](e.bk_nr_, vc.dt_einde) AS hpr
WHERE c.dt_ingang IS NOT NULL
GO
