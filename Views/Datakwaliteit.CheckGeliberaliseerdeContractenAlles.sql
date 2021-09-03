SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Datakwaliteit].[CheckGeliberaliseerdeContractenAlles]
AS
/*
-- https://jnwadvocaten.nl/artikelen/geliberaliseerde-huur-wanneer-is-een-aanbod-redelijk/
-- https://www.rijksoverheid.nl/onderwerpen/woning-huren/vraag-en-antwoord/woon-ik-in-een-sociale-huurwoning-of-niet
-- https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/toeslagen/huurtoeslag/uw-inkomen-is-niet-te-hoog-voor-de-huurtoeslag/
-- Mail Marieke 4-1-2021
Toch nog een vraagje over het Excel-bestand (had het mailtje al sinds vanochtend klaar staan, maar nog niet verzonden…)
Bij alle adressen is de Indexcode contractregel leeg; ik vermoed omdat je die indexcode ‘zoekt’ op de eerste contractregel? (waar ook de kale huur en libgrens op zijn gebaseerd)
Is het mogelijk die Indexcode van de meest recente contractregel af/uit te lezen en aan die Detail-regel toe te voegen? 
Die ONB-codering is nl. t.t.v. de inventarisatie ingevoerd, waardoor die code niet op de eerste contractregel staat.


SELECT 	CASE WHEN Ingangsdatum < '19940701' THEN 'Geen controle nodig - gezien ingangsdatum sociaal contract'	-- select top 10 *
			ELSE CASE WHEN [Kalehuur ingangsdatum] = 0 
				THEN 'Kalehuur niet bekend ten tijde van ingangsdatum huurcontract'
				ELSE CASE WHEN iif([Kalehuur ingangsdatum] > [Grenswaarde liberalisatie],1,0) = [Geliberaliseerd] THEN 'In overeenstemming' 
				ELSE 'Afwijkend' END END END
		,count(*)
from [Datakwaliteit].[CheckGeliberaliseerdeContracten]
GROUP BY CASE WHEN Ingangsdatum <= '19940101' THEN 'Geen controle nodig - gezien ingangsdatum sociaal contract'	-- select top 10 *
			ELSE CASE WHEN [Kalehuur ingangsdatum] = 0 
				THEN 'Kalehuur niet bekend ten tijde van ingangsdatum huurcontract'
				ELSE CASE WHEN iif([Kalehuur ingangsdatum] > [Grenswaarde liberalisatie],1,0) = [Geliberaliseerd] THEN 'In overeenstemming' 
				ELSE 'Afwijkend' END END END





*/
WITH cte_geliberaliseerd
AS (
       SELECT Eenheidnr_
              ,[Customer No_]
			  ,Ingangsdatum
              ,Huurprijsliberalisatie
              ,Volgnr = row_number() OVER (
                     PARTITION BY Eenheidnr_,[Customer No_] ORDER BY Ingangsdatum ASC
                     )
       FROM empire_Data.dbo.Staedion$Contract AS C
       WHERE [Dummy Contract] = 0
	   --AND Huurprijsliberalisatie = 1
	   --AND Eenheidnr_ = 'OGEH-0005220'
       ), cte_ONB AS 
  (       SELECT Eenheidnr_
              ,[Indexcode]
              ,Volgnr = row_number() OVER (
                     PARTITION BY Eenheidnr_ ORDER BY Ingangsdatum asc
                     )
       FROM empire_Data.dbo.Staedion$Contract AS C
       WHERE [Dummy Contract] = 0
       AND C.[Indexcode] = 'ONB')



       ,cte_grenzen
AS (   SELECT geliberaliseerd
              ,minimum
              ,maximum
              ,vanaf
              ,tot
	    -- select min(vanaf), max(tot), datediff(d,min(vanaf), max(tot)),sum(datediff(d,vanaf,tot)+1) -- check of er dubbele dagen in zitten of dagen ontbreken
	   FROM staedion_dm.[Parameters].HuurgrenzenLiberalisatie

       )
SELECT Eenheidnr = BRON.Nr_
       --CLUS.Clusternr, 
       --CLUS.Clusternaam, 
       --Assetmanager = coalesce(CONT.Assetmanager, 'Onbekend')
       ,[Huurder] = coalesce(HRD.huurder1, 'Leegstand')
       ,[Kalehuur] = coalesce(HPR.kalehuur, 0)
       ,[Korting] = coalesce(HPR.nettohuur_incl_korting_btw, 0)
	   ,[Soort eenheid (corpodata)] = TT.[Analysis Group Code]
       ,[Type eenheid] = TT.Omschrijving
       ,CONTR.Ingangsdatum
       ,CONTR.Einddatum
       ,[Kalehuur ingangsdatum] = coalesce(HPR.kalehuur, 0)
	   ,[Geliberaliseerd] = coalesce(LIB.Huurprijsliberalisatie, 0)
	   ,[Grenswaarde liberalisatie] = (select min(minimum) from cte_Grenzen where CONTR.Ingangsdatum >= vanaf and CONTR.Ingangsdatum <= tot)
	   ,Huurverhogingsbeleidstype = BRON.[Rent Increase Policy Type Code]
	   ,[Indexcode contractregel] = Coalesce(ONB.IndexCode,'')
	   ,[Controle-bevinding] = CASE WHEN CONTR.Ingangsdatum  is null then 'Geen lopend contract' else case when CONTR.Ingangsdatum < '19940701' THEN 'Geen controle nodig - gezien ingangsdatum sociaal contract'	-- select top 10 *
			ELSE CASE WHEN coalesce(HPR.kalehuur, 0) = 0 
				THEN 'Kalehuur niet bekend ten tijde van ingangsdatum huurcontract'
				ELSE CASE WHEN iif(coalesce(HPR.kalehuur, 0) > 
										(select min(minimum) from cte_Grenzen where CONTR.Ingangsdatum >= vanaf and CONTR.Ingangsdatum <= tot)
												,1,0) = coalesce(LIB.Huurprijsliberalisatie, 0) THEN 'In overeenstemming' 
				ELSE 'Afwijkend' END END END END
		,[Nettohuur ingangsdatum] = coalesce(HPR.kalehuur, 0)
		,[Controle-bevinding netto] = CASE WHEN CONTR.Ingangsdatum  is null then 'Geen lopend contract' else case when CONTR.Ingangsdatum < '19940701' THEN 'Geen controle nodig - gezien ingangsdatum sociaal contract'	-- select top 10 *
			ELSE CASE WHEN coalesce(HPR.nettohuur, 0) = 0 
				THEN 'Nettohuur niet bekend ten tijde van ingangsdatum huurcontract'
				ELSE CASE WHEN iif(coalesce(HPR.nettohuur, 0) > 
										(select min(minimum) from cte_Grenzen where CONTR.Ingangsdatum >= vanaf and CONTR.Ingangsdatum <= tot)
												,1,0) = coalesce(LIB.Huurprijsliberalisatie, 0) THEN 'In overeenstemming' 
				ELSE 'Afwijkend' END END END end
-- select top 10 TT.*
FROM empire_data.dbo.staedion$oge AS BRON
LEFT OUTER JOIN empire_Data.dbo.staedion$type AS TT
       ON TT.[Code] = BRON.[Type]
              AND TT.Soort <> 2
LEFT OUTER JOIN empire_Data.dbo.staedion$Additioneel AS CONTR
       ON CONTR.[Eenheidnr_] = BRON.Nr_
              AND CONTR.Einddatum = '17530101'
LEFT OUTER JOIN cte_geliberaliseerd AS LIB
       ON CONTR.Eenheidnr_ = LIB.Eenheidnr_
	   AND CONTR.[Customer No_] = LIB.[Customer No_]
              AND LIB.Volgnr = 1
LEFT OUTER JOIN cte_ONB AS ONB
       ON ONB.Eenheidnr_ = BRON.Nr_
	   AND ONB.Volgnr = 1
--OUTER APPLY empire_staedion_data.[dbo].[ITVFnContactbeheerInclNaam](BRON.Nr_) AS CONT
--OUTER APPLY empire_staedion_data.[dbo].ITVfnCLusterBouwblok(BRON.Nr_) AS CLUS
OUTER APPLY empire_staedion_data.[dbo].[ITVfnHuurprijs](BRON.Nr_, CONTR.Ingangsdatum) AS HPR
OUTER APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(CONTR.[Customer No_]) AS HRD
WHERE BRON.[Common Area] = 0
	   --AND TT.[Analysis Group Code] = 'WON ZELF'
    --   AND BRON.[Begin exploitatie] <> '17530101'
    --   AND BRON.[Einde exploitatie] = '17530101'
    --   AND BRON.[Status] IN (
    --          0
    --          ,3              ) -- =Leegstand,Uit beheer,Renovatie,Verhuurd,Administratief,Verkocht,In ontwikkeling
       --and BRON.Nr_ = 'OGEH-0061514'
GO
