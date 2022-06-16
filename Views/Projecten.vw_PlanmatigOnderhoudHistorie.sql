SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create VIEW [Projecten].[vw_PlanmatigOnderhoudHistorie]
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Tbv historisch overzicht IBIS-Main - gewenst overzicht mbt planmatig onderhoud.
Michiel van Coevorden: 
Aan te leveren rijen: vanaf 2008 mag ook, budgetregels planmatig mbt gevels, schilderen, dak (evt alles om generieker te maken)
Aan te leveren kolommen:
PLOH-projecten
Bepaalde werksoorten (leveren ze nog aan):
Schilderen
Gevel
Dak
Wat is er uitgevoerd in het verleden
Aan te leveren kolomm n
Werksoorten
Ft-nr (bouwblok zit niet in IBIS-main) – FINC omzetten naar FT
Realisatie vs begroting
Omschrijving
Leverancier
Zie datamart staedion_dm.Projecten
Zie Topdesk 22 04 598 Format rapportage uitgevoerd werk PLOH.xlsx'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Projecten'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_PlanmatigOnderhoudHistorie';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220303 JvdW aangemaakt

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
-- empire_dwh.[dbo].[dsp_rs_nieuwe_clusters]
with cte_clusters_hulp as 
	(select distinct clusternr_oud, clusternr
	from empire_staedion_data.data.dsp_rs_nieuwe_clusters_data 
	where dt_in_exploitatie <= getdate()
	and (dt_uit_exploitatie is null or dt_uit_exploitatie >=getdate())
	), cte_clusters as 
		(select	clusternr_oud,count(distinct clusternr) as aantal_unieke_ft, min(clusternr) as eerste_ft, max(clusternr) as laatste_ft, string_Agg(clusternr,';') as reeks_ft
		from	cte_clusters_hulp
		group by clusternr_oud
		)
	 , cte_basis as ( 
			SELECT BEDR.Bedrijf
				,P.Nr_ as Projectnr
				,P.Naam as Projectnaam
				,P.Omschrijving as Projectomschrijving
				,REA.[cluster] as [Cluster]
				,iif(REA.Cluster like 'FINC%', CTE.reeks_ft, REA.Cluster) as [Cluster nieuw]
				,REA.[Budgetregelnr_] as Budgetregelnr

				,WS.Werksoort
				,case when lower(WS.Omschrijving) like '%schild%' then 'Schilderwerk'
							when lower(WS.Omschrijving) like '%dak%' then 'Dakwerkzaamheden'
							when lower(WS.Omschrijving) like '%gevel%' then 'Gevelwerkzaamheden' 
							else 'Overig' end as [Classificatie werksoort]
				,WS.Omschrijving
				,REA.[Vendor No_] as [Leveranciersnr]
				,row_number() over (partition by REA.budget_id, REA.Budgetregelnr_ order by REA.Budgetregelnr_ asc) as Volgnr

				,LEV.[Name] as [Leveranciersnaam]
				,REA.[G_L Account No_] as Rekeningnr
				,(select convert(float,[Budget_incl_btw]) from staedion_dm.[Projecten].[Budget] as B where B.id = REA.budget_id and B.Budgetregelnr_ = REA.Budgetregelnr_) as [Budget_incl_btw]
				,convert(float,sum(REA.[Realisatie incl_ BTW])) as [Totaal realisatie incl BTW voor dit budgetnr]
				,count(distinct REA.[Document No_]) as [Aantal facturen]
				,max(REA.[Boekdatum]) as [Meest recente boekdatum voor dit budgetnr]
				,getdate() as Gegenereerd

			--	,Rekeningnr = REA.[G_L Account No_]
			--	,[Realisatie excl BTW] = REA.[Realisatie excl_ BTW]
			--	,[Rekeningnr en naam] = Coalesce(REA.[G_L Account No_], '') + ' ' + [GA].[Name]
			--	,REA.[Resource No_]
			--	,REA.[Item No_]
			--	,[Volgnr Empire projectpost] = REA.[Job Ledger Entry No_]
			--	,REA.[Werksoort_id]
			--	,REA.[project_id]
			--	,REA.[Budget_id]

			-- select distinct P.*
			-- select count(*),convert(float,sum(REA.[Realisatie incl_ BTW]))

			FROM staedion_dm.projecten.Realisatie AS REA 
			LEFT OUTER JOIN empire_data.dbo.Staedion$G_L_Account AS GA ON GA.No_ = REA.[G_L Account No_]
			left outer join empire_data.dbo.Vendor as LEV on LEV.No_ = REA.[Vendor No_]
			left outer join staedion_dm.projecten.Project as P on P.id = REA.[project_id]
			left outer join staedion_dm.projecten.Werksoort as WS on WS.id = REA.[Werksoort_id]
			left outer join staedion_dm.algemeen.bedrijven as BEDR on BEDR.bedrijf_id = REA.bedrijf_id
			left outer join cte_clusters as CTE on CTE.clusternr_oud = REA.[cluster] --and CTE.volgnr = 1
			--where lower(WS.Omschrijving) like  '%schild%'
			--or lower(WS.Omschrijving) like  '%dak%'
			--or lower(WS.Omschrijving) like  '%gevel%'
			where P.Nr_ like 'POCO%' or P.Nr_ like 'PLOH%'
			group by  BEDR.Bedrijf
				,P.Nr_ 
				,P.Naam 
				,P.Omschrijving 
				,REA.[cluster]
				,REA.[Budgetregelnr_] 
				,WS.Werksoort
				,case when lower(WS.Omschrijving) like '%schild%' then 'Schilderwerk'
							when lower(WS.Omschrijving) like '%dak%' then 'Dakwerkzaamheden'
							when lower(WS.Omschrijving) like '%gevel%' then 'Gevelwerkzaamheden' 
							else 'Overig' end
				,WS.Omschrijving
				,REA.[Vendor No_] 
				,LEV.[Name] 
				,REA.[G_L Account No_] 
				,iif(REA.Cluster like 'FINC%', CTE.reeks_ft, REA.Cluster)
				,REA.budget_id
				)

				select	Bedrijf
						,Projectnr
						,Projectnaam
						,Projectomschrijving
						,[Cluster]
						,[Cluster nieuw]
						,Budgetregelnr
						,Werksoort
						,[Classificatie werksoort]
						,Omschrijving
						,[Leveranciersnr]
						,Volgnr

						,[Leveranciersnaam]
						,Rekeningnr
						,iif(Volgnr=1, [Budget_incl_btw],null) as [Budget_incl_btw]
						,[Totaal realisatie incl BTW voor dit budgetnr]
						,[Aantal facturen]
						,[Meest recente boekdatum voor dit budgetnr]
						,Gegenereerd
				from cte_basis



GO
EXEC sp_addextendedproperty N'MS_Description', N'Tbv historisch overzicht IBIS-Main - gewenst overzicht mbt planmatig onderhoud.
Michiel van Coevorden: 
Aan te leveren rijen: vanaf 2008 mag ook, budgetregels planmatig mbt gevels, schilderen, dak (evt alles om generieker te maken)
Aan te leveren kolommen:
PLOH-projecten
Bepaalde werksoorten (leveren ze nog aan):
Schilderen
Gevel
Dak
Wat is er uitgevoerd in het verleden
Aan te leveren kolomm n
Werksoorten
Ft-nr (bouwblok zit niet in IBIS-main) – FINC omzetten naar FT
Realisatie vs begroting
Omschrijving
Leverancier
Zie datamart staedion_dm.Projecten
Zie Topdesk 22 04 598 Format rapportage uitgevoerd werk PLOH.xlsx', 'SCHEMA', N'Projecten', 'VIEW', N'vw_PlanmatigOnderhoudHistorie', NULL, NULL
GO
