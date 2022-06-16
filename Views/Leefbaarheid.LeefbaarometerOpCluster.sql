SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Leefbaarheid].[LeefbaarometerOpCluster]
AS
WITH CTE_LBMG
AS (
	SELECT Clusternummer
		,Jaar
		,Klasse
		,Cijfer = ((cast(Klasse AS FLOAT) - 1) / 8) * 9 + 1
		,Latitude
		,Longitude
	FROM (
		SELECT Clusternummer = [cluster_nr]
			,Latitude = [ycord]
			,Longitude = [xcord]
			,[2002] = round([L02_mean], 0)
			,[2003] = round([L02_mean], 0)
			,[2004] = round([L02_mean], 0)
			,[2005] = round([L02_mean], 0)
			,[2006] = round([L02_mean], 0)
			,[2007] = round([L02_mean], 0)
			,[2008] = round([L08_mean], 0)
			,[2009] = round([L08_mean], 0)
			,[2010] = round([L08_mean], 0)
			,[2011] = round([L08_mean], 0)
			,[2012] = round([L12_mean], 0)
			,[2013] = round([L12_mean], 0)
			,[2014] = round([L14_mean], 0)
			,[2015] = round([L14_mean], 0)
			,[2016] = round([L16_mean], 0)
			,[2017] = round([L16_mean], 0)
			,[2018] = round([L18_mean], 0)
			,[2019] = round([L18_mean], 0)
			,[2020] = round([L18_mean], 0)
			,[2021] = round([L18_mean], 0)
		FROM [empire_staedion_data].[bik].[Leefbaarometer_gridscore]
		) p
	UNPIVOT(Klasse FOR Jaar IN (
				[2002]
				,[2003]
				,[2004]
				,[2005]
				,[2006]
				,[2007]
				,[2008]
				,[2009]
				,[2010]
				,[2011]
				,[2012]
				,[2013]
				,[2014]
				,[2015]
				,[2016]
				,[2017]
				,[2018]
				,[2019]
				,[2020]
				,[2021]
				)) AS unpvt
	)
SELECT *
FROM CTE_LBMG
GO
