SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum AS DATE)
RETURNS TABLE 
AS 
/* #########################################################################################################
Microsoft List = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv eerdere functie het kpi-framework 

######################################################################################################### */


RETURN

-- stap 1: alleen snapshot ophalen van meest recente periode gezien gekozen peildatum
WITH cte_laatste_peildatum
AS (SELECT MAX(Peildatum) AS Peildatum
    FROM staedion_dm.Sharepoint.AantallenStartBouwOplevering
    WHERE Peildatum <= @Peildatum),
     cte_basis_gegevens
AS (SELECT Title AS Project,
           Jaar,
           StartOplevering,
           SUM(Jan) AS Jan,
           SUM(Feb) AS Feb,
           SUM(Mrt) AS Mrt,
           SUM(Apr) AS Apr,
           SUM(Mei) AS Mei,
           SUM(Jun) AS Jun,
           SUM(Jul) AS Jul,
           SUM(Aug) AS Aug,
           SUM(Sept) AS Sept,
           SUM(Okt) AS Okt,
           SUM(Nov) AS Nov,
           SUM([Dec]) AS [Dec],
           MAX(TijdstipGenereren) AS TijdstipGenereren,
           MAX(Projectnummer) AS Projectnummer,
           MAX([FT-cluster]) AS [FT-cluster],
           MAX(Peildatum) AS Peildatum,
           MAX([TypeProject]) AS [TypeProject],
		   MAX(ProjectManager) AS ProjectManager,
           IIF(COUNT(*) > 1, 'Let op meerdere regels opgevoerd voor zelfde project-jaar', NULL) AS Opmerking
    -- select *
    FROM staedion_dm.Sharepoint.AantallenStartBouwOplevering
    WHERE Peildatum =
    (
        SELECT Peildatum FROM cte_laatste_peildatum
    )
    --AND Title = 'Florence Houthaghe'
    GROUP BY Title,
             StartOplevering,
             Jaar),
     -- stap 2: aantallen omzetten van kolommen naar peildatum + jaar 2022 / kolom juni wordt rij 2022-06-01
     cte_van_kolommen_naar_rijen
AS (SELECT DATEFROMPARTS(   Jaar,
                            CASE UNPIV.Maand
                                WHEN 'Jan' THEN
                                    1
                                WHEN 'Feb' THEN
                                    2
                                WHEN 'Mrt' THEN
                                    3
                                WHEN 'Apr' THEN
                                    4
                                WHEN 'Mei' THEN
                                    5
                                WHEN 'Jun' THEN
                                    6
                                WHEN 'Jul' THEN
                                    7
                                WHEN 'Aug' THEN
                                    8
                                WHEN 'Sept' THEN
                                    9
                                WHEN 'Okt' THEN
                                    10
                                WHEN 'Nov' THEN
                                    11
                                WHEN 'Dec' THEN
                                    12
                            END,
                            1
                        ) AS Periode,
           UNPIV.Maand,
           UNPIV.Aantallen * IIF(StartOplevering = 'Start', +1, -1) AS Aantal,
           Project,
           Projectnummer,
           [FT-cluster],
           StartOplevering,
           [TypeProject],
		   ProjectManager,
           CAST(TijdstipGenereren AS DATE) AS Laaddatum,
           Peildatum
    FROM cte_basis_gegevens
        UNPIVOT
        (
            Aantallen
            FOR Maand IN (Jan, Feb, Mrt, Apr, Mei, Jun, Jul, Aug, Sept, Okt, Nov, [Dec])
        ) AS UNPIV
    WHERE 1 = 1)

-- stap 3: alles optellen tot aan peildatum - mag niet negatief worden per project
-- NB soms projectnaam zelfde en in meerdere jaren opgevoerd met andere ft / projectnr: dan gegroepeerd - anders kunnen tellingen fout gaan
SELECT ALLES.Project,
       MAX(COALESCE(ALLES.[FT-cluster], '')) AS [FT-cluster],
       MAX(COALESCE(ALLES.[Projectnummer], '')) AS [Projectnummer],
       IIF(SUM(ALLES.Aantal) < 0, 0, SUM(ALLES.Aantal)) AS Onderhandenwerk,
       ALLES.Laaddatum,
       MIN(ALLES.TypeProject) AS TypeProject,
       MIN(ALLES.StartOplevering) AS StartOplevering,
	   MIN(ALLES.Projectmanager) AS Projectmanager,
       CONCAT(
                 ALLES.Project,
                 '; ',
                 MIN(ALLES.TypeProject),
                 '; ',
                 MIN(ALLES.ProjectManager),
                 '; ',
                 'Start minus oplevering cum: ' + FORMAT(SUM(ALLES.Aantal), 'N0')
             ) AS Omschrijving,
       COUNT(*) AS AantalRegels
FROM cte_van_kolommen_naar_rijen AS ALLES
WHERE ALLES.Periode <= COALESCE(@Peildatum, GETDATE())
GROUP BY ALLES.Project,
         ALLES.Laaddatum;
GO
EXEC sp_addextendedproperty N'MS_Description', N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
BRON: Microsoft list (https://staedionict.sharepoint.com/sites/onderhoud-vastgoed/afdelingprojecten/Lists/Aantallen Start Bouw%20 Oplevering)
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Functie [Projecten].[fn_AantallenProjectenMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en en haalt start- en oplever-aantallen op project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum.
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv functie fn_AantallenOnderhandenWerkMicrosoftList het kpi-framework incl prognoses voor resterende maanden
* Stored procedure [Dashboard].[sp_load_kpis_projecten]
Vult adhv functie fn_AantallenProjectenMicrosoftList het kpi-framework voor meerdere kps incl prognoses voor resterende maanden
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen', 'SCHEMA', N'Projecten', 'FUNCTION', N'fn_AantallenOnderhandenWerkMicrosoftList', NULL, NULL
GO
