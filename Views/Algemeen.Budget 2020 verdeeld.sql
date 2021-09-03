SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
  CREATE view [Algemeen].[Budget 2020 verdeeld]
  as
  with cte_tot
  as(
  select * from [Algemeen].[Budget 2020]
  where cluster is not null
  union all
  select * from [Algemeen].[budget verdeeld]
  )


  select * from cte_tot
 -- where Rekeningnummer = 'A815420'

GO
