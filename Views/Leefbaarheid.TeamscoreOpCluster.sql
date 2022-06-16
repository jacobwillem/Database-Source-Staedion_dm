SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Leefbaarheid].[TeamscoreOpCluster]
AS SELECT ELS.Clusternummer,
       ELS.Jaar,
       AantalWoningen,
       [TeamscoreOverlast] = COALESCE(
                                         TS19.[Leefbaarheid:                                  A# Overlast],
                                         TS20.[Leefbaarheid:                                  A# Overlast],
                                         TS21.[Leefbaarheid:                                  A# Overlast],
										 TS22.[Leefbaarheid:                                  A# Overlast]
                                     ),
       [TeamscoreVervuiling] = COALESCE(
                                           TS19.[Leefbaarheid:                                  B# Vervuiling],
                                           TS20.[Leefbaarheid:                                  B# Vervuiling],
                                           TS21.[Leefbaarheid:                                  B# Vervuiling],
										   TS22.[Leefbaarheid:                                  B# Vervuiling]
                                       ),
       [TeamscoreGemiddeldOverlastVervuiling] = COALESCE(
                                                            TS19.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling],
                                                            TS20.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling],
                                                            TS21.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling],
															TS22.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling]
                                                        ),
       [TeamscoreCriminaliteitWoonfraude] = COALESCE(
                                                        TS19.[Criminaliteit & Woonfraude],
                                                        TS20.[Criminaliteit & Woonfraude],
                                                        TS21.[Criminaliteit / Woonfraude],
														TS22.[Criminaliteit / Woonfraude]
                                                    ),
       [TeamscoreParticipatie] = COALESCE(TS19.[Participatie], TS20.[Participatie], TS21.[Participatie], TS22.[Participatie]),
       [TeamscoreLeefkwaliteit] = COALESCE(
                                              TS19.[Leefkwaliteit],
                                              TS20.[Leefkwaliteit],
                                              TS21.[Leefkwaliteit (portieken/ kelder/ gedeelde ruimtes en directe wo],
											  TS22.[Leefkwaliteit (portieken/ kelder/ gedeelde ruimtes en directe wo]
                                          ),
       [TeamscoreBeheerintensiteit] = COALESCE(
                                                  TS19.[Huidige beheerintensiteit],
                                                  TS20.[Huidige beheerintensiteit],
                                                  TS21.[Huidige beheerintensiteit],
												  TS22.[Huidige beheerintensiteit]
                                              ),
       [TeamscoreCijfer] = COALESCE(
                                       TS19.[Teamscore],
                                       TS20.[Teamscore],
                                       TS21.[Complexscore                             (Gemiddelde van alle in],
									   TS22.[Complexscore                             (Gemiddelde van alle in]

                                   )
FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
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
      );


GO
