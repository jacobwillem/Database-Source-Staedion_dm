SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Leegstand].[Leegstandsgeval JACO]
AS
/* ##############################################################################################################
Van Ruben Stolk tbv div PBI-rapportages voor O&V

20211011 JvdW toegevoegd tbv PBI Leegstand
 > [Dagen leegstand vanaf ingang met deze reden]
20211014 JvdW aanvulling om ook vorige periodes technische leegstand mee te nemen 
>
select [Datum], [Leegstandsnummer], [Sleutel eenheid], [Reden leegstand], [Datum ingang], [Datum einde], [Datum ingang reden], [Datum einde reden], [Dagen leegstand], [Derving netto], [Derving bruto], [Derving kale], [Heeft leegstand ultimo maand], [Heeft momenteel leegstand], [Dagen leegstand vanaf ingang], [Dagen leegstand vanaf ingang met deze reden]
from [Leegstand].[Leegstandsgeval]
except
select [Datum], [Leegstandsnummer], [Sleutel eenheid], [Reden leegstand], [Datum ingang], [Datum einde], [Datum ingang reden], [Datum einde reden], [Dagen leegstand], [Derving netto], [Derving bruto], [Derving kale], [Heeft leegstand ultimo maand], [Heeft momenteel leegstand], [Dagen leegstand vanaf ingang], [Dagen leegstand vanaf ingang met deze reden]
from [Leegstand].[Leegstandsgeval JACO]

select [Datum], [Leegstandsnummer], [Sleutel eenheid], [Reden leegstand], [Datum ingang], [Datum einde], [Datum ingang reden], [Datum einde reden], [Dagen leegstand], [Derving netto], [Derving bruto], [Derving kale], [Heeft leegstand ultimo maand], [Heeft momenteel leegstand], [Dagen leegstand vanaf ingang], [Dagen leegstand vanaf ingang met deze reden]
from [Leegstand].[Leegstandsgeval JACO]
except
select [Datum], [Leegstandsnummer], [Sleutel eenheid], [Reden leegstand], [Datum ingang], [Datum einde], [Datum ingang reden], [Datum einde reden], [Dagen leegstand], [Derving netto], [Derving bruto], [Derving kale], [Heeft leegstand ultimo maand], [Heeft momenteel leegstand], [Dagen leegstand vanaf ingang], [Dagen leegstand vanaf ingang met deze reden]
from [Leegstand].[Leegstandsgeval]


-----------------------------------------------------------------------------------------------------------------
VORIGE VERSIE
-----------------------------------------------------------------------------------------------------------------
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


############################################################################################################## */
WITH CTE_basis
AS (
   SELECT [Datum] = CONVERT(DATE, DL.datum),
          [Leegstandsnummer] = DL.leegstandsnummer,
          [Sleutel eenheid] = DL.fk_eenheid_id,
          [Reden leegstand] = RL.descr,
          [Datum ingang] = CONVERT(DATE, DL.dt_ingang),
          [Datum einde] = CONVERT(DATE, DL.dt_einde),
          [Datum ingang reden] = CONVERT(DATE, DL.dt_ingang_reden),
          [Datum einde reden] = CONVERT(DATE, DL.dt_einde_reden),
          [Dagen leegstand] = DL.dagenleegstand,
          [Derving netto] = DL.dervingnetto,
          [Derving bruto] = DL.dervingbruto,
          [Derving kale] = DL.dervingkale,
          [Heeft leegstand ultimo maand] = CASE
                                               WHEN ISNULL(DL.dt_einde_reden, '99991231') >= DL.datum THEN
                                                   'Ja'
                                               ELSE
                                                   'Nee'
                                           END,
          [Heeft momenteel leegstand] = CASE
                                            WHEN ISNULL(DL.dt_einde, '99991231') >= GETDATE() THEN
                                                'Ja'
                                            ELSE
                                                'Nee'
                                        END,
          [Dagen leegstand vanaf ingang] = DATEDIFF(dd, DL.dt_ingang, ISNULL(DL.dt_einde, GETDATE())),
          -- JvdW 20211011 toegevoegd
          [Dagen leegstand vanaf ingang met deze reden] = DL.dagen_vanaf_ingang_reden
   FROM empire_dwh.dbo.d_leegstand AS DL
       LEFT JOIN empire_dwh.dbo.redenleegstand AS RL
           ON RL.id = DL.fk_redenleegstand_id),
     cte_voorafgaand_1
AS (SELECT D2.leegstandsnummer,
		   RL.descr AS [Reden leegstand],
           D2.Datum,
           D2.dt_ingang_reden,
           D2.dt_einde_reden,
           D2.dagen_vanaf_ingang_reden,
           Opmerking = 'Eerdere periode = ' + CONVERT(NVARCHAR(20), D2.dt_ingang_reden, 105) + '- '
                       + CONVERT(NVARCHAR(20), D2.dt_einde_reden, 105),
           volgnr = ROW_NUMBER() OVER (PARTITION BY D2.leegstandsnummer ORDER BY D2.Datum DESC)
    FROM empire_dwh.dbo.d_leegstand AS D2
	       LEFT JOIN empire_dwh.dbo.redenleegstand AS RL
           ON RL.id = D2.fk_redenleegstand_id
        JOIN
        (
            SELECT DISTINCT
                   leegstandsnummer,
                   [Reden leegstand],
                   Datum,
                   [Datum ingang reden]
            FROM CTE_basis
        ) AS CTE
            ON CTE.leegstandsnummer = D2.leegstandsnummer
               AND CTE.[Reden leegstand] =  RL.descr
               AND CTE.Datum > D2.Datum
               AND CTE.[Datum ingang reden] <> D2.dt_ingang_reden
               AND D2.dt_einde_reden IS NOT NULL)
SELECT BASIS.[Datum],
       BASIS.[Leegstandsnummer],
       BASIS.[Sleutel eenheid],
       BASIS.[Reden leegstand],
       BASIS.[Datum ingang],
       BASIS.[Datum einde],
       BASIS.[Datum ingang reden],
       BASIS.[Datum einde reden],
       BASIS.[Dagen leegstand],
       BASIS.[Derving netto],
       BASIS.[Derving bruto],
       BASIS.[Derving kale],
       BASIS.[Heeft leegstand ultimo maand],
       BASIS.[Heeft momenteel leegstand],
       BASIS.[Dagen leegstand vanaf ingang],
       BASIS.[Dagen leegstand vanaf ingang met deze reden],
       [Dagen leegstand vanaf ingang met deze reden cumulatief] = BASIS.[Dagen leegstand vanaf ingang met deze reden]
                                                                   + COALESCE(CTE_1.dagen_vanaf_ingang_reden, 0),
       Opmerking = 'NB: dagen is inclusief eerdere periode met deze leegstandscode: ' + CTE_1.Opmerking + ' ('
                   + FORMAT(COALESCE(CTE_1.dagen_vanaf_ingang_reden, 0), 'N0') + ' dagen)'
		,KOPIEDATUM = CTE_1.Datum
FROM CTE_basis AS BASIS
    LEFT OUTER JOIN cte_voorafgaand_1 AS CTE_1
        ON CTE_1.leegstandsnummer = BASIS.leegstandsnummer
           AND CTE_1.volgnr = 1
;




GO
