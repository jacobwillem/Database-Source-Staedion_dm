SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE VIEW [Leefbaarheid].[BIKOpCluster]
AS
SELECT Clusternummer = ELS.Clusternummer
	,Clusternaam = ELS.Clusternaam
	,Latitude = LBMC.Latitude
	,Longitude = LBMC.Longitude
	,BuurtCode = CLBU.BuurtCode
	,BUcode = N'BU' + RIGHT(N'00000000' + CAST(CLBU.BuurtCode AS NVARCHAR), 8)
	,Buurt = BU.BuurtNaam
	,Gemeente = GM.GemeenteNaam
	,Thuisteam = THTE.Thuisteam
	,Bewonerscommissie = CP.[Bewonerscommissie]
    ,Bewonersconsulent = CP.[Bewonersconsulent]
    ,Complexbeheerder1 = CP.[Complexbeheerder 1]
    ,Complexbeheerder2 = CP.[Complexbeheerder 2]
    ,Huismeester1 = CP.[Huismeester 1]
    ,Huismeester2 = CP.[Huismeester 2]
    ,SociaalComplexbeheerder = CP.[Sociaal Complexbeheerder]
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
	,AantalWoningen = ELS.AantalWoningen
	,[BIKscoreCluster] = CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END
	,[BIKscoreClusterKCMopCluster] = CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END
	,BIKscoreBuurt = BIK.BIKscoreBuurt
	,BIKkleurCluster = CASE 
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END IS NULL
				THEN NULL
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 5
				THEN 'Rood'
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 6
				THEN 'Oranje'
			WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 7
			THEN 'Geel'
		WHEN CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END < 8
				THEN 'Licht groen'
	when CASE 
		WHEN (
				KCM.KCMCijfer IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(KCM.KCMCijfer IS NULL, 0, 1)), 1)
		END >= 8 then 'Donker groen'
			END
	,BIKkleurClusterKCMopCluster = CASE 
			WHEN CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END IS NULL
				THEN NULL
			WHEN CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END < 5
				THEN 'Rood'
			WHEN CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END < 6
				THEN 'Oranje'
			WHEN CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END < 7
			THEN 'Geel'
		WHEN CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END < 8
				THEN 'Licht groen'
	when CASE 
		WHEN (
				coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL
				AND TS.[TeamscoreCijfer] IS NULL
				)
			THEN NULL
		ELSE ROUND((0.5 * coalesce(TS.[TeamscoreCijfer], 0) +
					0.21 * coalesce(LBMC.Cijfer, LBMB.Cijfer, 0) +
					0.08 * coalesce((cast(LBH.OverlastCijfer AS FLOAT) +
									cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2, 0) +
					0.21 * coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer, 0)) / 
					(0.5 * iif(TS.TeamscoreCijfer IS NULL, 0, 1) +
					0.21 * iif(coalesce(LBMC.Cijfer, LBMB.Cijfer) IS NULL, 0, 1) +
					0.08 * iif((cast(LBH.OverlastCijfer AS FLOAT) +
								cast(LBH.OnrechtmatigGebruikCijfer AS FLOAT)) / 2 IS NULL, 0, 1) +
					0.21 * iif(coalesce(KCMCL.KCMCijfer, KCM.KCMCijfer) IS NULL, 0, 1)), 1)
		END >= 8 then 'Donker groen'
			END
	,BIKkleurBuurt = BIK.BIKkleurBuurt
	,LeefbaarometerCijferCluster = round(LBMC.Cijfer, 1)
	,LeefbaarometerCijferBuurt = round(LBMB.Cijfer, 1)
	,AantalRespondenten = KCM.AantalRespondenten
	,AantalRespondentenOpCluster = KCMCL.AantalRespondenten
	,KCMThuisgevoel = round(KCM.KCMThuisgevoel, 1)
	,KCMThuisgevoelOpCluster = round(KCMCL.KCMThuisgevoel, 1)
	,KCMTevredenheidWoning = round(KCM.KCMTevredenheidWoning, 1)
	,KCMTevredenheidWoningOpCluster = round(KCMCL.KCMTevredenheidWoning, 1)
	,KCMTevredenheidAlgemeneRuimte = round(KCM.KCMTevredenheidAlgemeneRuimte, 1)
	,KCMTevredenheidAlgemeneRuimteOpCluster = round(KCMCL.KCMTevredenheidAlgemeneRuimte, 1)
	,KCMTevredenheidBuurt = round(KCM.KCMTevredenheidBuurt, 1)
	,KCMTevredenheidBuurtOpCluster = round(KCMCL.KCMTevredenheidBuurt, 1)
	,KCMCijfer = round(KCM.KCMCijfer, 1)
	,KCMCijferOpCluster = round(KCMCL.KCMCijfer, 1)
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
FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode as CLBU on CLBU.Clusternummer = ELS.Clusternummer
INNER JOIN empire_staedion_data.bik.CBS_Buurt2020 AS BU ON BU.BuurtCode = CLBU.BuurtCode
INNER JOIN empire_staedion_data.bik.CBS_Gemeente2020 AS GM ON GM.GemeenteCode = BU.GemeenteCode
LEFT OUTER JOIN empire_staedion_data.bik.ELS_BuurtCodeThuisteam AS THTE ON THTE.BuurtCode = CLBU.BuurtCode
LEFT OUTER JOIN staedion_dm.Leefbaarheid.ClusterKenmerkenContactPersonen AS CP ON CP.Clusternummer = ELS.Clusternummer
LEFT OUTER JOIN staedion_dm.Leefbaarheid.LeefbaarometerOpCluster AS LBMC ON LBMC.Clusternummer = ELS.Clusternummer
	AND LBMC.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.LeefbaarometerOpBuurt AS LBMB ON LBMB.BuurtCode = CLBU.BuurtCode
	AND LBMB.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.KlantContactMonitorOpBuurt AS KCM ON KCM.BuurtCode = CLBU.BuurtCode
	AND KCM.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.KlantContactMonitorOpCluster AS KCMCL ON KCMCL.Clusternummer = ELS.Clusternummer
	AND KCMCL.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.LeefbaarheidsdossiersOpBuurt AS LBH ON LBH.BuurtCode = CLBU.BuurtCode
	AND LBH.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.TeamscoreOpCluster AS TS ON TS.Clusternummer = ELS.Clusternummer
	AND TS.Jaar = ELS.Jaar
LEFT OUTER JOIN staedion_dm.Leefbaarheid.BIKOpBuurt AS BIK ON BIK.BuurtCode = CLBU.BuurtCode
	AND BIK.Jaar = ELS.Jaar
	where ELS.Jaar >= 2016
GO
