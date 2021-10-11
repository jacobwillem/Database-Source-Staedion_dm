SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Algemeen].[Huurklasse met grens]
as
select  
  [Huurprijsklasse Staedion],
  case when [Huurprijsklasse Staedion] = 'Boven huurprijsgrens' then null else '<= ' + convert(varchar,max(maximum)) end as grens
from Algemeen.Huurklasse
where [Huurprijsklasse Staedion] is not null
and GETDATE() between vanaf and DATEADD(dd,-1,tot)
group by 
  [Huurprijsklasse Staedion], 
  vanaf,
  tot
GO
