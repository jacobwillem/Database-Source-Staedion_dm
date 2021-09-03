SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Algemeen].[Assetmanager] as
select
  [Sleutel]                       = c.no_,
  [Assetmanager]                  = c.name
from empire_data.dbo.Contact as c
  where c.No_ in (
    select distinct Contactnr_
    from empire_data.dbo.mg_cluster_contactpersoon as ccp
    where
      ccp.Functie = 'CB-ASSMAN'
  )
GO
