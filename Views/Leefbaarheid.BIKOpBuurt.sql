SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Leefbaarheid].[BIKOpBuurt]
AS
SELECT BuurtCode = ELS.BuurtCode
	,BUcode = N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS NVARCHAR), 8)
	,Buurt = BU.BuurtNaam
	,Gemeente = GM.GemeenteNaam
	,Thuisteam = THTE.Thuisteam
	,[Bewonerscommissie] = CP.[Bewonerscommissie]
	,[Bewonersconsulent] = CP.[Bewonersconsulent]
	,[Complexbeheerder1] = CP.[Complexbeheerder1]
	,[Complexbeheerder2] = CP.[Complexbeheerder2]
	,[Huismeester1] = CP.[Huismeester1]
	,[Huismeester2] = CP.[Huismeester2]
	,[SociaalComplexbeheerder] = CP.[SociaalComplexbeheerder]
	,Jaar = ELS.Jaar
	,BIKJaar = CASE 
		WHEN ELS.Jaar = 2018
			THEN 'BIK2019'
		WHEN ELS.Jaar = 2019
			THEN 'BIK2020'
		WHEN ELS.Jaar = 2020
			THEN 'BIK2021'
		WHEN ELS.Jaar = 2021
			THEN 'BIK2022'
		ELSE NULL
		END
	,AantalClusters = ELS.AantalClusters
	,AantalWoningen = ELS.AantalWoningen
	,[BIKscoreBuurt] = CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END
	,BIKkleurBuurt = CASE 
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END IS NULL
				THEN NULL
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 5
				THEN 'Rood'
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 6
				THEN 'Oranje'
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 7
			THEN 'Geel'
		WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 8
				THEN 'Licht groen'
	when CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			OR ELS.AantalWoningen < 10
			THEN NULL
		ELSE ROUND((0.3 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.3 * coalesce(LBM.Cijfer, 0) +
					0.1 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.3 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.3 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.3 * iif(LBM.Cijfer IS NULL, 0, 1) +
					0.1 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.3 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END >= 8 then 'Donker groen'
			END
	,LeefbaarometerCijfer = round(LBM.Cijfer, 1)
	,AantalRespondenten = KCM.AantalRespondenten
	,KCMThuisgevoel = round(KCM.KCMThuisgevoel, 1)
	,KCMTevredenheidWoning = round(KCM.KCMTevredenheidWoning, 1)
	,KCMTevredenheidAlgemeneRuimte = round(KCM.KCMTevredenheidAlgemeneRuimte, 1)
	,KCMTevredenheidBuurt = round(KCM.KCMTevredenheidBuurt, 1)
	,KCMCijfer = round(KCM.KCMCijfer, 1)
	,AantalMeldingenOverlast = LBH.AantalOverlastDossiers
	,OverlastPercentage = round(LBH.OverlastDossiersPerWoning * 100, 2)
	,OverlastCijfer = round(LBH.OverlastCijfer, 1)
	,AantalMeldingenWoonfraude = LBH.AantalOnrechtmatigGebruikDossiers
	,WoonfraudePercentage = round(LBH.OnrechtmatigGebruikDossiersPerWoning * 100, 2)
	,WoonfraudeCijfer = round(LBH.OnrechtmatigGebruikCijfer, 1)
	,OverlastWoonfraudeCijfer = round((cast(LBH.OverlastCijfer AS FLOAT) + cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 1)
	,[TeamscoreOverlast] = ROUND(TS.[TeamscoreOverlast], 1)
	,[TeamscoreVervuiling] = ROUND(TS.[TeamscoreVervuiling], 1)
	,[TeamscoreGemiddeldOverlastVervuiling] = ROUND(TS.[TeamscoreGemiddeldOverlastVervuiling], 1)
	,[TeamscoreCriminaliteitWoonfraude] = ROUND(TS.[TeamscoreCriminaliteitWoonfraude], 1)
	,[TeamscoreParticipatie] = ROUND(TS.[TeamscoreParticipatie], 1)
	,[TeamscoreLeefkwaliteit] = ROUND(TS.[TeamscoreLeefkwaliteit], 1)
	,[TeamscoreBeheerintensiteit] = ROUND(TS.[TeamscoreBeheerintensiteit], 1)
	,[TeamscoreCijfer] = ROUND(TS.[TeamscoreCijfer], 1)
FROM empire_staedion_data.bik.ELS_AantalWoningenPerBuurtUltimo AS ELS
INNER JOIN empire_staedion_data.bik.CBS_Buurt2020 AS BU ON BU.BuurtCode = ELS.BuurtCode
INNER JOIN empire_staedion_data.bik.CBS_Gemeente2020 AS GM ON GM.GemeenteCode = BU.GemeenteCode
LEFT OUTER JOIN empire_staedion_data.bik.ELS_BuurtCodeThuisteam AS THTE ON THTE.BuurtCode = ELS.BuurtCode
LEFT OUTER JOIN staedion_dm.Leefbaarheid.ClusterKenmerkenContactPersonenOpBuurt as CP on CP.BuurtCode = ELS.BuurtCode
LEFT OUTER JOIN staedion_dm.Leefbaarheid.LeefbaarometerOpBuurt AS LBM ON LBM.BuurtCode = ELS.BuurtCode
	AND LBM.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.KlantContactMonitorOpBuurt AS KCM ON KCM.BuurtCode = ELS.BuurtCode
	AND KCM.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.LeefbaarheidsdossiersOpBuurt AS LBH ON LBH.BuurtCode = ELS.BuurtCode
	AND LBH.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.TeamscoreOpBuurt AS TS ON TS.BuurtCode = ELS.BuurtCode
	AND TS.Jaar = ELS.Jaar
	where ELS.Jaar >= 2016

GO
