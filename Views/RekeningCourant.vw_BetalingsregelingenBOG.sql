SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [RekeningCourant].[vw_BetalingsregelingenBOG] AS

SELECT BASIS.[Peildatum],
       BASIS.[Rapportagemaand],
       BASIS.[Betalingsregelingnr],
       BASIS.[Klantnr],
       BASIS.[Klantnaam],
       BASIS.[Boekingsdatum],
       BASIS.[Documentdatum],
       BASIS.[Einddatum],
       BASIS.[Bedrag betalingsregeling],
	   [Betaald deel betalingsregeling] = BASIS.[Bedrag betalingsregeling] -  BASIS.[Openstaand saldo betalingsregeling],
	   BASIS.[Aantal niet vervallen termijnen],
	   BASIS.[Bedrag niet vervallen termijnen],
	   BASIS.[Openstaand saldo betalingsregeling],
       BASIS.[Deurwaarderszaak],
       BASIS.[Derdendossier],
       BASIS.[Leefbaarheidsdossier],
       BASIS.[Betaalwijze huur],
       BASIS.[Betaalwijze regeling],
       BASIS.[Klachtstatus CM],
       BASIS.[Openstaand saldo],
       BASIS.[Afsluitreden],
       BASIS.[Klant status],
       BASIS.[Rapportagestatus_id],
       BASIS.[Huidige status klant],
       BASIS.[Beginstand],
       BASIS.[Aangemaakt],
       BASIS.[Afgerond],
       BASIS.[Eindstand],
       BASIS.[Termijnen],
       BASIS.[Categorie termijnen],
       BASIS.[Categorie termijnen sortering],
       [Huidige periode] = CASE
                               WHEN BASIS.Peildatum =
                               (
                                   SELECT MAX(KOPIE.Peildatum)
                                   FROM [staedion_dm].[RekeningCourant].vw_Betalingsregelingen AS KOPIE
                               ) THEN
                                   'Ja'
                               ELSE
                                   'Nee'
                           END
-- select [Bedrag open termijnen]
FROM RekeningCourant.vw_Betalingsregelingen AS BASIS
    LEFT OUTER JOIN empire_data.dbo.Customer AS CUST
        ON CUST.No_ = BASIS.[Klantnr]
WHERE BASIS.Peildatum >=
(
    SELECT DATEADD(YEAR, -1, MAX(KOPIE.Peildatum))
    FROM [staedion_dm].[RekeningCourant].vw_Betalingsregelingen AS KOPIE
)
      AND CUST.[Responsibility Center] = '85'
GO
