SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Algemeen].[eenheid huren]
as

with cte_contracten as(
  select Eenheidnr_, Volgnr_ from empire_data..staedion$contract where Einddatum > GETDATE() or Einddatum = '17530101'
)
select 
  el.Eenheidnr_ as eenheidnummer,
  SUM(el.[bedrag (lv)]) as kalehuur
from cte_contracten as con
join empire_data.dbo.Staedion$Element as el on
  el.Eenheidnr_ = con.Eenheidnr_ and
  el.Volgnummer = con.Volgnr_
where el.elementsoort = 4
and el.eenmalig = 0
and el.administratie = 0
and el.diversen = 0
group by el.Eenheidnr_

GO
