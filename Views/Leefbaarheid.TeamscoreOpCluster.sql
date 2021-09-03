SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Leefbaarheid].[TeamscoreOpCluster]
AS
SELECT ELS.Clusternummer
		,ELS.Jaar
		,AantalWoningen
		,[TeamscoreOverlast] = coalesce(TS19.[Leefbaarheid:                                  A# Overlast], TS20.[Leefbaarheid:                                  A# Overlast], TS21.[Leefbaarheid:                                  A# Overlast])
		,[TeamscoreVervuiling] = coalesce(TS19.[Leefbaarheid:                                  B# Vervuiling], TS20.[Leefbaarheid:                                  B# Vervuiling], TS21.[Leefbaarheid:                                  B# Vervuiling])
		,[TeamscoreGemiddeldOverlastVervuiling] = coalesce(TS19.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling], TS20.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling], TS21.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling])
		,[TeamscoreCriminaliteitWoonfraude] = coalesce(TS19.[Criminaliteit & Woonfraude], TS20.[Criminaliteit & Woonfraude], TS21.[Criminaliteit / Woonfraude])
		,[TeamscoreParticipatie] = coalesce(TS19.[Participatie], TS20.[Participatie], TS21.[Participatie])
		,[TeamscoreLeefkwaliteit] = coalesce(TS19.[Leefkwaliteit], TS20.[Leefkwaliteit], TS21.[Leefkwaliteit (portieken/ kelder/ gedeelde ruimtes en directe wo])
		,[TeamscoreBeheerintensiteit] = coalesce(TS19.[Huidige beheerintensiteit], TS20.[Huidige beheerintensiteit], TS21.[Huidige beheerintensiteit])
		,[TeamscoreCijfer] = coalesce(TS19.[Teamscore], TS20.[Teamscore], TS21.[Complexscore                             (Gemiddelde van alle in])
	FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
	LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2019] AS TS19 ON ELS.Clusternummer = TS19.clusternummer
		AND ELS.Jaar + 1 = TS19.Jaar
	LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2020] AS TS20 ON ELS.Clusternummer = TS20.clusternummer
		AND ELS.Jaar + 1 = TS20.Jaar
	LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2021] AS TS21 ON ELS.Clusternummer = TS21.Clusternummer
		AND ELS.Jaar + 1 = TS21.Jaar
	where ELS.Jaar > 2017 and (TS19.[Teamscore] is not null or TS20.[Teamscore] is not null or TS21.[Complexscore                             (Gemiddelde van alle in] is not null)


GO
