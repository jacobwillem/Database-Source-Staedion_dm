SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Leegstand].[Leegstand meetwaarden]
AS SELECT [Datum] = t.datum,
       [Sleutel eenheid] = dl.fk_eenheid_id,
       [Derving netto] = dl.dervingnetto / CONVERT(NUMERIC(12, 5), DAY(dl.datum)),
       [Derving bruto] = dl.dervingbruto / CONVERT(NUMERIC(12, 5), DAY(dl.datum)),
       [leegstandsdagen] = dl.dagenleegstand / CONVERT(NUMERIC(12, 5), DAY(dl.datum))
	   --,       [reden leegstand] = dl.fk_redenleegstand_id  -- JvdW tijdelijk tbv 21 12 1070 
-- select top 10 * 
FROM empire_dwh.dbo.d_leegstand dl
    CROSS JOIN empire_logic..dlt_loading_day ld
    JOIN empire_dwh.dbo.tijd t
        ON t.maand_value = MONTH(dl.datum)
           AND t.jaar = YEAR(dl.datum)
           AND t.datum
           BETWEEN DATEADD(mm, -13, ld.loading_day) AND ld.loading_day;

GO
