SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Leefbaarheid].[LeefbaarheidsdossiersOpBuurt]
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
	SELECT CLBU.BuurtCode
		,cte.Jaar
		,AantalOverlastDossiers = COUNT(cte.Eenheidnr_)
	FROM cte
	INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON cte.Clusternummer = CLBU.Clusternummer
	WHERE cte.Clusternummer IS NOT NULL
		AND cte.Dossiertype = 'Overlast'
	GROUP BY CLBU.BuurtCode
		,cte.Jaar
	)
	,cte_ONRMGEBR
AS (
	SELECT CLBU.BuurtCode
		,cte.Jaar
		,AantalOnrechtmatigGebruikDossiers = COUNT(cte.Eenheidnr_)
	FROM cte
	INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON cte.Clusternummer = CLBU.Clusternummer
	WHERE cte.Clusternummer IS NOT NULL
		AND cte.Dossiertype = 'Onrechtmatig gebruik'
	GROUP BY CLBU.BuurtCode
		,cte.Jaar
	)
SELECT AW.BuurtCode
	,AW.Jaar
	,AantalOnrechtmatigGebruikDossiers = coalesce(AantalOnrechtmatigGebruikDossiers, 0)
	,OnrechtmatigGebruikDossiersPerWoning = cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen
	,[OnrechtmatigGebruikCijfer] = CASE 
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0200
			THEN 1
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0175
			THEN 2
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0150
			THEN 3
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0125
			THEN 4
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0100
			THEN 5
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0075
			THEN 6
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0050
			THEN 7
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0025
			THEN 8
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.0000
			THEN 9
		WHEN cast(coalesce(AantalOnrechtmatigGebruikDossiers, 0) AS FLOAT) / AW.AantalWoningen = 0
			THEN 10
		END
	,AantalOverlastDossiers = coalesce(AantalOverlastDossiers, 0)
	,OverlastDossiersPerWoning = cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen
	,[OverlastCijfer] = CASE 
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.040
			THEN 1
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.035
			THEN 2
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.030
			THEN 3
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.025
			THEN 4
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.020
			THEN 5
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.015
			THEN 6
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.010
			THEN 7
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.005
			THEN 8
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen > 0.000
			THEN 9
		WHEN cast(coalesce(AantalOverlastDossiers, 0) AS FLOAT) / AW.AantalWoningen = 0
			THEN 10
		END
FROM empire_staedion_data.bik.ELS_AantalWoningenPerBuurtUltimo AS AW
LEFT OUTER JOIN cte_OVERLAST ON AW.BuurtCode = cte_OVERLAST.BuurtCode
	AND AW.Jaar = cte_OVERLAST.Jaar
LEFT OUTER JOIN cte_ONRMGEBR ON AW.BuurtCode = cte_ONRMGEBR.BuurtCode
	AND AW.Jaar = cte_ONRMGEBR.Jaar
WHERE AW.Jaar > 2015
GO
