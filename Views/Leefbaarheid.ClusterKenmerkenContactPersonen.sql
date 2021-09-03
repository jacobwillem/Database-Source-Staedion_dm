SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE view [Leefbaarheid].[ClusterKenmerkenContactPersonen] as

SELECT [Clusternummer]  = C.Nr_

	,[BewonerscommissieJN] = case when FN.Bewonerscommissie is null then 0 else  1 end
	,[ComplexbeheerderJN] = case when FN.[Complexbeheerder 1] is null and FN.[Complexbeheerder 2] is null then 0 else 1 end
	,[HuismeesterJN] = case when FN.[Huismeester 1] is null and FN.[Huismeester 2] is null then 0 else 1 end 
	,[Sociaal ComplexbeheerderJN] = case when FN.[Sociaal Complexbeheerder] is null then 0 else 1 end

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
WHERE C.Nr_ LIKE 'FT%'
GO
