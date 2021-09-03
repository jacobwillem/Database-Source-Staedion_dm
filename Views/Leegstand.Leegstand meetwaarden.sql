SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Leegstand].[Leegstand meetwaarden]
as
select
  [Datum]                                 = t.datum,
  [Sleutel eenheid]                       = dl.fk_eenheid_id,
  [Derving netto]                         = dl.dervingnetto / convert(numeric(12,5),day(dl.datum)),
  [Derving bruto]                         = dl.dervingbruto / convert(numeric(12,5),day(dl.datum)),
	[leegstandsdagen]												= dl.dagenleegstand / convert(numeric(12,5),day(dl.datum))
from empire_dwh.dbo.d_leegstand dl
cross join empire_logic..dlt_loading_day ld
join empire_dwh.dbo.tijd t on 
  t.maand_value = month(dl.datum) and
  t.jaar = year(dl.datum) and
  t.datum between dateadd(mm,-13, ld.loading_day) and ld.loading_day

GO
