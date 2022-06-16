SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Datakwaliteit].[vw_WoningenZonderWoningWaardering] AS 
/* ###############################################################################################################
BETREFT: view tbv PowerBi dashboard Datakwaliteit

EXEC sys.sp_updateextendedproperty @name = N'MS_Description'
       ,@value = N'BETREFT: view tbv PowerBi dashboard Datakwaliteit
TOELICHTING: In exploitatie zijnde woningen (ook onzelfstandige) zonder woningwaardering (of wel punten gevonden, maar onder de 10)
BRON: staedion_dm.datakwaliteit.vw_WoningenZonderWoningWaardering
View op brondata Empire. Geeft datacontrole-lijst weer op basis van volgende voorwaarden:
- woningen of onzelfstandige woningen volgens typologie Corpodata
- geen woningwaardering
- eenheid met datum in exploitatie
- eenheid zonder datum uit exploitatie
- status eenheidskaart verhuurd of leegstand'
		,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_WoningenZonderWoningWaardering';
GO

------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------------
20220201 JvdW Obv schema Huurbeleid opgesteld in samenwerking met Sophie van Welie


############################################################################################################### */



SELECT OGE.Nr_ AS eenheidnr,
       OGE.straatnaam + ' ' + OGE.huisnr_ + ' ' + OGE.Toevoegsel AS [Adres eenheid],
       CONT.[Assetmanager],
       TT.Omschrijving AS [Omschrijving technisch type],
       OGE.[Target Group Code] AS Doelgroepcode,
       HPR.huurbeleid AS Huurbeleid,
       CONVERT(FLOAT, HPR.kalehuur) AS Kalehuur,
       CONVERT(FLOAT, HPR.aftopgrens) AS Aftopgrens,
       CONVERT(FLOAT, HPR.markthuur) AS Markthuur,
       HPR.[Totaal_punten_afgerond],
       CONVERT(FLOAT, HPR.[Maximaal_toegestane_huur]) AS [Maximaal toegestane huur],
       HPR.perc_max_red_huur AS [Percentage maximaal redelijke huur],
       HPR.streefhuur_oud AS [Mutatiehuur],
       CAST(GETDATE() AS DATE) AS [Gegenereerd op],
       -- tbv insert in RealisatieDetails tabel
       1 AS Waarde,
       CAST(GETDATE() AS DATE) AS Laaddatum,
        CONCAT(
                 OGE.straatnaam + ' ' + OGE.huisnr_ + ' ' + OGE.Toevoegsel,
                 '; doelgroep: ',
                 OGE.[Target Group Code],
                 ';',
                 CONT.[Assetmanager],
                 '; mutatiehuur: ',
                 FORMAT(HPR.streefhuur_oud, '#.##'),
                 '; wwd: ',
                 FORMAT(HPR.[Totaal_punten_afgerond], '#.##')
             ) AS Omschrijving,
       NULL AS Teller,
       NULL AS Noemer,
       NULL AS Klantnr,
       CONVERT(DATE, NULL) AS datEinde,
       CONVERT(DATE, NULL) AS datIngang,
       NULL AS Hyperlink,
       'Geen woningwaarderingspunten gevonden (of onder de 10 punten)' AS Bevinding,
       NULL AS Gebruiker,
       NULL AS Relatienr
FROM empire_data.dbo.staedion$Oge AS OGE
    LEFT OUTER JOIN empire_data.dbo.staedion$type AS TT
        ON TT.Code = OGE.[Type]
           AND TT.[Soort] <> 2
    OUTER APPLY empire_staedion_data.dbo.[ITVfnHuurprijs](OGE.Nr_, GETDATE()) AS HPR
    OUTER APPLY staedion_dm.[Eenheden].[fn_ContactbeheerInclNaam](OGE.Nr_) AS CONT
WHERE (
          NULLIF(HPR.[Totaal_punten_afgerond], 0) IS NULL
          OR HPR.[Totaal_punten_afgerond] < 10
      )
      AND TT.[Analysis Group Code] LIKE '%WON%'
      AND OGE.[Begin exploitatie] <> '17530101'
      AND OGE.[Einde exploitatie] = '17530101'
      AND OGE.[Status] IN ( 0, 3 ) -- 0 then 'Leegstand' when 1 then 'Uit beheer' when 2 then 'Renovatie' when 3 then 'Verhuurd' when 4 then 'Administratief' when 5 then 'Verkocht' 		when 6 then 'In ontwikkeling' end status_eenheidskaart,
;
GO
EXEC sp_addextendedproperty N'MS_Description', N'BETREFT: view tbv PowerBi dashboard Datakwaliteit
TOELICHTING: In exploitatie zijnde woningen (ook onzelfstandige) zonder woningwaardering (of wel punten gevonden, maar onder de 10)
BRON: staedion_dm.datakwaliteit.vw_WoningenZonderWoningWaardering
View op brondata Empire. Geeft datacontrole-lijst weer op basis van volgende voorwaarden:
- woningen of onzelfstandige woningen volgens typologie Corpodata
- geen woningwaardering
- eenheid met datum in exploitatie
- eenheid zonder datum uit exploitatie
- status eenheidskaart verhuurd of leegstand', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'vw_WoningenZonderWoningWaardering', NULL, NULL
GO
