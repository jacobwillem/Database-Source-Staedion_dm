SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  CREATE VIEW [Dashboard].[check_kcm_aantallen]
  AS 
  (
  SELECT controle_brontabel = 'stn407', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn407_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn410', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn410_Ingevulde_gegevens UNION ALL
  SELECT controle_brontabel = 'stn417', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn417_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn418', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn418_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn420', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn420_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn421', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn421_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn647', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn647_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn658', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn658_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn659', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn659_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn660', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn660_Ingevulde_gegevens UNION all
  SELECT controle_brontabel = 'stn661', datum = convert(date,[Ingevulde gegevens]) FROM empire_staedion_data.kcm.stn661_Ingevulde_gegevens 
  )
GO
