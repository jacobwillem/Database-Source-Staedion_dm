SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Dashboard].[vw_Clusterlocatie]
AS
	with brt ([FT clusternr], [CBS buurt], volgnr)
	as (select sub.[FT clusternr], [CBS buurt], row_number() over (partition by sub.[FT clusternr] order by sub.aantal desc) Volgnr
		from (select eig.[FT clusternr], iif(eig.[CBS buurt Code] = '', replace(eig.[CBS buurt], 'BU', ''), eig.[CBS Buurt Code]) [CBS buurt], count(*) aantal
			from staedion_dm.Eenheden.Eigenschappen eig
			where eig.Ingangsdatum <= getdate() and (eig.Einddatum is null or eig.Einddatum >= convert(date, getdate())) and
			eig.[FT clusternr] not in ('', 'FT-1998')
			group by eig.[FT clusternr], iif(eig.[CBS buurt Code] = '', replace(eig.[CBS buurt], 'BU', ''), eig.[CBS Buurt Code])
		-- tijdelijke oplossing voor ontbrekende clusters
		union
		select b.cluster, b.buurt, 1
		from (values ('FT-1319', '05183819'), 
			('FT-1679', '05183398')) b(cluster, buurt)) as sub),
	tht ([FT clusternr], [Thuisteam], [volgnr])
	as (select sub.[FT clusternr], sub.[Thuisteam], row_number() over (partition by sub.[FT clusternr] order by sub.aantal desc) Volgnr
		from (select eig.[FT clusternr], eig.[Thuisteam], count(*) aantal
			from staedion_dm.Eenheden.Eigenschappen eig
			where eig.Ingangsdatum <= getdate() and (eig.Einddatum is null or eig.Einddatum >= convert(date, getdate())) and
			eig.[FT clusternr] not in ('', 'FT-1998')
			group by eig.[FT clusternr], eig.[Thuisteam]) sub),
	gbd ([BUcode], [Gebied])
	as (select [BUcode], [Gebied] 
		from empire_staedion_data.dbo.Gebiedsindeling
		union
		select 'BU05180605', 'Rood'
		union
		select 'BU05032807', 'Groen'
		union
		select 'BU05184107', 'Groen')
	select brt.[FT clusternr] [Clusternummer], clu.Naam [Clusternaam],
		replace(tht.[Thuisteam], 'Thuisteam ', '') [Deelgebied],
		case tht.[Thuisteam] when 'Thuisteam Centrum' then 'Bob Koopman'
			when 'Thuisteam Zuid-West' then 'Brendan Holters'
			when 'Thuisteam Zuid-Oost' then 'Eric Buitenhuis'
			when 'Thuisteam Noord-West' then 'Eric Buitenhuis'
			else '' end [Woonfraudebestrijder],
		gbd.[Gebied] [DagelijksOnderhoudGebied],
		'GM' + left(brt.[CBS buurt], 4) [GMCode], gem.[Name] [Gemeente],
		'WK' + left(brt.[CBS buurt], 6) [WKcode], wyk.[Name] [Wijk],
		'BU' + brt.[CBS buurt] [BUcode], cbt.[Name] [Buurt],
		coalesce(lbm.ycord, crd.ycord) [Latitude],
		coalesce(lbm.xcord, crd.xcord) [Longitude]
	from brt inner join empire_data.dbo.Staedion$Cluster clu
	on brt.[FT clusternr] = clu.[Nr_]
	left outer join tht
	on brt.[FT clusternr] = tht.[FT clusternr] and tht.[Volgnr] = 1
	left outer join empire_data.dbo.[Municipality] gem
	on left(brt.[CBS buurt], 4) = gem.[Code]
	left outer join empire_data.dbo.[CBS_District] wyk
	on left(brt.[CBS buurt], 6) = wyk.[Code]
	left outer join empire_data.dbo.[CBS_Neighborhood] cbt
	on brt.[CBS buurt]= cbt.[Code]
	left outer join gbd
	on 'BU' + brt.[CBS buurt] = gbd.BUcode
	left outer join empire_staedion_data.bik.Leefbaarometer_gridscore lbm
	on brt.[FT clusternr] = lbm.cluster_nr 
	left outer join empire_staedion_data.bik.Leefbaarometer_gridscore_overige_coordinaten crd
	on brt.[FT clusternr]= crd.Clusternummer 
	where brt.volgnr = 1

/* vanaf hier tot einde de 'oude' definitie

WITH cteBUconcept AS(SELECT DISTINCT Clusternummer = EIG.[FT clusternr]
	,[BuurtCode] = CAST(BU.Code AS INT)
FROM  [staedion_dm].[Eenheden].[Eigenschappen] AS EIG
LEFT OUTER JOIN empire.empire.dbo.[Municipality] AS GM ON GM.[Code] = COALESCE(EIG.[Gemeente], 0518)
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
	,[BuurtCode] = '05184110'
	
UNION ALL

-- JvdW 22-03-2022 toegevoegd tijdelijk totdat een andere werkwijze is gevonden
SELECT DISTINCT Clusternummer = 'FT-1096'	,[BuurtCode] = '19161100'

UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1097'	,[BuurtCode] = '19161100'

UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1100'	,[BuurtCode] = '19160004' -- PP 20220331 deze komt niet voor in de buurtlijst, moet dit niet Voorburg Noord zuid zijn? buurtcode 19161100

UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1181'	,[BuurtCode] = '05181697'

UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1182'	,[BuurtCode] = '05181697'
UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1186'	,[BuurtCode] = '05181697'

UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1188'	,[BuurtCode] = '05181697'
UNION ALL
	
SELECT DISTINCT Clusternummer = 'FT-1603'	,[BuurtCode] = '05181697'

	
	)
	, cteBU AS(
SELECT DISTINCT cteBUconcept.Clusternummer, Clusternaam = CLN.[Naam], cteBUconcept.BuurtCode, BUcode = N'BU' + RIGHT(N'00000000' + CAST(cteBUconcept.BuurtCode AS NVARCHAR), 8) FROM cteBUconcept LEFT OUTER JOIN empire_data.dbo.Staedion$Cluster AS CLN ON cteBUconcept.Clusternummer = CLN.Nr_)

-- select tmp.Clusternummer, tmp.BuurtCode, src.Clusternummer, src.BuurtCode from #TempTable as tmp right outer join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as src on tmp.Clusternummer = src.Clusternummer where tmp.BuurtCode != src.BuurtCode order  by src.Clusternummer;

-- SELECT [Clusternummer]
-- FROM #TempTable group by Clusternummer having count(Clusternummer)>1;

--select * from #TempTable;

,cteTHTEconcept AS(SELECT DISTINCT BuurtCode = BU.BuurtCode
	,Thuisteam = EIG.[Thuisteam]
FROM [staedion_dm].[Eenheden].[Eigenschappen] AS EIG
RIGHT OUTER JOIN cteBU AS BU ON BU.Clusternummer = EIG.[FT clusternr]
WHERE EIG.[Thuisteam] IS NOT NULL
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

	,cteTHTE AS(
SELECT DISTINCT cteTHTEconcept.BuurtCode, cteTHTEconcept.Thuisteam FROM cteTHTEconcept)

,cteGBconcept AS(SELECT BUcode, Gebied FROM empire_staedion_data.dbo.Gebiedsindeling
UNION ALL
	
SELECT BUCode = 'BU05180605'
	,Gebied = 'Rood'

UNION ALL
	
SELECT BUCode = 'BU05032807'
	,Gebied = 'Groen'
	
UNION ALL
	
SELECT BUCode = 'BU05184107'
	,Gebied = 'Groen')
,cteGB AS(SELECT DISTINCT * FROM cteGBconcept)
,cteWF AS(
SELECT	 Thuisteam = 'Thuisteam Centrum'
		,Woonfraudebestrijder = 'Bob Koopman'

UNION ALL

SELECT   Thuisteam = 'Thuisteam Zuid-West'
		,Woonfraudebestrijder = 'Brendan Holters'

UNION ALL

SELECT	 Thuisteam = 'Thuisteam Zuid-Oost'
		,Woonfraudebestrijder = 'Eric Buitenhuis'

UNION ALL

SELECT	 Thuisteam = 'Thuisteam Noord-West'
		,Woonfraudebestrijder = 'Eric Buitenhuis')

--select tmp.BuurtCode, tmp.Thuisteam, src.BuurtCode, src.Thuisteam from #TempTT as tmp left outer join [empire_staedion_data].[bik].[ELS_BuurtCodeThuisteam] as src on tmp.BuurtCode = src.BuurtCode where tmp.Thuisteam != src.Thuisteam order  by src.BuurtCode;

--SELECT [BuurtCode]
--FROM #TempTT group by BuurtCode having count(BuurtCode)>1;

SELECT cteBU.Clusternummer
		,cteBU.Clusternaam
		,[Deelgebied] = REPLACE(cteTHTE.Thuisteam, 'Thuisteam ', '')
		,cteWF.Woonfraudebestrijder
		,DagelijksOnderhoudGebied = GB.Gebied
		,GMcode = N'GM' + RIGHT(N'0000' + CAST(BU.[Municipality Code] AS NVARCHAR), 4)
		,WKcode = N'WK' + RIGHT(N'000000' + CAST(BU.[District Code] AS NVARCHAR), 6)
		,BUcode = N'BU' + RIGHT(N'00000000' + CAST(cteBU.BuurtCode AS NVARCHAR), 8)
		,Gemeente = GM.[Name]
		,Wijk = DI.[Name]
		,Buurt = BU.[Name]
		,Latitude = COALESCE(LBM.ycord, CORD.ycord)
		,Longitude = COALESCE(LBM.xcord, CORD.xcord)
		FROM cteBU
		INNER JOIN cteTHTE ON cteBU.BuurtCode = cteTHTE.BuurtCode
		INNER JOIN empire.empire.dbo.[CBS Neighborhood] AS BU ON BU.[Code] = cteBU.BuurtCode
		INNER JOIN empire.empire.dbo.[CBS District] AS DI ON DI.[Code] = BU.[District Code]
		INNER JOIN empire.empire.dbo.[Municipality] AS GM ON GM.[Code] = BU.[Municipality Code]
	    LEFT OUTER JOIN cteWF ON cteTHTE.Thuisteam = cteWF.Thuisteam
		LEFT OUTER JOIN empire_staedion_data.bik.Leefbaarometer_gridscore AS LBM ON LBM.cluster_nr = cteBU.Clusternummer
		LEFT OUTER JOIN empire_staedion_data.bik.Leefbaarometer_gridscore_overige_coordinaten AS CORD ON CORD.Clusternummer = cteBU.Clusternummer
		LEFT OUTER JOIN cteGB AS GB ON GB.BUCode = cteBU.BUcode

*/
GO
