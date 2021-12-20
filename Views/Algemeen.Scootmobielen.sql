SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Algemeen].[Scootmobielen]
as
select 
  omschrijving as technischtype, 
  'Inclusief scootmobielstallingen' as selector 
from empire_data.dbo.vw_lt_mg_type as t 
where soort <> 2
union
select
  omschrijving,
  'Exclusief scootmobielstallingen' as selector
from empire_data.dbo.vw_lt_mg_type as t 
where soort <> 2
and Omschrijving <> 'Scootmobielstalling'
GO
