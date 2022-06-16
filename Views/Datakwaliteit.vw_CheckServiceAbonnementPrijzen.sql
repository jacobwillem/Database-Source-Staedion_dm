SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Datakwaliteit].[vw_CheckServiceAbonnementPrijzen]
AS

-- Query AfwijkendeData
WITH cte_ActueleContractRegels
AS (
       SELECT Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs], [Status contractregel], [Ingangsdatum]
       FROM staedion_dm.[Contracten].vw_NieuwsteContractRegels
       WHERE Elementnr IN (
                     '404'
                     ,'405'
                     ,'407'
                     ,'408'
                     ,'409'
                     ,'410'
                     ,'411'
                     ,'412'
                     ,'413'
                     ,'415'
                     )
       )
SELECT Toelichting = ' Afwijking standaardprijs 404,413,415'
       ,Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs],[Status contractregel],[Ingangsdatum]
FROM cte_ActueleContractRegels
WHERE [Afwijking standaardprijs] IS NOT NULL
       AND Elementnr IN (
              '404'
              ,'413'
              ,'415'
              )

UNION

SELECT Toelichting = 'Service-abonnement niet op woning'
       ,Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs],[Status contractregel],[Ingangsdatum]
FROM cte_ActueleContractRegels
WHERE Eenheidnr NOT IN (
              SELECT Eenheidnummer
              FROM staedion_dm.algemeen.Eenheid
              WHERE [Eenheidtype Corpodata] LIKE 'WON%'
                     AND bedrijf = 'Staedion'
              )

--UNION

--SELECT Toelichting = 'Service-abonnement niet op woning'
--       ,Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs]
--FROM cte_ActueleContractRegels
--WHERE Elementnr NOT IN (
--              '404'
--              ,'413'
--              ,'415'
--              )







GO
