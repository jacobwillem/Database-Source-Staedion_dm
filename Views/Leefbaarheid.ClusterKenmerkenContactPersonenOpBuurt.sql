SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Leefbaarheid].[ClusterKenmerkenContactPersonenOpBuurt]
AS
WITH cte
AS (
	SELECT [Clusternummer] = C.Nr_
		,[BuurtCode] = CLBU.BuurtCode
		,[BewonerscommissieJN] = CASE 
			WHEN FN.Bewonerscommissie IS NULL
				THEN 0
			ELSE 1
			END
		,[ComplexbeheerderJN] = CASE 
			WHEN FN.[Complexbeheerder 1] IS NULL
				AND FN.[Complexbeheerder 2] IS NULL
				THEN 0
			ELSE 1
			END
		,[HuismeesterJN] = CASE 
			WHEN FN.[Huismeester 1] IS NULL
				AND FN.[Huismeester 2] IS NULL
				THEN 0
			ELSE 1
			END
		,[Sociaal ComplexbeheerderJN] = CASE 
			WHEN FN.[Sociaal Complexbeheerder] IS NULL
				THEN 0
			ELSE 1
			END
		,[ClusterNaam] = C.Naam
		,FN.Thuisteam
		,FN.[Bewonerscommissie]
		,FN.[Bewonersconsulent]
		,FN.[Complexbeheerder 1]
		,FN.[Complexbeheerder 2]
		,FN.[Huismeester 1]
		,FN.[Huismeester 2]
		,FN.[Sociaal Complexbeheerder]
	FROM empire_data.dbo.staedion$Cluster AS C
	OUTER APPLY empire_Staedion_data.[dbo].[ITVFnContactbeheerClusterInclNaam](C.Nr_) AS FN
	RIGHT OUTER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON CLBU.Clusternummer = C.Nr_
	WHERE C.Nr_ LIKE 'FT%'
	)
	,cteBU
AS (
	SELECT DISTINCT BuurtCode
	FROM cte
	)
	,cteBCOM
AS (
	SELECT DISTINCT BuurtCode
		,[Bewonerscommissie]
	FROM cte
	)
	,cteBCOMG
AS (
	SELECT BuurtCode
		,[Bewonerscommissie] = STRING_AGG(cteBCOM.[Bewonerscommissie], '; ')
	FROM cteBCOM
	GROUP BY BuurtCode
	)
	,cteBCON
AS (
	SELECT DISTINCT BuurtCode
		,[Bewonersconsulent]
	FROM cte
	)
	,cteBCONG
AS (
	SELECT BuurtCode
		,[Bewonersconsulent] = STRING_AGG(cteBCON.[Bewonersconsulent], '; ')
	FROM cteBCON
	GROUP BY BuurtCode
	)
	,cteCB1
AS (
	SELECT DISTINCT BuurtCode
		,[Complexbeheerder 1]
	FROM cte
	)
	,cteCB1G
AS (
	SELECT BuurtCode
		,[Complexbeheerder1] = STRING_AGG(cteCB1.[Complexbeheerder 1], '; ')
	FROM cteCB1
	GROUP BY BuurtCode
	)
	,cteCB2
AS (
	SELECT DISTINCT BuurtCode
		,[Complexbeheerder 2]
	FROM cte
	)
	,cteCB2G
AS (
	SELECT BuurtCode
		,[Complexbeheerder2] = STRING_AGG(cteCB2.[Complexbeheerder 2], '; ')
	FROM cteCB2
	GROUP BY BuurtCode
	)
	,cteHM1
AS (
	SELECT DISTINCT BuurtCode
		,[Huismeester 1]
	FROM cte
	)
	,cteHM1G
AS (
	SELECT BuurtCode
		,[Huismeester1] = STRING_AGG(cteHM1.[Huismeester 1], '; ')
	FROM cteHM1
	GROUP BY BuurtCode
	)
	,cteHM2
AS (
	SELECT DISTINCT BuurtCode
		,[Huismeester 2]
	FROM cte
	)
	,cteHM2G
AS (
	SELECT BuurtCode
		,[Huismeester2] = STRING_AGG(cteHM2.[Huismeester 2], '; ')
	FROM cteHM2
	GROUP BY BuurtCode
	)
	,cteSCB
AS (
	SELECT DISTINCT BuurtCode
		,[Sociaal Complexbeheerder]
	FROM cte
	)
	,cteSCBG
AS (
	SELECT BuurtCode
		,[SociaalComplexbeheerder] = STRING_AGG(cteSCB.[Sociaal Complexbeheerder], '; ')
	FROM cteSCB
	GROUP BY BuurtCode
	)
SELECT cteBU.BuurtCode
	,[Bewonerscommissie]
	,[Bewonersconsulent]
	,[Complexbeheerder1]
	,[Complexbeheerder2]
	,[Huismeester1]
	,[Huismeester2]
	,[SociaalComplexbeheerder]
FROM cteBU
LEFT OUTER JOIN cteBCOMG ON cteBU.BuurtCode = cteBCOMG.BuurtCode
LEFT OUTER JOIN cteBCONG ON cteBU.BuurtCode = cteBCONG.BuurtCode
LEFT OUTER JOIN cteCB1G ON cteBU.BuurtCode = cteCB1G.BuurtCode
LEFT OUTER JOIN cteCB2G ON cteBU.BuurtCode = cteCB2G.BuurtCode
LEFT OUTER JOIN cteHM1G ON cteBU.BuurtCode = cteHM1G.BuurtCode
LEFT OUTER JOIN cteHM2G ON cteBU.BuurtCode = cteHM2G.BuurtCode
LEFT OUTER JOIN cteSCBG ON cteBU.BuurtCode = cteSCBG.BuurtCode
GO
