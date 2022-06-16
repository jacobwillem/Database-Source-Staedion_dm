SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Onderhoud].[vw_UrenGeboektInclInfoOrders TEST]

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = 
N'Dataset tbv onderhoudsafdeling, bedoeld om te kunnen analyseren hoe uren worden ingezet.
Basisset: Dataset Datum | Recource | Standaardtaak | Afrondcode vervolg | Onderhoudsorder
Attentiepunten:
* Uren vakmannen – aantal orders – afrondcodes
* Welke monteur heeft hoeveel bonnen gehad 
> gelijk af kunnen ronden
> aantallen ?
> vervolg 
> afrondcodes
> aantal orders taken + afrondcodes
> gaat meer aantallen
> later evt ook tijdsduur
'      ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoud'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_UrenGeboektInclInfoOrders TEST';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220421 JvdW, zie Topdesk 22 03 204


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
select sum([Aantal uren geboekt]) from Onderhoud.[vw_UrenGeboektInclInfoOrders TEST] where year(Boekdatum) = 2022
select sum(Quantity) from empire_Data.dbo.[Staedion$Job_Ledger_Entry] AS JLE where year([Posting Date]) = 2022 and [Ledger Entry Type] = 1

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
as 

		 WITH cte_info_onderhoudsorders
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
       LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR
              ON AFR.Afrondcode_id = TAAK.Afrondcode_id
       WHERE VERZ.[Huidig record] = 1
	   --AND SJAB.Code = 'AUT_DEUR_DR_DEFWMO'
       )
SELECT PP.Onderhoudsverzoek
       ,PP.[Onderhoudsorder/Projectnr]
       ,PP.Boekdatum
       ,RES.No_ AS [Resourcenr]
       ,concat(RES.No_,': ',RES.Naam,' (',RES.Functie,')') as [Medewerker incl functie]
       ,RES.Functie
       ,RES.Naam
       ,IMP.[Description] AS [Improductiviteitscode]
       ,sum(PP.Aantal) AS [Aantal uren geboekt]
       ,INFO.Reparatiesjabloon
       ,[Afrondcode taak]
			 ,INFO.[Standaard aantal uren]
			 ,staedion_dm.algemeen.fn_EmpireLink('Staedion', 11031240, 'No.='+PP.Onderhoudsverzoek+'','view' ) as Hyperlink
       ,getdate() AS gegenereerd
-- select sum(PP.Aantal)
FROM staedion_dm.Onderhoud.Projectposten AS PP
join cte_info_onderhoudsorders AS INFO
       ON PP.[Onderhoudsorder/Projectnr] = INFO.Onderhoudsorder
LEFT OUTER JOIN staedion_dm.onderhoud.[Resource] AS RES
       ON RES.Resource_id = PP.Resource_id
LEFT OUTER JOIN empire_data.dbo.[Staedion$Improductivity_Type] AS IMP
       ON IMP.[Code] = PP.[Onderhoudsorder/Projectnr]
WHERE year(PP.Boekdatum) >= 2022
       AND PP.Regelsoort = 'Uren'
--- and PP.Onderhoudsverzoek = @Nr
GROUP BY PP.Onderhoudsverzoek
       ,PP.[Onderhoudsorder/Projectnr]
       ,INFO.Onderhoudsorder
       ,PP.Boekdatum
       ,RES.No_
       ,RES.Functie
       ,RES.Naam
       ,INFO.Reparatiesjabloon
			 ,INFO.[Standaard aantal uren]
       ,[Afrondcode taak]
       ,IMP.[Description]
;
;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Dataset tbv onderhoudsafdeling, bedoeld om te kunnen analyseren hoe uren worden ingezet.
Basisset: Dataset Datum | Recource | Standaardtaak | Afrondcode vervolg | Onderhoudsorder
Attentiepunten:
* Uren vakmannen – aantal orders – afrondcodes
* Welke monteur heeft hoeveel bonnen gehad 
> gelijk af kunnen ronden
> aantallen ?
> vervolg 
> afrondcodes
> aantal orders taken + afrondcodes
> gaat meer aantallen
> later evt ook tijdsduur
', 'SCHEMA', N'Onderhoud', 'VIEW', N'vw_UrenGeboektInclInfoOrders TEST', NULL, NULL
GO
