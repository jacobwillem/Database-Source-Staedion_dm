SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [RekeningCourant].[vw_BetalingsregelingenKCM]
AS
/* #########################################################################################################################################
VAN		Jaco van der Wel
DOEL	View over onderliggende tabel heen voor aanlevering kcm-data - welke betalingsregelingen zijn laatste 31 dagen aangemaakt
--------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------------------
20220111 JvdW Topdesk 21 11 278

--------------------------------------------------------------------------------------------------------------------------------------------
TESTEN
--------------------------------------------------------------------------------------------------------------------------------------------
select * from staedion_dm.[RekeningCourant].[vw_BetalingsregelingenKCM]

--------------------------------------------------------------------------------------------------------------------------------------------
STEEKPROEF
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Nr as nvarchar(20) = 'BETR-2200124'
Declare @Peildatum as date = '20220111'

-- bronbestand Empire
select btr.*
  FROM [empire_data].[dbo].[Staedion$Payment_Scheme] as btr
            INNER JOIN [empire_data].[dbo].[Staedion$Payment_Scheme_Line] reg
                ON btr.Code = reg.Code
        WHERE btr.[Termination Code] NOT IN ( 'FB' )
				and btr.Code = @Nr
				and btr.[Posting Date] <= @Peildatum
;


########################################################################################################################################## */
WITH cte_contract_zittend ([Customer No_])
AS (SELECT adi.[Customer No_]
    FROM empire_data.[dbo].[Staedion$Additioneel] adi
    WHERE adi.Ingangsdatum <= GETDATE()
          AND
          (
              adi.Einddatum = '1753-01-01'
              OR adi.Ingangsdatum >= GETDATE()
          )
    GROUP BY adi.[Customer No_])
-- toevoegen huidige status huurder ?
SELECT DISTINCT
       BETR.Peildatum,
       BETR.Betalingsregelingnr,
       BETR.[Klantnr] AS Huurdernr,
       [Aanhef Huurdernaam] = ITVF.aanhef,
       [Huurdernaam] = ITVF.klantnaam,
       [Telefoonnr 1] = COALESCE(ITVF.telefoon1, ITVF.[Telefoon overdag]),
       [Telefoonnr 2] = ITVF.[telefoon 2],
       [Telefoonnr 3] = ITVF.[telefoon 3],
       [Emailadres] = COALESCE(
                                  NULLIF(ITVF.[E-Mail], ''),
                                  NULLIF(ITVF.[E-Mail 2], ''),
                                  NULLIF(ITVF.[E-Mail 3], ''),
                                  NULLIF(ITVF.[E-Mail 4], ''),
                                  NULLIF(ITVF.[E-Mail 5], '')
                              ),
       BETR.Boekingsdatum,
       BETR.Documentdatum,
       BETR.Einddatum,
       BETR.[Bedrag betalingsregeling], -- = SUM(BETR.[Bedrag betalingsregeling])
       BETR.[Openstaand saldo betalingsregeling],
       BETR.Rapportagestatus_id,
       [Huidige status klant] = IIF(CONTR.[Customer No_] IS NULL, 'Vertrokken', 'Zittend'),
       [Aantal termijnen] = CASE
                                   WHEN COALESCE(Termijnen, 0) <= 0 THEN
                                       'geen termijnen'
                                   ELSE
                                       CASE
                                           WHEN Termijnen <= 1 THEN
                                               '1 termijn'
                                           ELSE
                                               CASE
                                                   WHEN Termijnen < 4 THEN
                                                       '2-3 termijnen'
                                                   ELSE
                                                       CASE
                                                           WHEN Termijnen < 7 THEN
                                                               '4-6 termijnen'
                                                           ELSE
                                                               CASE
                                                                   WHEN Termijnen < 13 THEN
                                                                       '7-12 termijnen'
                                                                   ELSE
                                                                       '13+ termijnen'
                                                               END
                                                       END
                                               END
                                       END
                               END,
       BETR.[Aangemaakt door],
	   BETR.Eenheidnr,
       OGE.Straatnaam + ' ' + COALESCE(RTRIM(CAST(OGE.huisnr_ AS CHAR(10))), '') + ISNULL(' ' + OGE.toevoegsel, '') AS Eenheidadres,
	   OGE.Straatnaam,
	   RTRIM(CONCAT(OGE.Huisnr_,' ',OGE.Toevoegsel)) AS huisnr,
	   OGE.plaats AS Stad,
	   OGE.[Postcode],
       I.Clusternr,
       I.Clusternaam,
       I.Bouwblok,
       I.Bouwbloknaam,
       ITVF.[Indicatie overleden]
-- select count(*), count(distinct convert(nvarchar(20),Peildatum,105) + '|' + Betalingsregelingnr)
-- select BETR.*
FROM [staedion_dm].[RekeningCourant].[Betalingsregelingen] AS BETR
    LEFT OUTER JOIN empire_data.dbo.staedion$oge AS OGE
        ON OGE.Nr_ = BETR.Eenheidnr
    LEFT OUTER JOIN cte_contract_zittend AS CONTR
        ON BETR.Klantnr = CONTR.[Customer No_]
    CROSS APPLY staedion_dm.[Eenheden].[fn_CLusterBouwblok](COALESCE(BETR.Eenheidnr, 'nvt')) AS I
    CROSS APPLY empire_staedion_data.dbo.ITVfnContractaanhef(BETR.Klantnr) AS ITVF
WHERE YEAR(BETR.Peildatum) = YEAR(GETDATE())
      AND MONTH(BETR.Peildatum) = MONTH(GETDATE())
      AND BETR.Documentdatum >= DATEADD(d, -31, GETDATE());

GO
EXEC sp_addextendedproperty N'MS_Description', N'View over onderliggende tabel heen voor aanlevering kcm-data - welke betalingsregelingen zijn laatste 31 dagen aangemaakt', 'SCHEMA', N'RekeningCourant', 'VIEW', N'vw_BetalingsregelingenKCM', NULL, NULL
GO
