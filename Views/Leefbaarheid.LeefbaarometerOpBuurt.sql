SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE view [Leefbaarheid].[LeefbaarometerOpBuurt] as

with CTE_LBM AS (
SELECT BuurtCode, Jaar, LeefbaarometerKlasse  
FROM   
(SELECT BuurtCode = CODE, [2002] = KL02, [2003] = KL02, [2004] = KL02, [2005] = KL02, [2006] = KL02, [2007] = KL02, [2008] = KL08, [2009] = KL08, [2010] = KL08, [2011] = KL08, [2012] = KL12, [2013] = KL12, [2014] = KL14, [2015] = KL14, [2016] = KL16, [2017] = KL16, [2018] = KL18, [2019] = KL18, [2020] = KL18, [2021] = KL18
   FROM [empire_staedion_data].[bik].[Leefbarometer_buurtscore]) p 
UNPIVOT  
   (LeefbaarometerKlasse FOR Jaar IN   
      ([2002], [2003], [2004], [2005], [2006], [2007], [2008], [2009], [2010], [2011], [2012], [2013], [2014], [2015], [2016], [2017], [2018], [2019], [2020], [2021])) as unpvt),
CTE_LBMDIM AS(

SELECT BuurtCode = [GBD]
	  ,Jaar = 2012
      ,DimensieTotaalRelatief = [RLBRMTR12]
	  ,DimensieTotaalAbsoluut = 4.1544 + [RLBRMTR12]
      ,DimensieWoningRelatief = [RLBWON12]
      ,DimensieBewonersRelatief = [RLBBEV12]
      ,DimensieVoorzieningenRelatief = [RLBVRZ12]
      ,DimensieVeiligheidRelatief = [RLBVEI12]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS12]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2013
      ,DimensieTotaalRelatief = [RLBRMTR12]
	  ,DimensieTotaalAbsoluut = 4.1544 + [RLBRMTR12]
      ,DimensieWoningRelatief = [RLBWON12]
      ,DimensieBewonersRelatief = [RLBBEV12]
      ,DimensieVoorzieningenRelatief = [RLBVRZ12]
      ,DimensieVeiligheidRelatief = [RLBVEI12]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS12]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2014
      ,DimensieTotaalRelatief = [RLBRMTR14]
	  ,DimensieTotaalAbsoluut = 4.1631 + [RLBRMTR14]
      ,DimensieWoningRelatief = [RLBWON14]
      ,DimensieBewonersRelatief = [RLBBEV14]
      ,DimensieVoorzieningenRelatief = [RLBVRZ14]
      ,DimensieVeiligheidRelatief = [RLBVEI14]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS14]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2015
      ,DimensieTotaalRelatief = [RLBRMTR14]
	  ,DimensieTotaalAbsoluut = 4.1631 + [RLBRMTR14]
      ,DimensieWoningRelatief = [RLBWON14]
      ,DimensieBewonersRelatief = [RLBBEV14]
      ,DimensieVoorzieningenRelatief = [RLBVRZ14]
      ,DimensieVeiligheidRelatief = [RLBVEI14]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS14]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2016
      ,DimensieTotaalRelatief = [RLBRMTR16]
	  ,DimensieTotaalAbsoluut = 4.1847 + [RLBRMTR16]
      ,DimensieWoningRelatief = [RLBWON16]
      ,DimensieBewonersRelatief = [RLBBEV16]
      ,DimensieVoorzieningenRelatief = [RLBVRZ16]
      ,DimensieVeiligheidRelatief = [RLBVEI16]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS16]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2017
      ,DimensieTotaalRelatief = [RLBRMTR16]
	  ,DimensieTotaalAbsoluut = 4.1847 + [RLBRMTR16]
      ,DimensieWoningRelatief = [RLBWON16]
      ,DimensieBewonersRelatief = [RLBBEV16]
      ,DimensieVoorzieningenRelatief = [RLBVRZ16]
      ,DimensieVeiligheidRelatief = [RLBVEI16]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS16]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2018
      ,DimensieTotaalRelatief = [RLBRMTR18]
	  ,DimensieTotaalAbsoluut = 4.1940 + [RLBRMTR18]
      ,DimensieWoningRelatief = [RLBWON18]
      ,DimensieBewonersRelatief = [RLBBEV18]
      ,DimensieVoorzieningenRelatief = [RLBVRZ18]
      ,DimensieVeiligheidRelatief = [RLBVEI18]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS18]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]
	  
union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2019
      ,DimensieTotaalRelatief = [RLBRMTR18]
	  ,DimensieTotaalAbsoluut = 4.1940 + [RLBRMTR18]
      ,DimensieWoningRelatief = [RLBWON18]
      ,DimensieBewonersRelatief = [RLBBEV18]
      ,DimensieVoorzieningenRelatief = [RLBVRZ18]
      ,DimensieVeiligheidRelatief = [RLBVEI18]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS18]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2020
      ,DimensieTotaalRelatief = [RLBRMTR18]
	  ,DimensieTotaalAbsoluut = 4.1940 + [RLBRMTR18]
      ,DimensieWoningRelatief = [RLBWON18]
      ,DimensieBewonersRelatief = [RLBBEV18]
      ,DimensieVoorzieningenRelatief = [RLBVRZ18]
      ,DimensieVeiligheidRelatief = [RLBVEI18]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS18]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start]

union all

SELECT BuurtCode = [GBD]
	  ,Jaar = 2021
      ,DimensieTotaalRelatief = [RLBRMTR18]
	  ,DimensieTotaalAbsoluut = 4.1940 + [RLBRMTR18]
      ,DimensieWoningRelatief = [RLBWON18]
      ,DimensieBewonersRelatief = [RLBBEV18]
      ,DimensieVoorzieningenRelatief = [RLBVRZ18]
      ,DimensieVeiligheidRelatief = [RLBVEI18]
      ,DimensieFysiekeOmgevingRelatief = [RLBFYS18]
FROM [empire_staedion_data].[bik].[Leefbarometer_dimensiescore_Buurt_start])


select distinct ELS.BuurtCode,
		CTE_LBM.Jaar,
		Klasse = LeefbaarometerKlasse,
		Cijfer = ((cast(LeefbaarometerKlasse AS FLOAT) - 1) / 8) * 9 + 1,
		ScoreTotaalRelatief = DimensieTotaalRelatief,
		ScoreTotaalAbsoluut = DimensieTotaalAbsoluut,
		ScoreWoningRelatief = DimensieWoningRelatief,
		ScoreBewonersRelatief = DimensieBewonersRelatief,
		ScoreVoorzieningenRelatief = DimensieVoorzieningenRelatief,
		ScoreVeiligheidRelatief = DimensieVeiligheidRelatief,
		ScoreFysiekeOmgevingRelatief = DimensieFysiekeOmgevingRelatief

from CTE_LBM inner join empire_staedion_data.bik.ELS_ClusternummerBuurtCode as ELS on (N'BU' + RIGHT(N'00000000' + CAST(ELS.BuurtCode AS nvarchar), 8)) = CTE_LBM.BuurtCode
		left outer join CTE_LBMDIM on CTE_LBMDIM.BuurtCode = CTE_LBM.BuurtCode and CTE_LBMDIM.Jaar = CTE_LBM.Jaar

GO
