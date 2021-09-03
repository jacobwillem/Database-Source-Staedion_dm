SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Algemeen].[Verhuring_Correctie]
as
/******************************************************************************
* Theoretisch kan een contract in meerdere categorieën vallen, er is een keuze 
* gemaakt om dan 1 van de mogelijke categorieën te kiezen:
* Als er sprake is van Woonfraude bij het voorgaande contract wordt de verhuring gelabeld als Woonfraude
*	bij geen woonfraude wordt gekeken of het voorgaande contract als opzegreden heeft 'Doorstroming'
*   bij geen 'Doorstroming' wordt gekeken of het voorgaande contract als opzegreden heeft 'Woningruil'
*   bij geen 'Woningruil' wordt gekeken het een verhuring betreft aan livable of vps met een huur ongelijk 0 => label 'Tijdelijk'
* alle andere verhuringen worden gelabeld als 'Regulier'
*
******************************************************************************/
WITH opz (
       voorgaand_contract_id
       ,reden
       ,volgnr
       )
       -- bij meerdere mogelijkheden tot labeling wordt eerst gekeken naar label Woonfraude, vervolgens naar Doorstroming en ten slotte naar Woningruil
AS (
       SELECT tot.voorgaand_contract_id
              ,tot.reden
              ,row_number() OVER (
                     PARTITION BY tot.voorgaand_contract_id ORDER BY tot.prioriteit DESC
                     ) volgnr
       FROM (
              SELECT opz.fk_contract_id voorgaand_contract_id
                     ,red.descr reden
                     ,iif(red.id = '05', 100, 500) prioriteit
              FROM empire_dwh.dbo.opzegging_verhuurcontract opz
              INNER JOIN empire_dwh.dbo.redenopzegging red
                     ON opz.fk_redenopzegging_id = red.id
              WHERE red.id IN (
                            '05'
                            ,-- Woningruil
                            '10'
                            ) -- nog te bepalen leegstandscodering voor doorstroming
              
              UNION
              
              SELECT wfd.Contract_id
                     ,'Woonfraude'
                     ,1000
              FROM Verhuur.AfgeslotenWoonfraudeDossiers wfd
              WHERE wfd.Contract_id IS NOT NULL
                     AND wfd.Opmerking = 'Telt mee voor KPI-woonfraude'
              ) AS tot
       )
       ,con (
       [Sleutel contract]
       ,[Datum]
       ,[Sleutel eenheid]
       ,[Sleutel voorgaand contract]
       ,[Verhuring cyclus]
       ,[fk_klant_id]
       ,[nettohuur_bij_ingang]
       ,dt_ingang
       ,bk_eenheidnr
       )
AS (
       SELECT [Sleutel contract] = c.id
              ,[Datum] = c.dt_ingang
              ,[Sleutel eenheid] = c.fk_eenheid_id
              ,
              -- ophalen sleutel van het voorgaande contract op dezelfde eenheid
              [Sleutel voorgaand contract] = lag(c.id, 1, 0) OVER (
                     PARTITION BY c.fk_eenheid_id ORDER BY c.dt_ingang ASC
                     )
              ,ROW_NUMBER() OVER (
                     PARTITION BY c.fk_eenheid_id ORDER BY c.dt_ingang ASC
                     ) AS [Verhuring cyclus]
              ,c.fk_klant_id
              ,c.nettohuur_bij_ingang
              ,c.dt_ingang
              ,c.bk_eenheidnr
       FROM empire_dwh.dbo.contract AS c
       WHERE c.dt_ingang IS NOT NULL
       )
SELECT con.[Sleutel contract]
       ,con.[Datum]
       ,con.[Sleutel eenheid]
       ,con.[Sleutel voorgaand contract]
       ,con.[Verhuring cyclus]
       ,CASE 
              WHEN opz.reden IS NOT NULL
                     THEN opz.reden
              WHEN con.fk_klant_id IN (
                            'KLNT-0068802'
                            ,'KLNT-0059119'
                            ,-- klantnrs Livable
                            'KLNT-0054303'
                            ,'KLNT-0058527'
                            ) -- klantnrs VPS
                     AND con.nettohuur_bij_ingang <> 0
                     THEN 'Tijdelijk'
              ELSE 'Regulier'
              END categorie_oud

-- Nieuwe code
       ,CASE 
              WHEN opz.reden IS NOT NULL
                     THEN opz.reden
              WHEN con.fk_klant_id IN (
                            'KLNT-0068802'
                            ,'KLNT-0059119'
                            ,-- klantnrs Livable
                            'KLNT-0054303'
                            ,'KLNT-0058527'
                            ) -- klantnrs VPS
                     -- and 												con.nettohuur_bij_ingang 
                     AND HPR.nettohuur_incl_korting_btw <> 0
                     THEN 'Tijdelijk'
              WHEN con.fk_klant_id IN (
                            'KLNT-0068802'
                            ,'KLNT-0059119'
                            ,-- klantnrs Livable
                            'KLNT-0054303'
                            ,'KLNT-0058527'
                            ) -- klantnrs VPS
                     -- and 												con.nettohuur_bij_ingang 
                     AND HPR.nettohuur_incl_korting_btw = 0
                     THEN 'Nvt'
              ELSE 'Regulier'
              END categorie_nieuw
       ,con.nettohuur_bij_ingang
       ,[Huur herberekend per ingang incl korting] = HPR.nettohuur_incl_korting_btw
			 ,Eenheidnr = con.bk_eenheidnr
       ,[Klantnrs Livable / VPS] = CASE 
              WHEN con.fk_klant_id IN (
                            'KLNT-0068802'
                            ,'KLNT-0059119'
                            ,-- klantnrs Livable
                            'KLNT-0054303'
                            ,'KLNT-0058527'
                            )
                     THEN con.fk_klant_id
              ELSE NULL
              END
FROM con
LEFT OUTER JOIN opz
       ON con.[Sleutel voorgaand contract] = opz.voorgaand_contract_id
              AND opz.volgnr = 1
OUTER APPLY empire_staedion_data.dbo.ITVfnHuurprijs(con.bk_eenheidnr, con.dt_ingang) AS HPR
GO
