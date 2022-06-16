SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Onderhoud].[vw_OnderhoudsverzoekenAfrondcodes TEST]

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = 
N'....
'      ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoud'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_OnderhoudsverzoekenHuismeesters';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220421 JvdW, zie Topdesk 21 10 630


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


SELECT			VERZ.Onderhoudsverzoek as Verzoek
				,VERZ.[Omschrijving] as  [Verzoek - omschrijving]
				,VS.Onderhoudsverzoekstatus as [Verzoek - status]
				,VERZ.Melddatum as [Verzoek - datum invoer]
				,VERZ.[Ingevoerd door] as [Verzoek - ingevoerd door]

				,ORD.Onderhoudsorder as [Order]
				,ORD.[Datum technisch gereed]
				,OS.Orderstatus
				,ORD.[Datum gegund] as [Order - gunningsdatum]
				,OS.Orderstatus as [Order - status]
				,ORD.[Afspraakdatum]
				,ORD.[Vroegste startdatum]
				,UR.Urgentiecode as [Order - urgentiecode]
				,ORD.Leveranciernr as [Order - leverancier]

				,COALESCE(ORD.Leveranciernr, TAAK.Leveranciernr) AS Leveranciernr

				,TAAK.[Taak nr] as [Taak]
				,TAAK.Onderhoudstaak
				,TS.Onderhoudstaakstatus
				,SJAB.Reparatiesjabloon
				,SJAB.Code AS Sjablooncode
				,TAAK.Omschrijving
				,AFR_t.Afrondcode AS [Afrondcode taak]
				,AFR_o.Afrondcode as [Afrondcode order]
				,TAAK.Aanmaakdatum
				,TAAK.[Geldig van]
				,TAAK.[Geldig tot]
				,TAAK.[Standaard aantal uren]

				,VERZ.Clusternr as [Verzoek - clusternummer]
				,[Clusternaam] = (SELECT [naam] FROM empire_Data.dbo.staedion$cluster WHERE nr_ = VERZ.Clusternr)
				,VERZ.Eenheidnr as [Verzoek - eenheidnr]
				--,[Verzoek - locatie] = IIF(REQ.[Common Area] = 1,[Type Description], [Address])
				,[Verzoek - locatie] = IIF(VERZ.[Collectief object_id] is null, EIG.[Eenheid + adres],COLL.[Omschrijving])
				,KC.Kostencode as [Taak - kostencode]
				,'<a href="'+staedion_dm.Algemeen.fn_EmpireLink('Staedion', 11031240, 'No.='+VERZ.Onderhoudsverzoek +'', 'view')+'">'+VERZ.Onderhoudsverzoek +'</a>' AS [Verzoek - Hyperlink]
				,AR.Afwijsreden as [Verzoek - Redencode afgewezen]

				-- select distinct ORD.Leveranciernr
       FROM staedion_dm.Onderhoud.Onderhoudsverzoek AS VERZ
       LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsverzoekstatus AS VS
              ON VS.Onderhoudsverzoekstatus_id = VERZ.Onderhoudsverzoekstatus_id
       LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudstaak AS TAAK
              ON TAAK.Onderhoudsverzoek = VERZ.Onderhoudsverzoek
                     AND TAAK.[Geldig tot] IS NULL
       LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudstaakstatus AS TS
              ON TS.Onderhoudstaakstatus_id = TAAK.Onderhoudstaakstatus_id
       LEFT OUTER JOIN staedion_dm.Onderhoud.Reparatiesjabloon AS SJAB
              ON SJAB.Reparatiesjabloon_id = TAAK.Reparatiesjabloon_id
       LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsorder AS ORD
              ON ORD.Onderhoudsorder = TAAK.Onderhoudsorder
                     AND ORD.[Huidig record] = 1
       LEFT OUTER JOIN staedion_dm.onderhoud.Orderstatus AS OS
              ON OS.Orderstatus_id = ORD.Orderstatus_id
       LEFT OUTER JOIN staedion_dm.onderhoud.Urgentie AS UR
              ON UR.Urgentie_id = ORD.Urgentie_id
       LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR_t
              ON AFR_t.Afrondcode_id = TAAK.Afrondcode_id
       LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR_o
              ON AFR_o.Afrondcode_id = ORD.Afrondcode_id

       LEFT OUTER JOIN staedion_dm.onderhoud.Kostencode AS KC
              ON TAAK.Kostencode_id = KC.Kostencode_id
       LEFT OUTER JOIN staedion_dm.onderhoud.Afwijsreden AS AR
              ON AR.Afwijsreden_id = VERZ.Afwijsreden_id
       LEFT OUTER JOIN staedion_dm.Eenheden.[Collectieve objecten] AS COLL
              ON COLL.[Collectief object_id] = VERZ.[Collectief object_id]
       LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG
              ON EIG.Eenheidnr = VERZ.Eenheidnr
			  and EIG.Einddatum is null
       WHERE VERZ.[Huidig record] = 1
	   and ORD.Leveranciernr <> 'LEVE-02164' 
	   --or	(VS.Onderhoudsverzoekstatus not in ('Afgehandeld', 'Geannuleerd')
				--and	VERZ.[Collectief object_id] is not null
				and VERZ.Melddatum >= '20220101'
	   



GO
