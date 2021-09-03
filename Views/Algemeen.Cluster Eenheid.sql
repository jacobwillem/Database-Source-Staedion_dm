SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Algemeen].[Cluster Eenheid]
as
select
  [Sleutel cluster]  = cl.lt_id,
  [Sleutel eenheid]  = o.lt_id
from empire_data.dbo.mg_cluster_oge as co
join empire_logic.dbo.lt_mg_cluster as cl on
  cl.mg_bedrijf = co.mg_bedrijf and
  cl.Nr_ = co.Clusternr_
join empire_logic.dbo.lt_mg_oge as o on
  o.mg_bedrijf = co.mg_bedrijf and
  o.Nr_ = co.Eenheidnr_
GO
