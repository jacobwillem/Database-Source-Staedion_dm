SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Leegstand].[Leegstandsgeval]
AS
/* ##############################################################################################################
Van Ruben Stolk tbv div PBI-rapportages voor O&V

20211011 JvdW toegevoegd	tbv PBI Leegstand
> [Dagen leegstand vanaf ingang met deze reden]
20211113 JvdW toegevoegd tbv PBI Leegstand - BOG
> select distinct [Leegstandsduur in klasse] from [Leegstand].[Leegstandsgeval]
############################################################################################################## */

SELECT
  [Datum]                           = CONVERT(DATE,dl.datum),
  [Leegstandsnummer]                = dl.leegstandsnummer,
  [Sleutel eenheid]                 = dl.fk_eenheid_id,
  [Reden leegstand]                 = rl.descr,
  [Reden leegstand groep]           = case 
                                        when rl.descr in ('Marktleegstand','Technische leegstand','Markt met bruikleen','Asbestsanering','Nieuwbouw','Verkoop','Bewuste leegstand') then 'Mutatieleegstand'
                                        else rl.descr
                                      end,
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
  [Dagen leegstand vanaf ingang met deze reden] = dl.dagen_vanaf_ingang_reden,
  -- JvdW 20211113 toegevoegd	
  [Leegstandsduur in klasse]		= CASE DATEDIFF(MONTH,dl.dt_ingang, ISNULL(dl.dt_einde,GETDATE()))  
										WHEN 0 THEN '0 <1 maand'
										WHEN 1 THEN '1 tot 2 maanden'
										WHEN 2 THEN '2 tot 3 maanden'
										WHEN 3 THEN '3 tot 12 maanden'
										WHEN 4 THEN '3 tot 12 maanden'
										WHEN 5 THEN '3 tot 12 maanden'
										WHEN 6 THEN '3 tot 12 maanden'
										WHEN 7 THEN '3 tot 12 maanden'
										WHEN 8 THEN '3 tot 12 maanden'
										WHEN 9 THEN '3 tot 12 maanden'
										WHEN 10 THEN '3 tot 12 maanden'
										WHEN 11 THEN '3 tot 12 maanden'
										WHEN 12 THEN '3 tot 12 maanden'
										ELSE 'Overig: > dan 12 maanden' END 
-- select top 10  DATEDIFF(month,dl.dt_ingang, ISNULL(dl.dt_einde,GETDATE())),*
FROM empire_dwh.dbo.d_leegstand AS dl
LEFT JOIN empire_dwh.dbo.redenleegstand AS rl ON
  rl.id = dl.fk_redenleegstand_id
GO
