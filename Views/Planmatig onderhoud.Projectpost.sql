SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Planmatig onderhoud].[Projectpost]
as

-- RST | 2020-02-05 | dwh tabellen vervangen door staging

select
  [Datum]                                           = nullif(ejle.[posting date],  '17530101'),
  [Kosten]                                          = case when ejle.[total price] <> 0  then 0 else ejle.[total cost] end,
  [Opbrengsten]                                     = ejle.[total price],
  [Opbrengsten incl btw]                            = ejle.[Total Price incl_ VAT],
  [Sleutel project]                                 = p.lt_id,
  [Sleutel werksoort]                               = ws.lt_id,
  [Sleutel cluster]                                 = c.lt_id
from empire_data.dbo.vw_lt_mg_empire_job_ledger_entry ejle
left join empire_data.dbo.vw_lt_mg_empire_projectbudgetregel as br on
  ejle.mg_bedrijf = br.mg_bedrijf and
  ejle.[Job No_] = br.Projectnr_ and
  ejle.[Budgetline No_] = br.Regelnr_
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
