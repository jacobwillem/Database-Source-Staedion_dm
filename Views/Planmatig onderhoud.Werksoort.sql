SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Planmatig onderhoud].[Werksoort]
as

-- RST | 2020-02-05 | dwh tabellen vervangen door staging

select
  [Sleutel]                           = ew.lt_id,
  [Werksoort]                         = ew.Omschrijving,
  [Werksoort nummer]                  = ew.code
from empire_data..vw_lt_mg_empire_werksoort as ew

GO
