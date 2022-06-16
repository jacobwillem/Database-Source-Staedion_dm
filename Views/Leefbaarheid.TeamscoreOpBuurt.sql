SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Leefbaarheid].[TeamscoreOpBuurt]
AS SELECT CLBU.BuurtCode,
       ELS.Jaar,
       [TeamscoreOverlast] = SUM(COALESCE(
                                             TS19.[Leefbaarheid:                                  A# Overlast]
                                             * ELS.AantalWoningen,
                                             TS20.[Leefbaarheid:                                  A# Overlast]
                                             * ELS.AantalWoningen,
                                             TS21.[Leefbaarheid:                                  A# Overlast]
                                             * ELS.AantalWoningen,
                                             TS22.[Leefbaarheid:                                  A# Overlast]
                                             * ELS.AantalWoningen
                                         )
                                ) / SUM(ELS.AantalWoningen),
       [TeamscoreVervuiling] = SUM(COALESCE(
                                               TS19.[Leefbaarheid:                                  B# Vervuiling]
                                               * ELS.AantalWoningen,
                                               TS20.[Leefbaarheid:                                  B# Vervuiling]
                                               * ELS.AantalWoningen,
                                               TS21.[Leefbaarheid:                                  B# Vervuiling]
                                               * ELS.AantalWoningen,
                                               TS22.[Leefbaarheid:                                  B# Vervuiling]
                                               * ELS.AantalWoningen
                                           )
                                  ) / SUM(ELS.AantalWoningen),
       [TeamscoreGemiddeldOverlastVervuiling] = SUM(COALESCE(
                                                                TS19.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling]
                                                                * ELS.AantalWoningen,
                                                                TS20.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling]
                                                                * ELS.AantalWoningen,
                                                                TS21.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling]
                                                                * ELS.AantalWoningen,
                                                                TS22.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling]
                                                                * ELS.AantalWoningen
                                                            )
                                                   ) / SUM(ELS.AantalWoningen),
       [TeamscoreCriminaliteitWoonfraude] = SUM(COALESCE(
                                                            TS19.[Criminaliteit & Woonfraude] * ELS.AantalWoningen,
                                                            TS20.[Criminaliteit & Woonfraude] * ELS.AantalWoningen,
                                                            TS21.[Criminaliteit / Woonfraude] * ELS.AantalWoningen,
															TS22.[Criminaliteit / Woonfraude] * ELS.AantalWoningen
                                                        )
                                               ) / SUM(ELS.AantalWoningen),
       [TeamscoreParticipatie] = SUM(COALESCE(
                                                 TS19.[Participatie] * ELS.AantalWoningen,
                                                 TS20.[Participatie] * ELS.AantalWoningen,
                                                 TS21.[Participatie] * ELS.AantalWoningen,
												 TS22.[Participatie] * ELS.AantalWoningen
                                             )
                                    ) / SUM(ELS.AantalWoningen),
       [TeamscoreLeefkwaliteit] = SUM(COALESCE(
                                                  TS19.[Leefkwaliteit] * ELS.AantalWoningen,
                                                  TS20.[Leefkwaliteit] * ELS.AantalWoningen,
                                                  TS21.[Leefkwaliteit (portieken/ kelder/ gedeelde ruimtes en directe wo]
                                                  * ELS.AantalWoningen,
												  TS22.[Leefkwaliteit (portieken/ kelder/ gedeelde ruimtes en directe wo]
                                                  * ELS.AantalWoningen
                                              )
                                     ) / SUM(ELS.AantalWoningen),
       [TeamscoreBeheerintensiteit] = SUM(COALESCE(
                                                      TS19.[Huidige beheerintensiteit] * ELS.AantalWoningen,
                                                      TS20.[Huidige beheerintensiteit] * ELS.AantalWoningen,
                                                      TS21.[Huidige beheerintensiteit] * ELS.AantalWoningen,
													  TS22.[Huidige beheerintensiteit] * ELS.AantalWoningen
                                                  )
                                         ) / SUM(ELS.AantalWoningen),
       [TeamscoreCijfer] = SUM(COALESCE(
                                           TS19.[Teamscore] * ELS.AantalWoningen,
                                           TS20.[Teamscore] * ELS.AantalWoningen,
                                           TS21.[Complexscore                             (Gemiddelde van alle in]
                                           * ELS.AantalWoningen,
                                           TS22.[Complexscore                             (Gemiddelde van alle in]
                                           * ELS.AantalWoningen
                                       )
                              ) / SUM(ELS.AantalWoningen)
FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
    INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU
        ON ELS.Clusternummer = CLBU.Clusternummer
    LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2019] AS TS19
        ON ELS.Clusternummer = TS19.clusternummer
           AND ELS.Jaar + 1 = TS19.Jaar
    LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2020] AS TS20
        ON ELS.Clusternummer = TS20.clusternummer
           AND ELS.Jaar + 1 = TS20.Jaar
    LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2021] AS TS21
        ON ELS.Clusternummer = TS21.Clusternummer
           AND ELS.Jaar + 1 = TS21.Jaar
    LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2022] AS TS22
        ON ELS.Clusternummer = TS22.Clusternummer
           AND ELS.Jaar + 1 = TS22.Jaar
WHERE ELS.Jaar > 2017
      AND
      (
          TS19.[Teamscore] IS NOT NULL
          OR TS20.[Teamscore] IS NOT NULL
          OR TS21.[Complexscore                             (Gemiddelde van alle in] IS NOT NULL
          OR TS22.[Complexscore                             (Gemiddelde van alle in] IS NOT NULL
      )
GROUP BY CLBU.BuurtCode,
         ELS.Jaar;


GO
