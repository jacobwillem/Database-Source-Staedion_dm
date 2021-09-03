SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Leefbaarheid].[TeamscoreOpBuurt]
AS
SELECT CLBU.BuurtCode
		,ELS.Jaar
		,[TeamscoreOverlast] = sum(coalesce(TS19.[Leefbaarheid:                                  A# Overlast] * ELS.AantalWoningen, TS20.[Leefbaarheid:                                  A# Overlast] * ELS.AantalWoningen, TS21.[Leefbaarheid:                                  A# Overlast] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreVervuiling] = sum(coalesce(TS19.[Leefbaarheid:                                  B# Vervuiling] * ELS.AantalWoningen, TS20.[Leefbaarheid:                                  B# Vervuiling] * ELS.AantalWoningen, TS21.[Leefbaarheid:                                  B# Vervuiling] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreGemiddeldOverlastVervuiling] = sum(coalesce(TS19.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling] * ELS.AantalWoningen, TS20.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling] * ELS.AantalWoningen, TS21.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreCriminaliteitWoonfraude] = sum(coalesce(TS19.[Criminaliteit & Woonfraude] * ELS.AantalWoningen, TS20.[Criminaliteit & Woonfraude] * ELS.AantalWoningen, TS21.[Criminaliteit / Woonfraude] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreParticipatie] = sum(coalesce(TS19.[Participatie] * ELS.AantalWoningen, TS20.[Participatie] * ELS.AantalWoningen, TS21.[Participatie] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreLeefkwaliteit] = sum(coalesce(TS19.[Leefkwaliteit] * ELS.AantalWoningen, TS20.[Leefkwaliteit] * ELS.AantalWoningen, TS21.[Leefkwaliteit (portieken/ kelder/ gedeelde ruimtes en directe wo] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreBeheerintensiteit] = sum(coalesce(TS19.[Huidige beheerintensiteit] * ELS.AantalWoningen, TS20.[Huidige beheerintensiteit] * ELS.AantalWoningen, TS21.[Huidige beheerintensiteit] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
		,[TeamscoreCijfer] = sum(coalesce(TS19.[Teamscore] * ELS.AantalWoningen, TS20.[Teamscore] * ELS.AantalWoningen, TS21.[Complexscore                             (Gemiddelde van alle in] * ELS.AantalWoningen)) / sum(ELS.AantalWoningen)
	FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
	INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON ELS.Clusternummer = CLBU.Clusternummer
	LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2019] AS TS19 ON ELS.Clusternummer = TS19.clusternummer
		AND ELS.Jaar + 1 = TS19.Jaar
	LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2020] AS TS20 ON ELS.Clusternummer = TS20.clusternummer
		AND ELS.Jaar + 1 = TS20.Jaar
	LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2021] AS TS21 ON ELS.Clusternummer = TS21.Clusternummer
		AND ELS.Jaar + 1 = TS21.Jaar
	where ELS.Jaar > 2017 and (TS19.[Teamscore] is not null or TS20.[Teamscore] is not null or TS21.[Complexscore                             (Gemiddelde van alle in] is not null)
	GROUP BY CLBU.BuurtCode
		,ELS.Jaar


GO
