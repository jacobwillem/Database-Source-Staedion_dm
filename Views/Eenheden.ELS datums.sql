SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Eenheden].[ELS datums]
as
with cte as (
select distinct 
  [Datum] = datum_gegenereerd
from empire_staedion_data.dbo.els
)
select
  [Datum],
  [Sortering aflopend] = ROW_NUMBER() over (partition by datum order by datum desc) 
from cte

GO
