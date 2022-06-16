SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Datakwaliteit].[vw_StudentenwoningenGeboortedatum TEST] AS 
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Check leeftijden huurders van studentenwoningen. Eventueel ook check op opgevoerd studentennummer zoals vastgelegd op generieke kenmerk
Status: test-opzet af te stemmen met aanvrager Marieke
ZIE: Topdesk 22 03 669
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_StudentenwoningenGeboortedatum TEST';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220318 JvdW nav 22 03 669


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
-- vergelijkbaar met aantal eenheden ELS ? Verschil is leegstand ?
SELECT ELS.eenheidnr, 
       ELS.studentenwoning, 
       ELS.[In Exploitatie], 
       ELS.[datum_uit_exploitatie]
-- select distinct studentenwoning
FROM empire_Staedion_data.dbo.els AS ELS
WHERE datum_gegenereerd =
(
    SELECT MAX(datum_gegenereerd)
    FROM empire_Staedion_data.dbo.els
    WHERE datum_gegenereerd < GETDATE()
)
      AND studentenwoning = 'Ja'
      AND ELS.[datum_in_exploitatie] <= GETDATE()
      AND (ELS.[datum_uit_exploitatie] IS NULL
           OR ELS.[datum_uit_exploitatie] = '17530101'
           OR ELS.[datum_uit_exploitatie] = ''
           OR ELS.[datum_uit_exploitatie] >= GETDATE()
		   )
;
--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
############################################################################################################################# */


SELECT CASE
           WHEN(HRD.geboortedatum IS NULL
                OR HRD.geboortedatum = '17530101')
           THEN '1) Onbekende geboortedatum'
           WHEN HRD.Geboortedatum < DATEADD(year, -30, GETDATE())
           THEN '2) Huurder ouder dan 30 jaar'
       END AS Opmerking, 
	   HRD.[OGE Nummer],
	   HRD.[Ingangsdatum],
	   iif(nullif(HRD.[Einddatum], '17530101') IS null, null, HRD.[Einddatum]) AS Einddatum,
	   HRD.[OGE Adres],
	   HRD.[Typeomschrijving],
	   HRD.Verhuurteam,
	   HRD.[CTR Ingangsdatum],
	   HRD.[KLT Nummer],
	   HRD.[KLT Naam 1],
	   HRD.[Schoolnaam],
	   HRD.[Studentnummer],
	   HRD.[Geboortedatum],
       HRD.[Clu nummer] AS [FT-cluster],
	   HRD.[CLU Naam] AS [FL-clusternaam],
	   cast(getdate() AS date) AS Gegenereerd

FROM empire_Staedion_data.[dbo].[huurderslijst] AS HRD
WHERE [OGE nummer] IN
(
    SELECT ELS.eenheidnr --, ELS.studentenwoning, ELS.[In Exploitatie], ELS.[datum_uit_exploitatie]
    -- select distinct studentenwoning
    FROM empire_Staedion_data.dbo.els AS ELS
    WHERE ELS.datum_gegenereerd =
    (
        SELECT MAX(datum_gegenereerd)
        FROM empire_Staedion_data.dbo.els
        WHERE datum_gegenereerd < GETDATE()
    )
          AND ELS.studentenwoning = 'Ja'
)
      AND HRD.Clustersoort = 'FTCLUSTER'
      AND HRD.Ingangsdatum <= GETDATE()
      AND (HRD.Einddatum >= GETDATE()
           OR HRD.Einddatum = '17530101');
--  AND (
--		(HRD.geboortedatum IS null OR HRD.geboortedatum = '17530101')
--  OR	HRD.Geboortedatum < dateadd(year,-30,getdate())  )
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check leeftijden huurders van studentenwoningen. Eventueel ook check op opgevoerd studentennummer zoals vastgelegd op generieke kenmerk
Status: test-opzet af te stemmen met aanvrager Marieke
ZIE: Topdesk 22 03 669
', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'vw_StudentenwoningenGeboortedatum TEST', NULL, NULL
GO
