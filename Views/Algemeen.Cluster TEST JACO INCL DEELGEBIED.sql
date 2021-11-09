SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE VIEW [Algemeen].[Cluster TEST JACO INCL DEELGEBIED]
AS
WITH cte_bouwjaar
AS
(SELECT
		o.mg_bedrijf
	   ,co.Clusternr_
	   ,bouwjaar = MAX(o.[Construction Year])
	   ,renovatiejaar = MAX(o.[renovation year])
	FROM empire_data.dbo.mg_cluster_oge AS co
	JOIN empire_data.dbo.vw_lt_mg_oge AS o
		ON o.mg_bedrijf = co.mg_bedrijf
		AND o.Nr_ = co.Eenheidnr_
	GROUP BY o.mg_bedrijf
			,co.Clusternr_),
cte_tmp
AS
(SELECT
		[Sleutel] = c.lt_id
	   ,[Cluster] = c.Nr_ + ' ' + c.Naam
	   ,[Clusternummer] = c.Nr_
	   ,[Clusternaam] = c.Naam
	   ,[Clustersoort] = ct.Description
	   ,[Bouwjaar] = ISNULL(NULLIF(cb.bouwjaar, ''), 0)
	   ,[Bouw/renovatiejaar] =
		CASE
			WHEN cb.renovatiejaar > cb.bouwjaar THEN cb.renovatiejaar
			ELSE cb.bouwjaar
		END
	   ,[Renovatiejaar] = cb.renovatiejaar
	   ,[Nieuwbouw] =
		CASE
			WHEN cb.bouwjaar >= YEAR(DATEADD(yy, -2, GETDATE())) THEN 'Ja'
			ELSE 'Nee'
		END
	   ,[Sleutel assetmanager] = ccp.Contactnr_
	FROM empire_data.dbo.vw_lt_mg_cluster AS c
	LEFT JOIN empire_data.dbo.mg_cluster_type AS ct
		ON ct.Code = c.Clustersoort
		AND ct.mg_bedrijf = c.mg_bedrijf
	LEFT JOIN cte_bouwjaar AS cb
		ON cb.Clusternr_ = c.Nr_
		AND cb.mg_bedrijf = c.mg_bedrijf
	LEFT JOIN empire_data.dbo.mg_cluster_contactpersoon AS ccp
		ON ccp.mg_bedrijf = c.mg_bedrijf
		AND ccp.Clusternr_ = c.Nr_
		AND ccp.Functie = 'CB-ASSMAN'),
cte_deelgebied
AS
(SELECT
		Clusternummer
	   ,Deelgebied
	   ,Volgnr = ROW_NUMBER() OVER (PARTITION BY Clusternummer ORDER BY Clusternummer)
	FROM staedion_dm.dashboard.vw_Clusterlocatie)


SELECT
	TMP.[Sleutel]
   ,TMP.[Cluster]
   ,TMP.[Clusternummer]
   ,TMP.[Clusternaam]
   ,TMP.[Clustersoort]
   ,TMP.[Bouwjaar]
   ,TMP.[Bouw/renovatiejaar]
   ,TMP.[Renovatiejaar]
   ,TMP.[Nieuwbouw]
   ,TMP.[Sleutel assetmanager]
   ,[Klasse bouw/renovatiejaar] =
	CASE
		WHEN TMP.[Bouw/renovatiejaar] < 1945 THEN 'Tot 1945'
		WHEN TMP.[Bouw/renovatiejaar] < 1960 THEN '1945 - 1959'
		WHEN TMP.[Bouw/renovatiejaar] < 1970 THEN '1960 - 1969'
		WHEN TMP.[Bouw/renovatiejaar] < 1980 THEN '1970 - 1979'
		WHEN TMP.[Bouw/renovatiejaar] < 1990 THEN '1980 - 1989'
		WHEN TMP.[Bouw/renovatiejaar] < 2000 THEN '1990 - 1999'
		WHEN TMP.[Bouw/renovatiejaar] < 2010 THEN '2000 - 2009'
		WHEN TMP.[Bouw/renovatiejaar] >= 2010 THEN '2010 en later'
		ELSE 'Onbekend'
	END
   ,[Klasse bouw/renovatiejaar sortering] =
	CASE
		WHEN TMP.[Bouw/renovatiejaar] < 1945 THEN 1
		WHEN TMP.[Bouw/renovatiejaar] < 1960 THEN 2
		WHEN TMP.[Bouw/renovatiejaar] < 1970 THEN 3
		WHEN TMP.[Bouw/renovatiejaar] < 1980 THEN 4
		WHEN TMP.[Bouw/renovatiejaar] < 1990 THEN 5
		WHEN TMP.[Bouw/renovatiejaar] < 2000 THEN 6
		WHEN TMP.[Bouw/renovatiejaar] < 2010 THEN 7
		WHEN TMP.[Bouw/renovatiejaar] >= 2010 THEN 8
		ELSE 9
	END
	,DEELG.Deelgebied
FROM cte_tmp AS TMP
LEFT OUTER JOIN cte_deelgebied AS DEELG
	ON TMP.Clusternummer = DEELG.Clusternummer
		AND DEELG.Volgnr = 1 -- er kunnen dubbelen in voor gaan komen, vandaar deze restrictie veiligheidshalve ingebouwd



GO
