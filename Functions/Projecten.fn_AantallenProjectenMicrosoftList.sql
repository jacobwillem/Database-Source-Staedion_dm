SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Projecten].[fn_AantallenProjectenMicrosoftList] (@Peildatum AS DATE)
RETURNS TABLE 
AS 
/* #########################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
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
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen'
		,@level0type = N'SCHEMA'
       ,@level0name = 'Projecten'
       ,@level1type = N'FUNCTION'
       ,@level1name = 'fn_AantallenProjectenMicrosoftList';
GO
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
           Jan,Feb,Mrt,Apr,Mei,Jun,Jul,Aug,Sept,Okt,Nov,[Dec],
           TijdstipGenereren, Projectnummer,[FT-cluster],Peildatum,[TypeProject],ProjectManager
    -- select *
    FROM staedion_dm.Sharepoint.AantallenStartBouwOplevering
    WHERE Peildatum = (SELECT Peildatum FROM cte_laatste_peildatum)
    --AND Title = 'Florence Houthaghe'
    ),
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
           UNPIV.Aantal,
		   Jaar,
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
            Aantal
            FOR Maand IN (Jan, Feb, Mrt, Apr, Mei, Jun, Jul, Aug, Sept, Okt, Nov, [Dec])
        ) AS UNPIV
    WHERE 1 = 1)

-- stap 3: alles optellen tot aan peildatum - mag niet negatief worden per project
-- NB soms projectnaam zelfde en in meerdere jaren opgevoerd met andere ft / projectnr: dan gegroepeerd - anders kunnen tellingen fout gaan
SELECT	ALLES.Project,
		EOMONTH(ALLES.Periode) AS Peildatum,
		ALLES.Jaar,
		COALESCE(ALLES.[FT-cluster], '') AS [FT-cluster],
		COALESCE(ALLES.[Projectnummer], '') AS [Projectnummer],
		ALLES.Aantal AS Aantal,
		ALLES.Laaddatum,
		ALLES.TypeProject,
		ALLES.StartOplevering,
		ALLES.Projectmanager,
		CONCAT(ALLES.Project,
                 '; ',
                 ALLES.TypeProject,
                 '; ',
                 ALLES.ProjectManager,
                 '; ',
                 'Aantal: ' + FORMAT(ALLES.Aantal, 'N0')
             ) AS Omschrijving
FROM cte_van_kolommen_naar_rijen AS ALLES
WHERE ALLES.Periode <= COALESCE(@Peildatum, GETDATE())
AND YEAR(ALLES.Periode) = YEAR(COALESCE(@Peildatum, GETDATE()))
;
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
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen', 'SCHEMA', N'Projecten', 'FUNCTION', N'fn_AantallenProjectenMicrosoftList', NULL, NULL
GO
