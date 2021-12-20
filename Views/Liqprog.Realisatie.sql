SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Liqprog].[Realisatie]
as
select
  [Projectnummer] = gle.[Empire Projectnr_],
  [Datum] = EOMONTH(gle.[Posting date]),
  [Bedrag] = SUM(gle.amount)
from empire_data.dbo.Staedion$G_L_Entry as gle
where [Empire Projectnr_] <> ''
and gle.[G_L Account No_] in ('A021310','A023200','A023250','A028120','A028140','A021302','A021304','A021306','A021308')
group by gle.[Empire Projectnr_], EOMONTH(gle.[Posting date])
GO
