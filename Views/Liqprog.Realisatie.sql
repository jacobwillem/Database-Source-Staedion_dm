SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Liqprog].[Realisatie]
as
select
  [Projectnummer] = gle.[Empire Projectnr_],
  [Datum] = EOMONTH(gle.[Posting date]),
  [Bedrag] = SUM(gle.amount)
from empire_data.dbo.Staedion$G_L_Entry as gle
where [Empire Projectnr_] <> ''
and [Posting Date] >= (select first_of_year from empire_logic.dbo.vw_dates)
group by gle.[Empire Projectnr_], EOMONTH(gle.[Posting date])
GO
