SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Jaarrekening].[HuurstandenVSGrootboekVERVALLEN]
AS
WITH CTE_HS
AS (
	SELECT jaar
		,oge
		,gemeente
		,rekeningnr = 'Huurstanden'
		,rekeningnaam = 'Huurstanden'
		,[grootboekrekening boekingen per maand] = 'Huurstanden'
		,[eindevorigjaarAantal] = [eindevorigjaarExploitatie]
		,[eindevorigjaarNettohuur] = iif([eindevorigjaarExploitatie] = 1, coalesce([eindevorigjaarNettoHuur], 0), 0)
		,[janAantal] = [janExploitatie]
		,[janNettohuur] = iif([janExploitatie] = 1, coalesce([janNettoHuur], 0), 0)
		,[febAantal] = [febExploitatie]
		,[febNettohuur] = iif([febExploitatie] = 1, coalesce([febNettoHuur], 0), 0)
		,[mrtAantal] = [mrtExploitatie]
		,[mrtNettohuur] = iif([mrtExploitatie] = 1, coalesce([mrtNettoHuur], 0), 0)
		,[aprAantal] = [aprExploitatie]
		,[aprNettohuur] = iif([aprExploitatie] = 1, coalesce([aprNettoHuur], 0), 0)
		,[meiAantal] = [meiExploitatie]
		,[meiNettohuur] = iif([meiExploitatie] = 1, coalesce([meiNettoHuur], 0), 0)
		,[junAantal] = [junExploitatie]
		,[junNettohuur] = iif([junExploitatie] = 1, coalesce([junNettoHuur], 0), 0)
		,[beginjulAantal] = [beginjulExploitatie]
		,[beginjulNettohuur] = iif([beginjulExploitatie] = 1, coalesce([beginjulNettoHuur], 0), 0)
		,[julAantal] = [julExploitatie]
		,[julNettohuur] = iif([julExploitatie] = 1, coalesce([julNettoHuur], 0), 0)
		,[augAantal] = [augExploitatie]
		,[augNettohuur] = iif([augExploitatie] = 1, coalesce([augNettoHuur], 0), 0)
		,[sepAantal] = [sepExploitatie]
		,[sepNettohuur] = iif([sepExploitatie] = 1, coalesce([sepNettoHuur], 0), 0)
		,[oktAantal] = [oktExploitatie]
		,[oktNettohuur] = iif([oktExploitatie] = 1, coalesce([oktNettoHuur], 0), 0)
		,[novAantal] = [novExploitatie]
		,[novNettohuur] = iif([novExploitatie] = 1, coalesce([novNettoHuur], 0), 0)
		,[decAantal] = [decExploitatie]
		,[decNettohuur] = iif([decExploitatie] = 1, coalesce([decNettoHuur], 0), 0)
		,gegenereerd
	FROM [empire_staedion_data].[jaarrekening].[HuurStanden]
	)
	,CTE_GB
AS (
	SELECT Jaar = year(GLE.[Posting Date])
		,Maand = month(GLE.[Posting Date])
		,OGE = OGE.[Realty Object No_]
		,Gemeente = CTE_HS.gemeente
		,Rekeningnr = GLE.[G_L Account No_]
		,Rekeningnaam = GLA.NAME
		,Broncode = GLE.[Source Code]
		,Geboekt = GLE.Amount
	--,Boekdatum = GLE.[Posting Date] 
	--,Cluster = COK.Clusternr_ 
	--,Stuknummer = GLE.[Document No_] 
	--,Volgnummer = GLE.[Entry No_] 
	--,Omschrijving = GLE.[Description] 
	FROM empire_data.dbo.Staedion$G_L_Entry AS GLE
	JOIN empire_Data.dbo.[Staedion$G_L_Account] AS GLA ON GLA.No_ = GLE.[G_L Account No_]
	LEFT OUTER JOIN empire_Data.dbo.Staedion$G_L_Entry___Additional_Data AS OGE ON OGE.[G_L Entry No_] = GLE.[Entry No_]
	INNER JOIN CTE_HS ON CTE_HS.jaar = year(GLE.[Posting Date])
		AND OGE.[Realty Object No_] = CTE_HS.oge
	--LEFT OUTER JOIN empire_data.dbo.Staedion$Detailed_G_L_Entry dgl
	WHERE GLE.[G_L Account No_] IN (
			'A810200'
			,'A850150'
			)
		AND year(GLE.[Posting Date]) IN (
			SELECT DISTINCT jaar
			FROM empire_staedion_data.jaarrekening.HuurStanden
			)
		AND GLE.Amount <> 0
	)
	,CTE_PT
AS (
	SELECT jaar
		,oge
		,gemeente
		,rekeningnr
		,rekeningnaam = CONCAT (
			Rekeningnr
			,' '
			,Rekeningnaam
			)
		,CONCAT (
			'Geboekt als: '
			,Broncode
			) AS [boekingscode]
		,eindevorigjaarAantal = NULL
		,eindevorigjaarNettohuur = NULL
		,janAantal = NULL
		,janNettohuur = [1]
		,febAantal = NULL
		,febNettohuur = [2]
		,mrtAantal = NULL
		,mrtNettohuur = [3]
		,aprAantal = NULL
		,aprNettohuur = [4]
		,meiAantal = NULL
		,meiNettohuur = [5]
		,junAantal = NULL
		,junNettohuur = [6]
		,beginjulAantal = NULL
		,beginjulNettohuur = [7]
		,julAantal = NULL
		,julNettohuur = [7]
		,augAantal = NULL
		,augNettohuur = [8]
		,sepAantal = NULL
		,sepNettohuur = [9]
		,oktAantal = NULL
		,oktNettohuur = [10]
		,novAantal = NULL
		,novNettohuur = [11]
		,decAantal = NULL
		,decNettohuur = [12]
		,gegenereerd = GETDATE()
	FROM (
		SELECT Jaar
			,Maand
			,OGE
			,Gemeente
			,Geboekt
			,Rekeningnr
			,Rekeningnaam
			,Broncode
		FROM CTE_GB
		) AS SourceTable
	PIVOT(sum(Geboekt) FOR Maand IN (
				[1]
				,[2]
				,[3]
				,[4]
				,[5]
				,[6]
				,[7]
				,[8]
				,[9]
				,[10]
				,[11]
				,[12]
				)) AS PivotTable
	)
SELECT *
	,jaarNettohuur = iif(janNettohuur is null and 
						febNettohuur is null and 
						mrtNettohuur is null and 
						aprNettohuur is null and 
						meiNettohuur is null and 
						junNettohuur is null and 
						julNettohuur is null and 
						augNettohuur is null and 
						sepNettohuur is null and 
						oktNettohuur is null and  
						novNettohuur is null and 
						decNettohuur is null, null,
						(coalesce(janNettohuur, 0) +
						coalesce(febNettohuur, 0) +
						coalesce(mrtNettohuur, 0) +
						coalesce(aprNettohuur, 0) +
						coalesce(meiNettohuur, 0) +
						coalesce(junNettohuur, 0) +
						coalesce(julNettohuur, 0) +
						coalesce(augNettohuur, 0) +
						coalesce(sepNettohuur, 0) +
						coalesce(oktNettohuur, 0) + 
						coalesce(novNettohuur, 0) + 
						coalesce(decNettohuur, 0)))
FROM CTE_PT

UNION

SELECT *
	,jaarNettohuur = iif(janNettohuur is null and 
						febNettohuur is null and 
						mrtNettohuur is null and 
						aprNettohuur is null and 
						meiNettohuur is null and 
						junNettohuur is null and 
						julNettohuur is null and 
						augNettohuur is null and 
						sepNettohuur is null and 
						oktNettohuur is null and  
						novNettohuur is null and 
						decNettohuur is null, null,
						(coalesce(janNettohuur, 0) +
						coalesce(febNettohuur, 0) +
						coalesce(mrtNettohuur, 0) +
						coalesce(aprNettohuur, 0) +
						coalesce(meiNettohuur, 0) +
						coalesce(junNettohuur, 0) +
						coalesce(julNettohuur, 0) +
						coalesce(augNettohuur, 0) +
						coalesce(sepNettohuur, 0) +
						coalesce(oktNettohuur, 0) + 
						coalesce(novNettohuur, 0) + 
						coalesce(decNettohuur, 0)))
FROM CTE_HS;
GO
