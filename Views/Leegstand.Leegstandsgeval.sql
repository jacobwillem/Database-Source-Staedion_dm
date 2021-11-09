SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Leegstand].[Leegstandsgeval]
AS
/* ##############################################################################################################
Van Ruben Stolk tbv div PBI-rapportages voor O&V

20211011	JvdW toegevoegd	tbv PBI Leegstand
> [Dagen leegstand vanaf ingang met deze reden]
############################################################################################################## */

SELECT
  [Datum]                           = CONVERT(DATE,dl.datum),
  [Leegstandsnummer]                = dl.leegstandsnummer,
  [Sleutel eenheid]                 = dl.fk_eenheid_id,
  [Reden leegstand]                 = rl.descr,
  [Datum ingang]                    = CONVERT(DATE,dl.dt_ingang),
  [Datum einde]                     = CONVERT(DATE,dl.dt_einde),
  [Datum ingang reden]              = CONVERT(DATE,dl.dt_ingang_reden),
  [Datum einde reden]               = CONVERT(DATE,dl.dt_einde_reden),
  [Dagen leegstand]                 = dl.dagenleegstand,
  [Derving netto]                   = dl.dervingnetto,
  [Derving bruto]                   = dl.dervingbruto,
  [Derving kale]                    = dl.dervingkale,
  [Heeft leegstand ultimo maand]    = CASE WHEN ISNULL(dl.dt_einde_reden,'99991231') >= dl.datum THEN 'Ja' ELSE 'Nee' END,
  [Heeft momenteel leegstand]       = CASE WHEN ISNULL(dl.dt_einde,'99991231') >= GETDATE() THEN 'Ja' ELSE 'Nee' END,
  [Dagen leegstand vanaf ingang]    = DATEDIFF(dd,dl.dt_ingang, ISNULL(dl.dt_einde,GETDATE())),
  -- JvdW 20211011 toegevoegd
  [Dagen leegstand vanaf ingang met deze reden] = dl.dagen_vanaf_ingang_reden
FROM empire_dwh.dbo.d_leegstand AS dl
LEFT JOIN empire_dwh.dbo.redenleegstand AS rl ON
  rl.id = dl.fk_redenleegstand_id
GO
