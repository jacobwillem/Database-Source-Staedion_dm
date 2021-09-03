SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Planmatig onderhoud].[Project]
as
select
  [Sleutel]                               = p.lt_id,
  [Projectnummer]                         = p.Nr_,
  [Projectomschrijving]                   = p.Omschrijving,
  [Projectnaam]                           = p.Naam,
  [Datum start]                           = p.Startdatum,
  [Datum gereed]                          = nullif(p.[Datum gereed], '17530101'),
  [Status project]                        = s.Omschrijving,
  [Type project]                          = t.Omschrijving,
  [Jaar]                                  = p.jaar,
  [Clusternummer]                         = p.Clusternr_
from empire_data.dbo.vw_lt_mg_empire_project as p
left join empire_data.dbo.vw_lt_mg_empire_projectstatus as s on 
  p.mg_bedrijf          = s.mg_bedrijf and
  p.Status              = s.Code
left join empire_data.dbo.vw_lt_mg_empire_projecttype as t on 
  p.mg_bedrijf          = t.mg_bedrijf and
  p.type                = t.Code
left join empire_logic.dbo.lt_mg_cluster as cl on
  cl.mg_bedrijf = p.mg_bedrijf and
  cl.Nr_ = p.Clusternr_




GO
