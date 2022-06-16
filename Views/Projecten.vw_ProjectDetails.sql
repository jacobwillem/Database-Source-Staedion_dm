SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Projecten].[vw_ProjectDetails] as 
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
JvdW 20220428 TBV PBI rapportage budgetrapportage planmatig onderhoud: bedoeld om alle details in 1 matrix te kunnen tonen
JvdW 20220513 Tbv PBI rapportage budgetrapportage leefbaarheid: BRS.Regelstatus toevoegen op alle budgetregelnrs
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_RealisatieDetails'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    

with cte_budgetregelstatus as		-- op alle regels toe laten passen
(select B.Project_id, B.Budgetregelnr_, BRS.RegelStatus
FROM staedion_dm.Projecten.[Budget] AS B
    LEFT OUTER JOIN staedion_dm.Projecten.BudgetRegelStatus AS BRS
        ON BRS.id = B.Budgetstatus_id)

SELECT 'Totaal' AS SoortRegel
	,PG.project_id
	, CONCAT(PG.Projectnr, ' ',PG.Naam) AS Project
	, concat_ws(' ; ',PG.Projectnr + ' ' + PG.Naam, ' totaal') as ProjectWerksoort
	, COALESCE(NULLIF(PG.Contractnr,''), 'Geen onderhoudscontractnr') AS Contractnr
	, PG.Actief
	, PG.Projecttype
	, totaal_Budget = COALESCE((
			SELECT CONVERT(FLOAT, SUM(B.Budget_incl_btw))
			FROM [projecten].[Budget] AS B
			WHERE B.project_id = PG.project_id
			), 0)
	, totaal_Realisatie = COALESCE((
			SELECT CONVERT(FLOAT, SUM(R.[Realisatie incl_ BTW]))
			FROM [projecten].Realisatie AS R
			WHERE R.project_id = PG.project_id
			), 0)
	, totaal_Verplichting_historie = COALESCE((
			SELECT CONVERT(FLOAT, SUM(VH.[verplicht_incl_btw]))
			FROM [projecten].[Verplichting_historie] AS VH
			WHERE VH.project_id = PG.project_id
				AND VH.peildatum = (
					SELECT MAX(peildatum)
					FROM [projecten].[Verplichting_historie]
					)
			), 0)
	, totaal_Verplichting = COALESCE((
			SELECT CONVERT(FLOAT, SUM(V.[verplicht_incl_btw]))
			FROM [projecten].[Verplichting] AS V
			WHERE V.project_id = PG.project_id
			), 0)
	, totaal_Prognose = COALESCE((
			SELECT CONVERT(FLOAT, SUM(P.Prognose_incl_btw))
			FROM [projecten].[Budget] AS P
			WHERE P.project_id = PG.project_id
			), 0)
     , NULL AS Budgetregelnr
	 , 'Nvt' as Budgetregelstatus
     , NULL AS [Budget incl btw]
	 , NULL AS [Realisatie incl btw]
	 , NULL AS [Verplichting incl btw]
	 , NULL AS [Prognose incl BTW]
     , NULL AS Cluster
     , NULL AS Werksoort
     , NULL AS Omschrijving
	 , NULL AS WerksoortInclOmschrijving
	 , NULL AS [Omschrijving 2]
	 , NULL AS [Document No_]
	 , NULL AS Boekdatum
	 , NULL AS [Job Ledger Entry No_]
	 , NULL AS [Resource No_]
	 , NULL AS [Item No_]
	 , NULL AS Leveranciersnr
	 , NULL AS leveranciersnaam
	 , NULL AS [Order status]
	 , NULL AS Inkoopregelnr_

	 , NULL AS Startdatum 
	 , NULL AS [Vrije code Budgetregel]
	 , NULL AS Opleverdatum
-- select distinct Projecttype
-- select top 10 *
FROM [projecten].[vw_Projectgegevens] AS PG
--WHERE PG.Projectnr  = @Nr or @Nr is null
GROUP BY PG.project_id, PG.Projectnr,PG.Actief , PG.Contractnr, PG.Naam, PG.Projecttype

UNION 
SELECT 'Budgetregels' AS SoortRegel
	,PG.project_id
	, CONCAT(PG.Projectnr, ' ',PG.Naam) AS Project
	, concat_ws(' ; ',CONCAT(PG.Projectnr, ' ',PG.Naam), CONCAT(W.Werksoort,' ',W.Omschrijving)) as ProjectWerksoort
	, COALESCE(NULLIF(PG.Contractnr,''), 'Geen onderhoudscontractnr') AS Contractnr
     , PG.Actief 
	 , PG.Projecttype
     , NULL AS totaal_Budget
     , NULL AS totaal_Realisatie
     , NULL AS totaal_Verplichting_Historie
     , NULL AS totaal_Verplichting
     , NULL AS totaal_Prognose
     , B.Budgetregelnr_ AS Budgetregelnr
	 , coalesce(BRS.Regelstatus, 'Onbekend') as Budgetregelstatus
     , CONVERT(FLOAT, coalesce(B.Budget_incl_btw,0)) AS [Budget incl btw]
	 , NULL AS [Realisatie incl btw]
	 , NULL AS [Verplichting incl btw]
	 , NULL AS [Prognose incl BTW]
     , B.Cluster
     , W.Werksoort
     , W.Omschrijving
	 , CONCAT(W.Werksoort,' ',W.Omschrijving) AS WerksoortInclOmschrijving
	 , NULL AS [Omschrijving 2]
	 , NULL AS [Document No_]
	 , NULL AS Boekdatum
	 , NULL AS [Job Ledger Entry No_]
	 , NULL AS [Resource No_]
	 , NULL AS [Item No_]
	 , NULL AS Leveranciersnr
	 , NULL AS leveranciersnaam
	 , NULL AS [Order status]
	 , NULL AS Inkoopregelnr_

	 , NULL AS Startdatum 
	 , NULL AS [Vrije code Budgetregel]
	 , NULL AS Opleverdatum
-- select count(*) -- 93613
FROM [projecten].[vw_Projectgegevens] AS PG
    LEFT OUTER JOIN staedion_dm.Projecten.[Budget] AS B
        ON B.Project_id = PG.project_id
    LEFT OUTER JOIN staedion_dm.Projecten.Werksoort AS W
        ON B.Werksoort_id = W.id
    LEFT OUTER JOIN staedion_dm.Projecten.BudgetRegelStatus AS BRS
        ON BRS.id = B.Budgetstatus_id

-- WHERE PG.Projectnr  = @Nr or @Nr is NULL

UNION

SELECT 'Realisatieregels' AS SoortRegel
	,PG.project_id
	, CONCAT(PG.Projectnr, ' ',PG.Naam) AS Project
	, concat_ws(' ; ',CONCAT(PG.Projectnr, ' ',PG.Naam), CONCAT(W.Werksoort,' ',W.Omschrijving)) as ProjectWerksoort
	, COALESCE(NULLIF(PG.Contractnr,''), 'Geen onderhoudscontractnr') AS Contractnr
     , PG.Actief 
	 , PG.Projecttype
     , NULL AS totaal_Budget
     , NULL AS totaal_Realisatie
     , NULL AS totaal_Verplichting_Historie
     , NULL AS totaal_Verplichting
     , NULL AS totaal_Prognose
     , R.Budgetregelnr_ AS Budgetregelnr
	 , coalesce(BRS.Regelstatus, 'Onbekend') as Budgetregelstatus
     , NULL AS [Budget incl btw]
	 , CONVERT(float,R.[Realisatie incl_ BTW]) AS [Realisatie incl btw]
	 , NULL AS [Verplichting incl btw]
	 , NULL AS [Prognose incl BTW]
     , R.cluster
     , W.Werksoort
     , W.Omschrijving
	 , CONCAT(W.Werksoort,' ',W.Omschrijving) AS WerksoortInclOmschrijving
	 , NULL AS [Omschrijving 2]
	 , R.[Document No_]
	 , R.Boekdatum
	 , R.[Job Ledger Entry No_]
	 , R.[Resource No_]
	 , R.[Item No_]
	 , R.[Vendor No_] AS Leveranciersnr
	 , V.[Name] AS Leveranciersnaam
	 , NULL AS [Order status]
	 , NULL AS Inkoopregelnr_

	 , NULL AS Startdatum 
	 , NULL AS [Vrije code Budgetregel]
	 , NULL AS Opleverdatum

-- select convert(float,sum(R.[Realisatie incl_ BTW]))
FROM [projecten].[vw_Projectgegevens] AS PG
LEFT OUTER JOIN staedion_dm.Projecten.Realisatie AS R
       ON R.project_id = PG.project_id
LEFT OUTER JOIN staedion_dm.Projecten.Werksoort AS W
       ON R.Werksoort_id = W.id
LEFT OUTER JOIN empire_data.dbo.vendor AS V
       ON V.No_ = R.[Vendor No_]
LEFT OUTER JOIN cte_budgetregelstatus as BRS
		ON BRS.Project_id = PG.project_id
		and BRS.Budgetregelnr_ = R.Budgetregelnr_
-- WHERE PG.Projectnr  = @Nr or @Nr is NULL

union
SELECT 'Verplichtingregels' AS SoortRegel
	,PG.project_id
	, CONCAT(PG.Projectnr, ' ',PG.Naam) AS Project
	, concat_ws(' ; ',CONCAT(PG.Projectnr, ' ',PG.Naam), CONCAT(W.Werksoort,' ',W.Omschrijving)) as ProjectWerksoort
	, COALESCE(NULLIF(PG.Contractnr,''), 'Geen onderhoudscontractnr') AS Contractnr
     , PG.Actief 
	 , PG.Projecttype
     , NULL AS totaal_Budget
     , NULL AS totaal_Realisatie
     , NULL AS totaal_Verplichting_Historie
     , NULL AS totaal_Verplichting
     , NULL AS totaal_Prognose
     , PP.Budgetregelnr_ AS Budgetregelnr
	 , coalesce(BRS.Regelstatus, 'Onbekend') as Budgetregelstatus
     , NULL AS [Budget incl btw]
	 , NULL AS [Realisatie incl btw]
	 , PP.[verplicht_incl_btw] AS [Verplichting incl btw]
	 , NULL AS [Prognose incl BTW]
     , PP.cluster
     , W.Werksoort
     , W.Omschrijving
	 , CONCAT(W.Werksoort,' ',W.Omschrijving) AS WerksoortInclOmschrijving
	 , PP.[Omschrijving 2]
	 , PP.[Document No_]
	 , NULL AS Boekdatum
	 , NULL AS [Job Ledger Entry No_]
	 , NULL AS [Resource No_]
	 , NULL AS [Item No_]
	 , PP.Leveranciersnr 
	 , V.[Name] AS Leveranciersnaam
	 , PP.[Order status]
	 , PP.Inkoopregelnr_

	 , NULL AS Startdatum 
	 , NULL AS [Vrije code Budgetregel]
	 , NULL AS Opleverdatum

FROM [projecten].[vw_Projectgegevens] AS PG
LEFT OUTER JOIN staedion_dm.Projecten.[Verplichting] AS PP
       ON PP.project_id = PG.project_id
LEFT OUTER JOIN staedion_dm.Projecten.Werksoort AS W
       ON PP.Werksoort_id = W.id
LEFT OUTER JOIN empire_data.dbo.vendor AS V
       ON V.No_ = PP.Leveranciersnr 
LEFT OUTER JOIN cte_budgetregelstatus as BRS
		ON BRS.Project_id = PG.project_id
		and BRS.Budgetregelnr_ = PP.Budgetregelnr_
-- WHERE PG.Projectnr  = @Nr or @Nr is null

UNION 

SELECT 'Prognoseregels' AS SoortRegel
	,PG.project_id
	 , CONCAT(PG.Projectnr, ' ',PG.Naam) AS Project
	, concat_ws(' ; ',CONCAT(PG.Projectnr, ' ',PG.Naam), CONCAT(W.Werksoort,' ',W.Omschrijving)) as ProjectWerksoort
	, COALESCE(NULLIF(PG.Contractnr,''), 'Geen onderhoudscontractnr') AS Contractnr
     , PG.Actief 
	 , PG.Projecttype
     , NULL AS totaal_Budget
     , NULL AS totaal_Realisatie
     , NULL AS totaal_Verplichting_Historie
     , NULL AS totaal_Verplichting
     , NULL AS totaal_Prognose
     , PP.Budgetregelnr_ AS Budgetregelnr
	 , coalesce(BRS.Regelstatus, 'Onbekend') as Budgetregelstatus
     , NULL AS [Budget incl btw]
	 , NULL AS [Realisatie incl btw]
	 , NULL AS [Verplichting incl btw]
	 , convert(float,PP.[Prognose_incl_BTW]) AS [Prognose incl BTW]
     , PP.cluster
     , W.Werksoort
     , W.Omschrijving
	 , CONCAT(W.Werksoort,' ',W.Omschrijving) AS WerksoortInclOmschrijving
	 , NULL AS [Omschrijving 2]
	 , NULL AS [Document No_]
	 , NULL AS Boekdatum
	 , NULL AS [Job Ledger Entry No_]
	 , NULL AS [Resource No_]
	 , NULL AS [Item No_]
	 , NULL AS Leveranciersnr 
	 , NULL AS leveranciersnaam
	 , NULL AS [Order status]
	 , NULL AS Inkoopregelnr_

	 , PP.Startdatum 
	 , PP.[Vrije code Budgetregel]
	 , PP.Opleverdatum

 --select PP.*
FROM staedion_dm.projecten.[vw_Projectgegevens] AS PG
LEFT OUTER JOIN staedion_dm.Projecten.[Budget] AS PP
       ON PP.project_id = PG.project_id
    LEFT OUTER JOIN staedion_dm.Projecten.Werksoort AS W
        ON PP.Werksoort_id = W.id
	LEFT OUTER JOIN cte_budgetregelstatus as BRS
		ON BRS.Project_id = PG.project_id
		and BRS.Budgetregelnr_ = PP.Budgetregelnr_
where PP.[Prognose_incl_BTW] is not null
-- WHERE PG.Projectnr  like '4012400358%'
 
GO
