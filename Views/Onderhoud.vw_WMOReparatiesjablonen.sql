SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Onderhoud].[vw_WMOReparatiesjablonen]

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = 
N'Maakt inzichtelijk hoeveel onderhoudsorders er zijn aangemaakt op een bepaald WMO reparatiesjabloon.
Sinds 2021 (wellicht al eerder) komt WMO reparatiesjabloon AUT_DEUR_DR_DEFWMO ten laste van de gewone reparatiekosten.
Afhankelijk van bepaalde voorwaarden (TN-nummer op factuur moet dan verwijzen naar WMO-registratie bij de gemeente), kunnen deze kosten worden doorberekend.
Om inzichtelijk te maken hoe vaak dat wel / niet gebeurt, is deze view opgesteld tbv Power BI rapportage WMO
BRON: view is gebaseerd op datamart staedion_dm.onderhoud
'      ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoud'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_WMOReparatiesjablonen';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220421 JvdW, zie Topdesk 22 03 204

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
as 
WITH cte_sjabloon_wmo
AS (
	SELECT 'AUT_DEUR_DR_DEFWMO' AS WOM_Sjabloon
	)
	,cte_info_onderhoudsorders
AS (
	SELECT VERZ.Onderhoudsverzoek
		,VS.Onderhoudsverzoekstatus
		,ORD.Onderhoudsorder
		,OS.Orderstatus
		,TAAK.Onderhoudstaak
		,TAAK.[Taak nr]
		,TS.Onderhoudstaakstatus
		,SJAB.Reparatiesjabloon
		,SJAB.Code AS Sjablooncode
		,ORD.[Datum technisch gereed]
		,COALESCE(ORD.Leveranciernr, TAAK.Leveranciernr) AS Leveranciernr
		,TAAK.Omschrijving
		,AFR.Afrondcode AS [Afrondcode taak]
		,TAAK.Aanmaakdatum
		,TAAK.[Geldig van]
		,TAAK.[Geldig tot]
		,TAAK.[Standaard aantal uren]
		,TAAK.[Huurder akkoord met kosten]
		,TAAK.[Doorbelasten aan]
		,TAAK.[Doorbelasten aan klantnr]
		,KC.Kostencode
	FROM staedion_dm.Onderhoud.Onderhoudsverzoek AS VERZ
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsverzoekstatus AS VS ON VS.Onderhoudsverzoekstatus_id = VERZ.Onderhoudsverzoekstatus_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudstaak AS TAAK ON TAAK.Onderhoudsverzoek = VERZ.Onderhoudsverzoek
		AND TAAK.[Geldig tot] IS NULL
	LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudstaakstatus AS TS ON TS.Onderhoudstaakstatus_id = TAAK.Onderhoudstaakstatus_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Reparatiesjabloon AS SJAB ON SJAB.Reparatiesjabloon_id = TAAK.Reparatiesjabloon_id
	LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsorder AS ORD ON ORD.Onderhoudsorder = TAAK.Onderhoudsorder
		AND ORD.[Huidig record] = 1
	LEFT OUTER JOIN staedion_dm.Onderhoud.Kostencode AS KC ON ORD.Kostencode_id = KC.Kostencode_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Orderstatus AS OS ON OS.Orderstatus_id = ORD.Orderstatus_id
	LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR ON AFR.Afrondcode_id = TAAK.Afrondcode_id
	WHERE VERZ.[Huidig record] = 1
		AND VERZ.Onderhoudsverzoek IN (
			SELECT VERZ.Onderhoudsverzoek
			FROM staedion_dm.Onderhoud.Onderhoudsverzoek AS VERZ
			LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudstaak AS TAAK ON TAAK.Onderhoudsverzoek = VERZ.Onderhoudsverzoek
				AND TAAK.[Geldig tot] IS NULL
			LEFT OUTER JOIN staedion_dm.Onderhoud.Reparatiesjabloon AS SJAB ON SJAB.Reparatiesjabloon_id = TAAK.Reparatiesjabloon_id
			WHERE SJAB.Code IN (
					SELECT WOM_Sjabloon
					FROM cte_sjabloon_wmo
					)
			)
	)
SELECT AlleRegels.Onderhoudsverzoek
	,AlleRegels.[Onderhoudsorder/Projectnr]
	,max(AlleRegels.Boekdatum) AS Boekdatum
	,sum(AlleRegels.[Aantal uren geboekt]) AS [Aantal uren geboekt]
	,sum(AlleRegels.[Kosten]) AS Kosten
	,sum(AlleRegels.Opbrengst) AS Opbrengst
	,string_agg(AlleRegels.Boekstuknr, ';') AS Boekstuknrs
	,max(AlleRegels.[Huurder akkoord met kosten]) AS [Huurder akkoord met kosten]
	,max(AlleRegels.[Doorbelasten aan]) AS [Doorbelasten aan]
	,max(AlleRegels.[Doorbelasten aan klantnr]) AS [Doorbelasten aan klantnr]
	,AlleRegels.Kostencode
	,AlleRegels.Reparatiesjabloon
	,AlleRegels.Sjablooncode
	,CASE 
		WHEN AlleRegels.Sjablooncode IN (
				SELECT WOM_Sjabloon
				FROM cte_sjabloon_wmo
				)
			Then sum(AlleRegels.Opbrengst) + sum(AlleRegels.Kosten)
		ELSE 0
		END AS [Saldo WMO-kosten reparatie]
	,CASE 
		WHEN AlleRegels.Sjablooncode IN (
				SELECT WOM_Sjabloon
				FROM cte_sjabloon_wmo
				)
			AND sum(AlleRegels.Opbrengst) < 0
			THEN 1
		ELSE 0
		END AS [Teller Doorberekend]
	,CASE 
		WHEN AlleRegels.Sjablooncode IN (
				SELECT WOM_Sjabloon
				FROM cte_sjabloon_wmo
				)
			AND sum(AlleRegels.Kosten) > 0
			THEN 1
		ELSE 0
		END AS [Teller WMO reparatie]

		--"<a href=""""DynamicsNAV://s-emp17-as2.staedion.local:7146/EMP17_02_01/Staedion/runpage?page=11024012&$filter='Soort'%20IS%201%20AND%20'Eenheidnr.'%20IS%20OGEH-0001143&mode=view"""">OGEH-0001143</a>""
		--,'<a href="'
		--	+staedion_dm.algemeen.fn_EmpireLink('Staedion', 11031470, 'No.=' 
		--			+ AlleRegels.[Onderhoudsorder/Projectnr] 
		--			+ '', 'view') 
		--			+ '">'+ AlleRegels.[Onderhoudsorder/Projectnr] 
		--			+ '</a>'				
		--			AS HyperlinkEmpire -- onderhoudsorder
		,'<a href="'
			+staedion_dm.algemeen.fn_EmpireLink('Staedion', 11031240, 'No.=' 
					+ AlleRegels.Onderhoudsverzoek 
					+ '', 'view') 
					+ '">'+ AlleRegels.Onderhoudsverzoek 
					+ '</a>'				
					AS HyperlinkEmpire
	,iif(len(string_agg(AlleRegels.Boekstuknr, ';'))> 1
				,'https://staedion.xtendis.nl/web/weblauncher.aspx?archiefnaam=Centraal&Doc_Leveranciernummer='
				+ left(string_agg(AlleRegels.[Leveranciernr], ';'),10) 
				+ '&Interne referentie='
				+ left(string_agg(AlleRegels.Boekstuknr, ';'),13)
				,null) as HyperlinkFactuur
	,getdate() AS gegenereerd
-- NB: om distinct Boekstuknrs op te halen - kan dit handiger ?					
FROM (
	SELECT PP.Onderhoudsverzoek
		,PP.[Onderhoudsorder/Projectnr]
		,max(PP.Boekdatum) AS Boekdatum
		,sum(PP.Aantal) AS [Aantal uren geboekt]
		,sum(iif(PP.Gebruiksoort = 'Gebruik', PP.[Totale kosten], 0)) AS Kosten
		,sum(iif(PP.Gebruiksoort = 'Verkoop', PP.Totaalprijs, 0)) AS Opbrengst
		,PP.Boekstuknr
		,INFO.Reparatiesjabloon
		,INFO.Sjablooncode
		,INFO.[Doorbelasten aan]
		,INFO.Kostencode
		,max(INFO.[Leveranciernr]) AS [Leveranciernr]
		,max(INFO.[Huurder akkoord met kosten]) AS [Huurder akkoord met kosten]
		,max(INFO.[Doorbelasten aan klantnr]) AS [Doorbelasten aan klantnr]
	FROM staedion_dm.Onderhoud.Projectposten AS PP
	JOIN cte_info_onderhoudsorders AS INFO ON PP.[Onderhoudsorder/Projectnr] = INFO.Onderhoudsorder
	LEFT OUTER JOIN staedion_dm.onderhoud.[Resource] AS RES ON RES.Resource_id = PP.Resource_id
	LEFT OUTER JOIN empire_data.dbo.[Staedion$Improductivity_Type] AS IMP ON IMP.[Code] = PP.[Onderhoudsorder/Projectnr]
	WHERE 1 = 1 --year(PP.Boekdatum) >= 2022
		--- and PP.Onderhoudsverzoek = @Nr
	GROUP BY PP.Onderhoudsverzoek
		,PP.[Onderhoudsorder/Projectnr]
		,INFO.Reparatiesjabloon
		,INFO.Sjablooncode
		,PP.Boekstuknr
		,INFO.Kostencode
		,INFO.[Doorbelasten aan]
	) AS AlleRegels
GROUP BY AlleRegels.Onderhoudsverzoek
	,AlleRegels.[Onderhoudsorder/Projectnr]
	,AlleRegels.Reparatiesjabloon
	,AlleRegels.Sjablooncode
	,AlleRegels.[Doorbelasten aan]
	,AlleRegels.Kostencode

GO
EXEC sp_addextendedproperty N'MS_Description', N'Maakt inzichtelijk hoeveel onderhoudsorders er zijn aangemaakt op een bepaald WMO reparatiesjabloon.
Sinds 2021 (wellicht al eerder) komt WMO reparatiesjabloon AUT_DEUR_DR_DEFWMO ten laste van de gewone reparatiekosten.
Afhankelijk van bepaalde voorwaarden (TN-nummer op factuur moet dan verwijzen naar WMO-registratie bij de gemeente), kunnen deze kosten worden doorberekend.
Om inzichtelijk te maken hoe vaak dat wel / niet gebeurt, is deze view opgesteld tbv Power BI rapportage WMO
BRON: view is gebaseerd op datamart staedion_dm.onderhoud
', 'SCHEMA', N'Onderhoud', 'VIEW', N'vw_WMOReparatiesjablonen', NULL, NULL
GO
