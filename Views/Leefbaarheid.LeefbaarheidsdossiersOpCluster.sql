SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Leefbaarheid].[LeefbaarheidsdossiersOpCluster]
AS
WITH cte
AS (
	SELECT DISTINCT Jaar = year(Datum)
		,Eenheidnr_
		,[Assigned Person Code]
		,Clusternummer = CASE 
			WHEN [Clusternr_] LIKE 'FT-%'
				OR [Clusternr_] LIKE 'BB-%'
				THEN 'FT-' + right(left([Clusternr_], 7), 4)
			WHEN [Clusternr_] LIKE 'FINC-%'
				AND Eenheidnr_ <> ''
				THEN (
						coalesce((
								SELECT TOP 1 clusternummer
								FROM [empire_staedion_data].dbo.ELS
								WHERE eenheidnr = [Eenheidnr_]
									AND clusternummer LIKE 'FT-%'
									AND datum_gegenereerd = datefromparts(iif(year(Datum) < 2017, 2017, year(Datum)), 12, 31)
								ORDER BY Clusternummer ASC
								), (
								SELECT TOP 1 Clusternummer
								FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud]
								WHERE ClusternummerOud = [Clusternr_]
								ORDER BY Clusternummer ASC
								))
						)
			WHEN [Clusternr_] LIKE 'FINC-%'
				AND Eenheidnr_ = ''
				THEN (
						SELECT TOP 1 Clusternummer
						FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud]
						WHERE ClusternummerOud = [Clusternr_]
						ORDER BY Clusternummer ASC
						)
			ELSE NULL
			END
		,Dossiertype = CASE 
			WHEN Dossiertype = 'ONRMGEBR'
				THEN 'Onrechtmatig gebruik'
			WHEN Dossiertype = 'OVERLAST'
				THEN 'Overlast'
			END
	FROM [empire_data].[dbo].[Staedion$Livability_Dossier]
	WHERE (
			Dossiertype = 'OVERLAST'
			OR Dossiertype = 'ONRMGEBR'
			)
		AND YEAR(Datum) > 2015
		AND Eenheidnr_ <> ''
		AND Clusternr_ <> ''
		AND Dossierstatus <> 'GEANNUL'
	)
	,cte_OVERLAST
AS (
	SELECT Clusternummer
		,Jaar
		,AantalOverlastDossiers = COUNT(Eenheidnr_)
	FROM cte
	WHERE Clusternummer IS NOT NULL
		AND Dossiertype = 'Overlast'
	GROUP BY Clusternummer
		,Jaar
	)
	,cte_ONRMGEBR
AS (
	SELECT Clusternummer
		,Jaar
		,AantalOnrechtmatigGebruikDossiers = COUNT(Eenheidnr_)
	FROM cte
	WHERE Clusternummer IS NOT NULL
		AND Dossiertype = 'Onrechtmatig gebruik'
	GROUP BY Clusternummer
		,Jaar
		,Dossiertype
	)
SELECT Clusternummer = ELS.Clusternummer
	,Jaar = ELS.Jaar
	,AantalOnrechtmatigGebruikDossiers = coalesce(AantalOnrechtmatigGebruikDossiers, 0)
	,OnrechtmatigGebruikDossiersPerWoning = cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen
	,[OnrechtmatigGebruikCijfer] = CASE 
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0200
				THEN 1
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0175
				THEN 2
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0150
				THEN 3
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0125
				THEN 4
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0100
				THEN 5
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0075
				THEN 6
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0050
				THEN 7
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0025
				THEN 8
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen > 0.0000
				THEN 9
			WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) as float)  / ELS.AantalWoningen = 0
				THEN 10
			END
	,AantalOverlastDossiers = coalesce(AantalOverlastDossiers, 0)
	,OverlastDossiersPerWoning = cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen
	,[OverlastCijfer] = CASE 
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.040
				THEN 1
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.035
				THEN 2
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.030
				THEN 3
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.025
				THEN 4
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.020
				THEN 5
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.015
				THEN 6
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.010
				THEN 7
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.005
				THEN 8
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen > 0.000
				THEN 9
			WHEN cast(coalesce(AantalOverlastDossiers, 0) as float)  / ELS.AantalWoningen = 0
				THEN 10
			END
FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
LEFT OUTER JOIN cte_OVERLAST ON ELS.Clusternummer = cte_OVERLAST.Clusternummer
	AND ELS.Jaar = cte_OVERLAST.Jaar
LEFT OUTER JOIN cte_ONRMGEBR ON ELS.Clusternummer = cte_ONRMGEBR.Clusternummer
	AND ELS.Jaar = cte_ONRMGEBR.Jaar
	where ELS.Jaar > 2015
GO
