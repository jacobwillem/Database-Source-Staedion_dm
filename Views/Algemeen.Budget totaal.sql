SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [Algemeen].[Budget totaal]
as
select
 [Datum],
 [Sleutel grootboekrekening],
 [Sleutel cluster],
 [Cluster],
 [Budget],
 [Budgetnaam],
 [Rekeningnummer],
 [Op basis van verdeelsleutel]
from [Algemeen].[Budget waarderendement]
where year(datum) <> 2020
union all 
select
 [Datum],
 [Sleutel grootboekrekening],
 [Sleutel cluster],
 [Cluster],
 [Budget],
 [Budgetnaam],
 [Rekeningnummer],
 null
from [Algemeen].[Budget 2020 verdeeld]


GO
