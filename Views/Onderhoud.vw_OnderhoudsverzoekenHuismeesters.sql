SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Onderhoud].[vw_OnderhoudsverzoekenHuismeesters]

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = 
N'Overzicht tbv huismeesters van reparatieverzoeken door hen aangemaakt aangevuld met openstaande reparatieverzoeken van bewoners 
op collectieve objecten
ZIE: Topdesk 21 10 630 Jeroen van der Heijde
'      ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoud'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_OnderhoudsverzoekenHuismeesters';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220421 JvdW, zie Topdesk 21 10 630 - In 1 query kreeg ik de performance niet goed - nu maar even opgelost door een union te maken 


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
select count(*) from onderhoud.vw_OnderhoudsverzoekenHuismeesters
select * from onderhoud.vw_OnderhoudsverzoekenHuismeesters where nullif([Verzoek - eenheidnr],'') is not null
--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
as 

WITH cte_huismeesters
AS (
	SELECT inlognaam
		,[Volledige naam]
		,[Functie]
	FROM empire_Staedion_data.visma.werknemers
	WHERE Functie = 'huismeester'
	)
	,cte_info_onderhoudsorders
AS (
	SELECT VERZ.Onderhoudsverzoek AS Verzoek
		,VERZ.[Omschrijving] AS [Verzoek - omschrijving]
		,VS.Onderhoudsverzoekstatus AS [Verzoek - status]
		,VERZ.Melddatum AS [Verzoek - datum invoer]
		,VERZ.[Ingevoerd door] AS [Verzoek - ingevoerd door]
		,ORD.Onderhoudsorder AS [Order]
		,ORD.[Datum technisch gereed]
		,OS.Orderstatus
		,ORD.[Datum gegund] AS [Order - gunningsdatum]
		,OS.Orderstatus AS [Order - status]
		,ORD.[Afspraakdatum]
		,ORD.[Vroegste startdatum]
		,UR.Urgentiecode AS [Order - urgentiecode]
		,ORD.Leveranciernr AS [Order - leverancier]
		,COALESCE(ORD.Leveranciernr, TAAK.Leveranciernr) AS Leveranciernr
		,TAAK.[Taak nr] AS [Taak]
		,TAAK.Onderhoudstaak
		,TS.Onderhoudstaakstatus
		,SJAB.Reparatiesjabloon
		,SJAB.Code AS Sjablooncode
		,TAAK.Omschrijving
		,AFR.Afrondcode AS [Afrondcode taak]
		,TAAK.Aanmaakdatum
		,TAAK.[Geldig van]
		,TAAK.[Geldig tot]
		,TAAK.[Standaard aantal uren]
		,VERZ.Clusternr AS [Verzoek - clusternummer]
		--,[Clusternaam] = (
		--	SELECT [naam]
		--	FROM empire_Data.dbo.staedion$cluster
		--	WHERE nr_ = VERZ.Clusternr
		--	)
		,VERZ.Eenheidnr AS [Verzoek - eenheidnr]
		--,[Verzoek - locatie] = IIF(REQ.[Common Area] = 1,[Type Description], [Address])
		,[Verzoek - locatie] = IIF(VERZ.[Collectief object_id] IS NULL, EIG.[Eenheid + adres], COLL.[Collectief object] + ' ' + COLL.Omschrijving)
		,KC.Kostencode AS [Taak - kostencode]
		,'<a href="' + staedion_dm.Algemeen.fn_EmpireLink('Staedion', 11031240, 'No.=' + VERZ.Onderhoudsverzoek + '', 'view') + '">' + VERZ.Onderhoudsverzoek + '</a>' AS [Verzoek - Hyperlink]
		,AR.Afwijsreden AS [Verzoek - Redencode afgewezen]
		--,NULL AS Notitie
		,NOT_V.Notities as Notitie
		,CASE 
			WHEN VERZ.[Ingevoerd door] IN (
					SELECT inlognaam
					FROM cte_huismeesters
					)
				THEN 'Onderhoudsverzoek opgevoerd door huismeester'
			ELSE 'Onderhoudsverzoek op collectief object'
			END AS [Herkomst onderhoudsverzoek]
	FROM staedion_dm.Onderhoud.Onderhoudsverzoek AS VERZ
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsverzoekstatus AS VS ON VS.Onderhoudsverzoekstatus_id = VERZ.Onderhoudsverzoekstatus_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudstaak AS TAAK ON TAAK.Onderhoudsverzoek_id = VERZ.Onderhoudsverzoek_id
		AND TAAK.[Geldig tot] IS NULL
	 LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudsverzoeknotities as NOT_V
		on NOT_V.Onderhoudsverzoek_id = VERZ.Onderhoudsverzoek_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudstaakstatus AS TS ON TS.Onderhoudstaakstatus_id = TAAK.Onderhoudstaakstatus_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Reparatiesjabloon AS SJAB ON SJAB.Reparatiesjabloon_id = TAAK.Reparatiesjabloon_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsorder AS ORD ON ORD.Onderhoudsorder_id = TAAK.Onderhoudsorder_id
		AND ORD.[Huidig record] = 1
	LEFT OUTER JOIN staedion_dm.onderhoud.Orderstatus AS OS ON OS.Orderstatus_id = ORD.Orderstatus_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Urgentie AS UR ON UR.Urgentie_id = ORD.Urgentie_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR ON AFR.Afrondcode_id = TAAK.Afrondcode_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Kostencode AS KC ON TAAK.Kostencode_id = KC.Kostencode_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Afwijsreden AS AR ON AR.Afwijsreden_id = VERZ.Afwijsreden_id
	LEFT OUTER JOIN staedion_dm.Eenheden.[Collectieve objecten] AS COLL ON COLL.[Collectief object_id] = VERZ.[Collectief object_id]
		AND COLL.[Einddatum] is null
	LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG ON EIG.Eenheidnr = VERZ.Eenheidnr
		AND EIG.[Einddatum] IS NULL
	WHERE VERZ.[Huidig record] = 1
		AND (
			(
				VERZ.[Ingevoerd door] IN (
					SELECT inlognaam
					FROM cte_huismeesters
					)
				)
			--NB: werkt enorm vertragend
			--OR (
			--	VS.Onderhoudsverzoekstatus NOT IN (
			--		'Afgehandeld'
			--		,'Geannuleerd'
			--		)
			--	AND VERZ.[Collectief object_id] IS NOT NULL
			--	AND VERZ.Melddatum >= '20220101'
			--	)
			)
	)
SELECT	 Verzoek
		,[Verzoek - omschrijving]
		,[Verzoek - status]
		,[Verzoek - datum invoer]
		,[Verzoek - ingevoerd door]
		,[Order]
		,[Datum technisch gereed]
		,Orderstatus
		,[Order - gunningsdatum]
		,[Order - status]
		,[Afspraakdatum]
		,[Vroegste startdatum]
		,[Order - urgentiecode]
		,[Order - leverancier]
		,Leveranciernr
		,[Taak]
		,Onderhoudstaak
		,Onderhoudstaakstatus
		,Reparatiesjabloon
		,Sjablooncode
		,Omschrijving
		,[Afrondcode taak]
		,Aanmaakdatum
		,[Geldig van]
		,[Geldig tot]
		,[Standaard aantal uren]
		,[Verzoek - clusternummer]
		,[Clusternaam] = (
			SELECT [naam]
			FROM empire_Data.dbo.staedion$cluster
			WHERE nr_ = [Verzoek - clusternummer]
			)
		,[Verzoek - eenheidnr]
		,[Verzoek - locatie] 
		,[Taak - kostencode]
		,[Verzoek - Hyperlink]
		,[Verzoek - Redencode afgewezen]
		--,NULL AS Notitie
		,Notitie
		,[Herkomst onderhoudsverzoek]
FROM cte_info_onderhoudsorders

UNION

SELECT	VERZ.Onderhoudsverzoek AS Verzoek
		,VERZ.[Omschrijving] AS [Verzoek - omschrijving]
		,VS.Onderhoudsverzoekstatus AS [Verzoek - status]
		,VERZ.Melddatum AS [Verzoek - datum invoer]
		,VERZ.[Ingevoerd door] AS [Verzoek - ingevoerd door]
		,ORD.Onderhoudsorder AS [Order]
		,ORD.[Datum technisch gereed]
		,OS.Orderstatus
		,ORD.[Datum gegund] AS [Order - gunningsdatum]
		,OS.Orderstatus AS [Order - status]
		,ORD.[Afspraakdatum]
		,ORD.[Vroegste startdatum]
		,UR.Urgentiecode AS [Order - urgentiecode]
		,ORD.Leveranciernr AS [Order - leverancier]
		,COALESCE(ORD.Leveranciernr, TAAK.Leveranciernr) AS Leveranciernr
		,TAAK.[Taak nr] AS [Taak]
		,TAAK.Onderhoudstaak
		,TS.Onderhoudstaakstatus
		,SJAB.Reparatiesjabloon
		,SJAB.Code AS Sjablooncode
		,TAAK.Omschrijving
		,AFR.Afrondcode AS [Afrondcode taak]
		,TAAK.Aanmaakdatum
		,TAAK.[Geldig van]
		,TAAK.[Geldig tot]
		,TAAK.[Standaard aantal uren]
		,VERZ.Clusternr AS [Verzoek - clusternummer]
		,[Clusternaam] = (
			SELECT [naam]
			FROM empire_Data.dbo.staedion$cluster
			WHERE nr_ = VERZ.Clusternr
			)
		,VERZ.Eenheidnr AS [Verzoek - eenheidnr]
		--,[Verzoek - locatie] = IIF(REQ.[Common Area] = 1,[Type Description], [Address])
		,[Verzoek - locatie] = IIF(VERZ.[Collectief object_id] IS NULL, EIG.[Eenheid + adres], COLL.[Collectief object] + ' ' + COLL.Omschrijving)
		,KC.Kostencode AS [Taak - kostencode]
		,'<a href="' + staedion_dm.Algemeen.fn_EmpireLink('Staedion', 11031240, 'No.=' + VERZ.Onderhoudsverzoek + '', 'view') + '">' + VERZ.Onderhoudsverzoek + '</a>' AS [Verzoek - Hyperlink]
		,AR.Afwijsreden AS [Verzoek - Redencode afgewezen]
		,NULL AS Notitie
		--				,NOT_V.Notities as Notitie
		,CASE 
			WHEN VERZ.[Ingevoerd door] IN (
					SELECT inlognaam
					FROM cte_huismeesters
					)
				THEN 'Onderhoudsverzoek opgevoerd door huismeester'
			ELSE 'Onderhoudsverzoek op collectief object'
			END AS [Herkomst onderhoudsverzoek]
FROM staedion_dm.Onderhoud.Onderhoudsverzoek AS VERZ
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsverzoekstatus AS VS ON VS.Onderhoudsverzoekstatus_id = VERZ.Onderhoudsverzoekstatus_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudstaak AS TAAK ON TAAK.Onderhoudsverzoek_id = VERZ.Onderhoudsverzoek_id
		AND TAAK.[Geldig tot] IS NULL
	--	   LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudsverzoeknotities as NOT_V
	--			on NOT_V.Onderhoudsverzoek_id = VERZ.Onderhoudsverzoek_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudstaakstatus AS TS ON TS.Onderhoudstaakstatus_id = TAAK.Onderhoudstaakstatus_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Reparatiesjabloon AS SJAB ON SJAB.Reparatiesjabloon_id = TAAK.Reparatiesjabloon_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsorder AS ORD ON ORD.Onderhoudsorder_id = TAAK.Onderhoudsorder_id
		AND ORD.[Huidig record] = 1
	LEFT OUTER JOIN staedion_dm.onderhoud.Orderstatus AS OS ON OS.Orderstatus_id = ORD.Orderstatus_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Urgentie AS UR ON UR.Urgentie_id = ORD.Urgentie_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR ON AFR.Afrondcode_id = TAAK.Afrondcode_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Kostencode AS KC ON TAAK.Kostencode_id = KC.Kostencode_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Afwijsreden AS AR ON AR.Afwijsreden_id = VERZ.Afwijsreden_id
	LEFT OUTER JOIN staedion_dm.Eenheden.[Collectieve objecten] AS COLL ON COLL.[Collectief object_id] = VERZ.[Collectief object_id]
		AND COLL.[Einddatum] is null
	LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG ON EIG.Eenheidnr = VERZ.Eenheidnr
		AND EIG.[Einddatum] IS NULL
	WHERE VERZ.[Huidig record] = 1
		AND (
				VS.Onderhoudsverzoekstatus NOT IN (
					'Afgehandeld'
					,'Geannuleerd'
					)
				AND VERZ.[Collectief object_id] IS NOT NULL
				AND VERZ.Melddatum >= '20220101'
				)

GO
EXEC sp_addextendedproperty N'MS_Description', N'Overzicht tbv huismeesters van reparatieverzoeken door hen aangemaakt aangevuld met openstaande reparatieverzoeken van bewoners 
op collectieve objecten
ZIE: Topdesk 21 10 630 Jeroen van der Heijde
', 'SCHEMA', N'Onderhoud', 'VIEW', N'vw_OnderhoudsverzoekenHuismeesters', NULL, NULL
GO
