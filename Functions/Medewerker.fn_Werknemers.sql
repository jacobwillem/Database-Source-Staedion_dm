SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  function [Medewerker].[fn_Werknemers] (@Laaddatum as date = null) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Medewerker gegevens ophalen van wat er dagelijks via xml wordt ingelezen
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: [20201021 Nav Werkgroep Datakwaliteit]


------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Medewerker', 'fn_Werknemers'



------------------------------------------------------------------------------------------------------
TE DOEN
------------------------------------------------------------------------------------------------------
Dubbele personeelsnr - gaat dat goed ?
select * from TS_data.dbo.SnapshotWerknemer where  Personeelsnr in (736015,1008340,1009620,1010680)
select * from TS_Data.[dbo].[fn_Werknemers] (default)  where  Personeelsnr in (736015,1008340,1009620,1010680)

------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
-- performance alle data
-- dubbele ?
SELECT count(*), count(distinct personeelsnr), sum(FTE)
FROM    [Medewerker].[fn_Werknemers] (default)

SELECT count(*), count(distinct personeelsnr)
FROM   TS_data.dbo.SnapshotWerknemer 
where	 Laaddatum = (select max(Laaddatum) from  TS_data.dbo.SnapshotWerknemer )

-- formatie
SELECT [Aantal regels] = count(*), [Aantal personeelnrs] = count(distinct personeelsnr), [Totale fte] = sum(FTE)
			,[Tijdelijke formatie x fte] = sum([Tijdelijke formatie]*FTE)
			,[Aantal met tijdelijke formatie] = sum([Tijdelijke formatie])
FROM    [Medewerker].[fn_Werknemers] ('20201230')
where	 werknemersgroep = 'werknemers'
union
SELECT [Aantal regels] = count(*), [Aantal personeelnrs] = count(distinct personeelsnr), [Totale fte] = sum(FTE)
			,[Tijdelijke formatie x fte] = sum([Tijdelijke formatie]*FTE)
			,[Aantal met tijdelijke formatie] = sum([Tijdelijke formatie])
FROM    [Medewerker].[fn_Werknemers] ('20201231')
where	 werknemersgroep = 'werknemers'
union
SELECT [Aantal regels] = count(*), [Aantal personeelnrs] = count(distinct personeelsnr),[Totale fte] = sum(FTE)
			,[Tijdelijke formatie x fte] =  sum([Tijdelijke formatie]*FTE)
			,[Aantal met tijdelijke formatie] =  sum([Tijdelijke formatie])
FROM    [Medewerker].[fn_Werknemers] ('20201230')
where	 werknemersgroep = 'externen'

------------------------------------------------------------------------------------------------------
TEST
------------------------------------------------------------------------------------------------------
SELECT 'Gewijzigd'
       ,NIEUW.Personeelsnr
       ,NIEUW.Naam
       ,NIEUW.Functie
       ,FTE = sum(NIEUW.FTE) - sum(OUD.FTE)
       ,NIEUW.[Datum in dienst]
       ,NIEUW.[Datum uit dienst]
       ,NIEUW.Werknemersgroep
FROM  [Medewerker].[fn_Werknemers]('20201231') AS NIEUW
JOIN  [Medewerker].[fn_Werknemers]('20201230') AS OUD
       ON NIEUW.Personeelsnr = OUD.Personeelsnr
			 and NIEUW.Kostenplaats = OUD.Kostenplaats
where coalesce(NIEUW.Personeelsnr,OUD.Personeelsnr) = '1010680'
GROUP BY NIEUW.Personeelsnr
       ,NIEUW.Naam
       ,NIEUW.Functie
       ,NIEUW.[Datum in dienst]
       ,NIEUW.[Datum uit dienst]
       ,NIEUW.Werknemersgroep
HAVING abs(sum(NIEUW.FTE) - sum(OUD.FTE)) >= 0.01

SELECT personeelsnr, Naam, FTE, [Aantal uren],Kostenplaats,[Datum in dienst]
       ,[Datum uit dienst],Functie
FROM    [Medewerker].[fn_Werknemers] ('20201230')
where	 personeelsnr = '1010680'

SELECT personeelsnr, Naam, FTE, [Aantal uren], Kostenplaats,[Datum in dienst]
       ,[Datum uit dienst],Functie
FROM    [Medewerker].[fn_Werknemers] ('20201231')
where	 personeelsnr = '1010680'


-- Nog niet helemaal waterdicht
DECLARE @Nieuw AS DATE = '20201231'
DECLARE @Oud AS DATE = '20201230'

SELECT [Soort wijziging] = 'Nieuw'
       ,Personeelsnr
       ,Naam
       ,Functie
       ,FTE * 1  
       ,[Datum in dienst]
       ,[Datum uit dienst]
       ,Werknemersgroep
FROM    [Medewerker].[fn_Werknemers](@Nieuw) as Een
WHERE   NOT exists (
              SELECT 1
              FROM  [Medewerker].[fn_Werknemers](@Oud) as Twee
							where Een.Personeelsnr = Twee.Personeelsnr
							and Een.Kostenplaats = Twee.Kostenplaats
              )

UNION

SELECT 'Vertrokken'
       ,Personeelsnr
       ,Naam
       ,Functie
       ,FTE * - 1
       ,[Datum in dienst]
       ,[Datum uit dienst]
       ,Werknemersgroep
FROM    [Medewerker].[fn_Werknemers](@Oud) as Een
WHERE  NOT exists (
              SELECT 1
              FROM t [Medewerker].[fn_Werknemers](@Nieuw) as Twee
							where Een.Personeelsnr = Twee.Personeelsnr
							and Een.Kostenplaats = Twee.Kostenplaats
              )

UNION

SELECT 'Gewijzigd'
       ,NIEUW.Personeelsnr
       ,NIEUW.Naam
       ,NIEUW.Functie
       ,FTE = sum(NIEUW.FTE) - sum(OUD.FTE)
       ,NIEUW.[Datum in dienst]
       ,NIEUW.[Datum uit dienst]
       ,NIEUW.Werknemersgroep
FROM  [Medewerker].[fn_Werknemers](@Nieuw) AS NIEUW
JOIN  [Medewerker].[fn_Werknemers](@Oud) AS OUD
       ON NIEUW.Personeelsnr = OUD.Personeelsnr
			 and NIEUW.Kostenplaats = OUD.Kostenplaats
GROUP BY NIEUW.Personeelsnr
       ,NIEUW.Naam
       ,NIEUW.Functie
       ,NIEUW.[Datum in dienst]
       ,NIEUW.[Datum uit dienst]
       ,NIEUW.Werknemersgroep
HAVING abs(sum(NIEUW.FTE) - sum(OUD.FTE)) >= 0.01

SELECT sum(FTE) from   [Medewerker].[fn_Werknemers] (@Oud)
SELECT sum(FTE) from   [Medewerker].[fn_Werknemers] (@Nieuw)

################################################################################################### */	
RETURN

WITH cte_laaddatum
     AS (SELECT Laaddag = MAX(CONVERT(DATE, Laaddatum))
         FROM TS_data.[dbo].[SnapshotWerknemer]
         WHERE CONVERT(DATE, Laaddatum) <= COALESCE(@Laaddatum, GETDATE())),
     cte_details
     AS (SELECT [Personeelsnr], 
                [Naam], 
                [Geboortedatum], 
                [Geslacht], 
                [Functie], 
                [Datum in dienst], 
                [Datum uit dienst], 
                [FTE], 
                [Aantal uren], 
                [Afdeling], 
                [Kostenplaats], 
                [Soort contract], 
                [Tijdelijke formatie] = case when [Tijdelijke formatie] = '1' then 1 else 0 end, 
                [Werknemersgroep], 
                [Reden contract], 
                [Manager], 
                [Laaddatum], 
                Volgnummer = ROW_NUMBER() OVER(PARTITION BY [Personeelsnr], Kostenplaats
                ORDER BY [Laaddatum] DESC)
         FROM TS_data.[dbo].[SnapshotWerknemer]
         WHERE CONVERT(DATE, Laaddatum) <= COALESCE(@Laaddatum, GETDATE())
               AND  CONVERT(DATE, Laaddatum) =
         (
             SELECT Laaddag
             FROM cte_laaddatum
         ))
     SELECT [Personeelsnr], 
            [Naam], 
            [Geboortedatum], 
            [Geslacht], 
            [Functie], 
            [Datum in dienst], 
            [Datum uit dienst], 
            [FTE], 
            [Aantal uren], 
            [Afdeling], 
            [Kostenplaats], 
            [Soort contract], 
            [Tijdelijke formatie], 
            [Werknemersgroep], 
            [Reden contract], 
            [Manager], 
            [Laaddatum], 
            Volgnummer
     FROM cte_details AS DET
     WHERE DET.Volgnummer = 1;
GO
