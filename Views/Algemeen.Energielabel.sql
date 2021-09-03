SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Algemeen].[Energielabel]
as
select
  [Energielabel]            = el.Code,
  [Energieindex grenzen]    = el.Description,
  [Grens laag]              = el.[Energieindex laag],
  [Grens hoog]              = el.[Energieindex hoog]
from empire_data..vw_lt_mg_energy_label el
GO
