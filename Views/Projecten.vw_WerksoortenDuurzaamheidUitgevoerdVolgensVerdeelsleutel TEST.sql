SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Projecten].[vw_WerksoortenDuurzaamheidUitgevoerdVolgensVerdeelsleutel TEST]
AS
WITH cte_actuele_verdeelsleutels
AS (
   SELECT [Project No_],
          [Cluster No_],
          [Budget Line No_],
          [Distribution Key Type],
          [Version No_],
          ROW_NUMBER() OVER (PARTITION BY [Project No_],
                                          [Budget Line No_]
                             ORDER BY [Version No_] DESC
                            ) AS Volgnr
   -- select *
   FROM empire_data.dbo.[Staedion$Cluster_Distrn_Keys_Header]
   WHERE [Project No_] <> ''
         AND [Status] = 1 -- actief
),
     cte_gereedmeldingen
AS (SELECT BSM.Projectnr_ AS Projectnr,
           Projectnaam = PROJ.Naam,
           [Clusternr] = PBR.Clusternr_,
           [Eenheidnr] = VERDEELR.[Realty Unit No_],
           [Leverancier] =
           (
               SELECT MAX([Orderleveranciernr_])
               FROM empire_data.dbo.[Staedion$Empire_Projectbudg_det_regel] AS PBDR
               WHERE PBDR.Projectnr_ = BSM.Projectnr_
                     AND PBDR.Budgetregelnr_ = BSM.Budgetregelnr_
           ),
           [Werksoort] = PBR.Werksoort,
           [Datum gereed] = BSM.Datum,
           OmschrijvingWerkzaamheden = PROJ.Omschrijving,
           [Soort ingreep] = CASE
                                 WHEN
                                 (
                                     PBR.Werksoort = 'P31010'
                                     OR UPPER(PBR.Omschrijving) LIKE '%HR+%'
                                 ) THEN
                                     'HR-glas'
                                 WHEN
                                 (
                                     PBR.Werksoort = 'P51100'
                                     OR PBR.Omschrijving LIKE '%individuele CV installatie%'
                                     OR PBR.Omschrijving LIKE '%individuele CV-installatie%'
                                     OR PBR.Omschrijving LIKE '%individuele CV ketel%'
                                     OR PBR.Omschrijving LIKE '%individuele CV-ketel%'
                                 ) THEN
                                     'HR-toestel'
                                 WHEN
                                 (
                                     PBR.Werksoort IN ( 'P61010', 'P61011' )
                                     OR PBR.Omschrijving LIKE '%PV panelen%'
                                     OR PBR.Omschrijving LIKE '%PV-panelen%'
                                     OR PBR.Omschrijving LIKE '%PV paneel%'
                                     OR PBR.Omschrijving LIKE '%PV-paneel%'
                                 ) THEN
                                     'PV-paneel'
                                 WHEN (
                                          PBR.Werksoort = 'P57500'
                                          OR PBR.Omschrijving LIKE '%MV installatie%'
                                          OR PBR.Omschrijving LIKE '%MV-installatie%'
                                          OR PBR.Omschrijving LIKE '%MVI%'
                                      )
                                      AND
                                      (
                                          PROJ.Omschrijving LIKE '%vv%'
                                          OR PROJ.Omschrijving LIKE '%vervang%'
                                      ) THEN
                                     'MV-vervangen'
                                 WHEN (
                                          PBR.Werksoort = 'P57500'
                                          OR PBR.Omschrijving LIKE '%MV installatie%'
                                          OR PBR.Omschrijving LIKE '%MV-installatie%'
                                          OR PBR.Omschrijving LIKE '%MVI%'
                                      )
                                      AND PROJ.Omschrijving LIKE '%aanbreng%' THEN
                                     'MV-aanbrengen'
                             END,
           [Gereedmelding door] = BSM.[Gebruikers-ID],
           BSM.Budgetregelnr_ AS Budgetregelnr,
           PBR.Omschrijving AS Budgetregelomschrijving
    -- select BSM.*
    FROM empire_data.dbo.Staedion$Budgetstatusmutatie AS BSM
        JOIN empire_data.dbo.Staedion$Empire_Projectbudgetregel AS PBR
            ON PBR.Projectnr_ = BSM.Projectnr_
               AND PBR.Regelnr_ = BSM.Budgetregelnr_
        LEFT OUTER JOIN empire_data.dbo.[Staedion$Empire_Project] AS PROJ
            ON PROJ.Nr_ = BSM.Projectnr_
        --LEFT OUTER JOIN empire_data.dbo.[Staedion$Cluster_Distrn_Keys_Header] AS VERDEELS
        LEFT OUTER JOIN cte_actuele_verdeelsleutels AS VERDEELS
            ON VERDEELS.[Project No_] = BSM.Projectnr_
               AND VERDEELS.[Budget Line No_] = BSM.Budgetregelnr_
               AND VERDEELS.Volgnr = 1
        LEFT OUTER JOIN empire_data.dbo.[Staedion$Cluster_Distrn_Keys_Line] AS VERDEELR
            ON VERDEELS.[Cluster No_] = VERDEELR.[Cluster No_]
               AND VERDEELS.[Distribution Key Type] = VERDEELR.[Distribution Key Type]
               AND VERDEELS.[Version No_] = VERDEELR.[Version No_]
    WHERE 1 = 1 --BSM.Projectnr_ IN ( 'PLOH-2000019', 'PLOH-1900181', 'PLOH-2100035', 'PLOH-2200020' )
          AND VERDEELR.Numerator = 1
          --AND BSM.Datum      BETWEEN @DatumVanaf AND @DatumTotenMet
          AND BSM.[Status] = 20
          AND PBR.Projectnr_ LIKE 'PLOH%'
          --AND PBR.Projectnr_ = 'PLOH-2100124'
          -- Hier kunnen meerdere criteria worden opgenomen voor proces-kpi's mbt werksoorten Planmatig onderhoud
          AND
          (
              -- HR-glas:
              (
                  PBR.Werksoort = 'P31010'
                  OR UPPER(PBR.Omschrijving) LIKE '%HR+%'
              )
              OR
              -- HR-toestel:
              (
                  PBR.Werksoort = 'P51100'
                  OR PBR.Omschrijving LIKE '%individuele CV installatie%'
                  OR PBR.Omschrijving LIKE '%individuele CV ketel%'
              )
              OR
              -- PV-paneel:
              (
                  PBR.Werksoort IN ( 'P61010', 'P61011' )
                  OR PBR.Omschrijving LIKE '%PV panelen%'
                  OR PBR.Omschrijving LIKE '%PV-panelen%'
                  OR PBR.Omschrijving LIKE '%PV paneel%'
                  OR PBR.Omschrijving LIKE '%PV-paneel%'
              )
              OR
              -- MV:
              (
                  PBR.Werksoort = 'P57500'
                  OR PBR.Omschrijving LIKE '%MV installatie%'
                  OR PBR.Omschrijving LIKE '%MV-installatie%'
              )
          ))
SELECT [Projectnr],
       [Projectnaam],
       [Clusternr],
       [Eenheidnr],
       [Leverancier],
       [Werksoort],
       max([Datum gereed]) as [Datum gereed],		-- zie PLOH-2100035 - regel 36000: meerdere keren technisch gereed gemeld
       [OmschrijvingWerkzaamheden],
       [Soort ingreep],
       [Gereedmelding door],
       [Budgetregelnr],
       [Budgetregelomschrijving]
FROM cte_gereedmeldingen
group by  [Projectnr],
       [Projectnaam],
       [Clusternr],
       [Eenheidnr],
       [Leverancier],
       [Werksoort],
       [OmschrijvingWerkzaamheden],
       [Soort ingreep],
       [Gereedmelding door],
       [Budgetregelnr],
       [Budgetregelomschrijving] ;
GO
