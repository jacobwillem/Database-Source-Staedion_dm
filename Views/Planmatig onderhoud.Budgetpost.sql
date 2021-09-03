SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Planmatig onderhoud].[Budgetpost]
as

-- RST | 2020-02-05 | dwh tabellen vervangen door staging

select
  [Datum]                                           = nullif(bp.datum,'17530101'),
  [Bedrag excl btw]                                 = bp.[bedrag excl_ btw],
  [Bedrag incl btw]                                 = bp.[bedrag incl_ btw],
  [Sleutel project]                                 = p.lt_id,
  [Sleutel werksoort]                               = ws.lt_id,
  [Sleutel cluster]                                 = c.lt_id
from empire_data.dbo.vw_lt_mg_empire_projectbudgetpost as bp
left join empire_data.dbo.vw_lt_mg_empire_projectbudgetregel br on
  br.mg_bedrijf = bp.mg_bedrijf and
  br.projectnr_ = bp.projectnr_ and
  br.regelnr_ = bp.budgetregelnr_
left join empire_data.dbo.vw_lt_mg_empire_project p on
  p.mg_bedrijf  = br.mg_bedrijf and
  p.Nr_         = br.Projectnr_
left join empire_logic.dbo.lt_mg_empire_werksoort ws on 
  br.mg_bedrijf  = ws.mg_bedrijf and
  br.werksoort   = ws.Code
left join empire_logic.dbo.lt_mg_cluster c on 
  br.mg_bedrijf  = c.mg_bedrijf and
  br.Clusternr_  = c.Nr_

GO
