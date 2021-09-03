SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Dashboard].[vw_Clusterlocatie]
AS


with cteBUconcept as(SELECT DISTINCT Clusternummer = EIG.[FT clusternr]
	,[BuurtCode] = cast(BU.Code as int)
FROM  [staedion_dm].[Eenheden].[Eigenschappen] as EIG
LEFT OUTER JOIN empire.empire.dbo.[Municipality] AS GM ON GM.[Code] = coalesce(EIG.[Gemeente], 0518)
LEFT OUTER JOIN empire.empire.dbo.[CBS Neighborhood] AS BU ON BU.[Name] = EIG.Buurt
	AND BU.[Municipality Code] = GM.[Code]
WHERE EIG.[FT clusternr] NOT LIKE ''
	AND EIG.[FT clusternr] IS NOT NULL
	AND BU.Code IS NOT NULL
	AND NOT (
		EIG.[FT clusternr] = 'FT-1046'
		AND BU.Code = '05181252'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1258'
		AND BU.Code = '05182915'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1259'
		AND BU.Code = '05182915'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1273'
		AND BU.Code = '05182915'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1443'
		AND BU.Code = '05182144'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1486'
		AND BU.Code = '05184004'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1497'
		AND BU.Code = '05184004'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1545'
		AND BU.Code = '17830154'
		)
	AND NOT (
		EIG.[FT clusternr] = 'FT-1677'
		AND BU.Code = '05183488'
		)
	AND NOT EIG.[FT clusternr] = 'FT-1998'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1256'
	,[BuurtCode] = '05182915'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1319'
	,[BuurtCode] = '05183819'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1499'
	,[BuurtCode] = '19260227'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1501'
	,[BuurtCode] = '19260225'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1507'
	,[BuurtCode] = '19260225'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1508'
	,[BuurtCode] = '19260227'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1530'
	,[BuurtCode] = '05181795'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1531'
	,[BuurtCode] = '19260225'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1536'
	,[BuurtCode] = '19260225'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1538'
	,[BuurtCode] = '19260225'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1545'
	,[BuurtCode] = '17830161'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1559'
	,[BuurtCode] = '17830607'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1561'
	,[BuurtCode] = '17830607'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1576'
	,[BuurtCode] = '05180605'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1679'
	,[BuurtCode] = '05183398'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1730'
	,[BuurtCode] = '05182567'

UNION ALL

SELECT DISTINCT Clusternummer = 'FT-1732'
	,[BuurtCode] = '05184110')
	, cteBU as(
select distinct cteBUconcept.Clusternummer, cteBUconcept.BuurtCode, BUcode = N'BU' + RIGHT(N'00000000' + CAST(cteBUconcept.BuurtCode AS NVARCHAR), 8) from cteBUconcept)

-- select tmp.Clusternummer, tmp.BuurtCode, src.Clusternummer, src.BuurtCode from #TempTable as tmp right outer join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as src on tmp.Clusternummer = src.Clusternummer where tmp.BuurtCode != src.BuurtCode order  by src.Clusternummer;

-- SELECT [Clusternummer]
-- FROM #TempTable group by Clusternummer having count(Clusternummer)>1;

--select * from #TempTable;

,cteTHTEconcept as(SELECT DISTINCT BuurtCode = BU.BuurtCode
	,Thuisteam = EIG.[Thuisteam]
FROM [staedion_dm].[Eenheden].[Eigenschappen] as EIG
RIGHT OUTER JOIN cteBU AS BU ON BU.Clusternummer = EIG.[FT clusternr]
WHERE EIG.[Thuisteam] is not null
AND NOT (
	BuurtCode = '5183721'
	AND Thuisteam = 'Thuisteam Zuid-West'
	)

UNION ALL
	
SELECT BuurtCode = '5032807'
	,Thuisteam = 'Thuisteam Zuid-Oost'

UNION ALL
	
SELECT BuurtCode = '5181309'
	,Thuisteam = 'Thuisteam Noord-West'

UNION ALL
	
SELECT BuurtCode = '5184107'
	,Thuisteam = 'Thuisteam Zuid-Oost')

	,cteTHTE as(
select distinct cteTHTEconcept.BuurtCode, cteTHTEconcept.Thuisteam from cteTHTEconcept)

,cteGBconcept as(select BUcode, Gebied from empire_staedion_data.dbo.Gebiedsindeling
UNION ALL
	
SELECT BUCode = 'BU05180605'
	,Gebied = 'Rood'

UNION ALL
	
SELECT BUCode = 'BU05032807'
	,Gebied = 'Groen'
	
UNION ALL
	
SELECT BUCode = 'BU05184107'
	,Gebied = 'Groen')
,cteGB as(select distinct * from cteGBconcept)

--select tmp.BuurtCode, tmp.Thuisteam, src.BuurtCode, src.Thuisteam from #TempTT as tmp left outer join [empire_staedion_data].[bik].[ELS_BuurtCodeThuisteam] as src on tmp.BuurtCode = src.BuurtCode where tmp.Thuisteam != src.Thuisteam order  by src.BuurtCode;

--SELECT [BuurtCode]
--FROM #TempTT group by BuurtCode having count(BuurtCode)>1;

select cteBU.Clusternummer
		,[Deelgebied] = replace(cteTHTE.Thuisteam, 'Thuisteam ', '')
		,DagelijksOnderhoudGebied = GB.Gebied
		,GMcode = N'GM' + RIGHT(N'0000' + CAST(BU.[Municipality Code] AS NVARCHAR), 4)
		,WKcode = N'WK' + RIGHT(N'000000' + CAST(BU.[District Code] AS NVARCHAR), 6)
		,BUcode = N'BU' + RIGHT(N'00000000' + CAST(cteBU.BuurtCode AS NVARCHAR), 8)
		,Gemeente = GM.[Name]
		,Wijk = DI.[Name]
		,Buurt = BU.[Name]
		,Latitude = coalesce(LBM.ycord, CORD.ycord)
		,Longitude = coalesce(LBM.xcord, CORD.xcord)
		from cteBU
		inner join cteTHTE on cteBU.BuurtCode = cteTHTE.BuurtCode
		inner join empire.empire.dbo.[CBS Neighborhood] AS BU ON BU.[Code] = cteBU.BuurtCode
		inner join empire.empire.dbo.[CBS District] AS DI ON DI.[Code] = BU.[District Code]
		inner join empire.empire.dbo.[Municipality] AS GM ON GM.[Code] = BU.[Municipality Code]
		left outer join empire_staedion_data.bik.Leefbaarometer_gridscore as LBM on LBM.cluster_nr = cteBU.Clusternummer
		left outer join empire_staedion_data.bik.Leefbaarometer_gridscore_overige_coordinaten as CORD on CORD.Clusternummer = cteBU.Clusternummer
		left outer join cteGB as GB on GB.BUCode = cteBU.BUcode


GO
