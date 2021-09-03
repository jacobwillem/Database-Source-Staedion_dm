SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Algemeen].[Klant]
as
select
  [Sleutel]           = k.id,
  [Klant]             = k.descr,
  [Voornaam]          = hh.voornaam,
  [Voorletters]       = hh.voorletters,
  [Tussenvoegsel]     = hh.tussenvoegsel,
  [Achternaam]        = hh.achternaam,
  [Adres]             = hh.adres,
  [Postcode]          = hh.da_postcode,
  [Plaats]            = hh.da_plaats
from empire_dwh.dbo.klant as k
join empire_dwh.dbo.huishouden as hh on 
  hh.id = k.fk_huishouden_id

  
GO
