SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Verhuur].[GeaccepteerdeOrdersMutatieonderhoud]
AS
	WITH cte_verzoek
	AS (
		SELECT [Verzoek] = REQ.No_
			,[Verzoek - status] = CASE REQ.[Status]
					WHEN 0	THEN 'Nieuw'
					WHEN 3	THEN 'Te beoordelen'
					WHEN 6	THEN 'Inspectie'
					WHEN 10	THEN 'In behandeling'
					WHEN 14	THEN 'Technisch gereed'
					WHEN 15	THEN 'Geweigerd na kostenspecificatie'
					WHEN 16	THEN 'Wacht op goedkeuring kostenspecificatie'
					WHEN 17	THEN 'Geweigerd na steekproef'
					WHEN 18	THEN 'Vrijgegeven voor facturatie'
					WHEN 20	THEN 'Afgehandeld'
					WHEN 25	THEN 'Geannuleerd'
					WHEN 30	THEN 'Geweigerd'
					ELSE '' --convert(NVARCHAR(4), REQ.[Status])
				END
			,[Verzoek - onderhoudstype] = CASE REQ.[Maintenance Type]
					WHEN 3	THEN 'Reparatieonderhoud'
					WHEN 7	THEN 'Mutatieonderhoud'
					WHEN 11	THEN 'Planmatig onderhoud'
					WHEN 15	THEN 'Leefbaarheid'
					WHEN 19	THEN 'WMO aanpassing'
					WHEN 23	THEN 'Woningverbetering'
					ELSE CONVERT(NVARCHAR(4), REQ.[Maintenance Type])
				END
			,[Verzoek - huurdernr] = REQ.[Tenant Customer No_]
			,[Verzoek - eenheidnr] = REQ.[Realty Object No_]
			,[Verzoek - clusternummer] = REQ.[Cluster No_]
			,[Verzoek - omschrijving] = REQ.[Description]
			,[Verzoek - datum invoer] = REQ.[Reporting Date]
			,[Verzoek - ingevoerd door] = REQ.[Created By]
			,[Verzoek - Ingevoerd vanuit] = CASE REQ.[Created From]
					WHEN 0	THEN 'Handmatig'
					WHEN 1	THEN 'Klantportaal'
					WHEN 2	THEN 'Vraagboom'
					WHEN 3	THEN 'Huuropzegging'
					WHEN 4	THEN 'KOVRA'
					ELSE CONVERT(NVARCHAR(2), REQ.[Created From])
				END
			,[Verzoek - locatie] = IIF(REQ.[Common Area] = 1, [Type Description], [Address])
		FROM [empire_data].[dbo].[Staedion$Maintenance_Request] AS REQ
		WHERE [Maintenance Type] = 7
			AND [Status] NOT IN (25, 30)
		)
		,cte_order
	AS (
		SELECT REQ.*
			,[Order] = ORD.[No_]
			,[Order - leverancier] = ORD.[Vendor No_]
			,[Order - acceptatiedatum] = ORD.[Date accepted]
			,[Order - gunningsdatum] = ORD.[Date awarded]
			,[Order - status] = CASE ORD.[Status]
					WHEN 0	THEN 'Nieuw'
					WHEN 4	THEN 'Offerte aangevraagd'
					WHEN 8	THEN 'Offerte ontvangen'
					WHEN 12	THEN 'Offerte geaccepteerd'
					WHEN 16	THEN 'Offerte afgewezen'
					WHEN 20	THEN 'Wacht op goedkeuring'
					WHEN 24	THEN 'Vrijgegeven'
					WHEN 28	THEN 'Gegund'
					WHEN 32	THEN 'Geaccepteerd'
					WHEN 36	THEN 'Geweigerd'
					WHEN 40	THEN 'Te plannen'
					WHEN 44	THEN 'Gepland'
					WHEN 48	THEN 'Def. gepland'
					WHEN 52	THEN 'In uitvoering'
					WHEN 56	THEN 'Onderbroken'
					WHEN 60	THEN 'Technisch gereed'
					WHEN 62	THEN 'Wacht op goedkeuring kostenspecificatie'
					WHEN 63	THEN 'Vrijgegeven voor facturatie'
					WHEN 64	THEN 'Afgehandeld'
					WHEN 65	THEN 'Geannuleerd'
					ELSE CONVERT(NVARCHAR(4), ORD.[Status])
				END
		FROM cte_verzoek AS REQ
		INNER JOIN empire_Data.dbo.Staedion$DM___Maintenance_Order AS ORD
			ON ORD.[Maintenance Request No_] = REQ.[Verzoek]
		WHERE ORD.[Status] NOT IN (0, 20, 28, 36, 65)
			AND YEAR(ORD.[Date accepted]) >= 2021	-- Filter op jaar acceptatie order >= 2021
		)
		,cte_taak
	AS (
		SELECT ORD.*
			,[Taak] = TAA.No_
			,[Taak - aanmaakdatum] = TAA.[Creation Date]
			,[Taak - standaard taakcode] = TAA.[Standard Task Code]
			,[Taak - omschrijving] = TAA.[Description]
			,[Taak - status] = CASE TAA.[Status]
				WHEN 0	THEN 'Nieuw'
				WHEN 10	THEN 'Offerte'
				WHEN 19	THEN 'In behandeling'
				WHEN 20	THEN 'Technisch gereed'
				WHEN 28	THEN 'Afgehandeld'
				WHEN 32	THEN 'Geannuleerd'
				ELSE CONVERT(NVARCHAR(4), TAA.[Status])
				END
		FROM cte_order AS ORD
		LEFT OUTER JOIN empire_data.dbo.Staedion$Maintenance_Task AS TAA
			ON ORD.[Order] = TAA.[Maintenance Order No_]
		WHERE TAA.[Standard Task Code] IN ('MU-01', 'MU-02', 'MU-03', 'MU-04', 'MU-05', 'MU-06', 'MU-07') -- Codes voor mutatieonderhoud
		)
		,cte_inspectie
	AS (
		SELECT APP.[Maintenance Request No_]
			,[Line No_] = MAX(APP.[Line No_])
		FROM [empire_data].[dbo].[Staedion$DM___Inspection_Appointment] AS APP
		WHERE APP.[Type] = 0
		GROUP BY [Maintenance Request No_]
		)
		,cte_verhuurteam
	AS (
		SELECT Ingangsdatum = MAX(Ingangsdatum)
			,Eenheidnr
			,Verhuurteam = MAX(Verhuurteam)
		FROM staedion_dm.Eenheden.Eigenschappen
		GROUP BY Eenheidnr
		)
		,cte_ls
	AS (SELECT [laatste] = MAX([datum_gegenereerd]) 
		FROM [empire_staedion_data].[dbo].[ELS]
		)
		,cte_els
	AS (
	SELECT [Eenheidnr]
			  ,[omschrijving_technischtype]
			  ,[Verhuurteam] = [contactpersoon_CB_VHTEAM]
			  ,[Adres] =  iif([straat] = '', '', [straat] + ' ')
						+ iif(CONVERT(NVARCHAR(64), [huisnummer]) = '', '', CONVERT(NVARCHAR(64), [huisnummer]) + ' ')
						+ iif([toevoegsel] = '', '', [toevoegsel] + ' ')
						+ iif([da_plaats] = '', '', [da_plaats] + ' ')
		FROM [empire_staedion_data].[dbo].[ELS]
		CROSS JOIN cte_ls
		WHERE [datum_gegenereerd] = cte_ls.[laatste]
		)

	SELECT DagelijksOnderhoudGebied = COALESCE(LOC.DagelijksOnderhoudGebied, [Verzoek - clusternummer])
		,TAA.*
		,Voorinspectie = IIF(YEAR(CAST(APP.[Date] AS DATE)) <> 1753
			AND APP.[Date] IS NOT NULL, APP.[Date], TAA.[Verzoek - datum invoer])
		,Inspecteur = COALESCE(EMPINS.[Volledige naam], EMPMAN.[Volledige naam])
		,Email = COALESCE(EMPINS.[Werk email], EMPMAN.[Werk email])
		,Functie = COALESCE(EMPINS.Functie, EMPMAN.Functie)
		,Technischtype = ELS.[omschrijving_technischtype]
		,Verhuurteam = ELS.[Verhuurteam]
		,Adres = ELS.[Adres]
	FROM cte_taak AS TAA
	LEFT OUTER JOIN cte_inspectie AS INS
		ON INS.[Maintenance Request No_] = TAA.Verzoek
	LEFT OUTER JOIN [empire_data].[dbo].[Staedion$DM___Inspection_Appointment] AS APP
		ON TAA.Verzoek = APP.[Maintenance Request No_] AND INS.[Line No_] = APP.[Line No_]
	LEFT OUTER JOIN [staedion_dm].[Medewerker].[TalentVisma] AS EMPINS
		ON APP.[Inspector Code] = EMPINS.Empire_wrkn
	LEFT OUTER JOIN [staedion_dm].[Medewerker].[TalentVisma] AS EMPMAN
		ON TAA.[Verzoek - ingevoerd door] = EMPMAN.Inlognaam
	LEFT OUTER JOIN staedion_dm.Dashboard.vw_Clusterlocatie AS LOC
		ON LOC.Clusternummer = TAA.[Verzoek - clusternummer]
	LEFT OUTER JOIN cte_els AS ELS
			ON ELS.Eenheidnr = TAA.[Verzoek - eenheidnr]

GO
