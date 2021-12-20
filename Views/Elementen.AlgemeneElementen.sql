SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Elementen].[AlgemeneElementen] as
/* #########################################################################################
BETREFT: stamtabel voor oa PowerBI rapport huurkortingen. Later uitbreidbaar

NB: geeft niet de wijzigingen weer in de sturing, laatste stand Empire
--------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------
20211206 JvdW
--------------------------------------------------------------------------------------------
TESTEN
--------------------------------------------------------------------------------------------
select count(*), count(distinct Elementnr) from [Elementen].[AlgemeneElementen]

--------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Klacht'
######################################################################################### */    
SELECT ELEM.Nr_ AS Elementnr,
	   ELEM.Nr_ + ' ('+ COALESCE(NULLIF(ELEM.Omschrijving,''),'? omschrijving') + ')' + ' - '+ COALESCE(NULLIF(PROD.Verhuurrekening,''),'verhuurrekening ?') AS Element,
       ELEM.Omschrijving,
       CASE ELEM.ElementSoort
           WHEN 0 THEN
               ''
           WHEN 1 THEN
               'Service'
           WHEN 2 THEN
               'Verbruik'
           WHEN 3 THEN
               'Water'
           WHEN 4 THEN
               'Kale huur'
           WHEN 5 THEN
               'Waarborgsom'
           WHEN 6 THEN
               'Huurmatiging'
           WHEN 7 THEN
               'Parkeerplaats buiten'
           WHEN 8 THEN
               'Parkeerplaats binnen'
           WHEN 9 THEN
               'Huurkorting'
           WHEN 10 THEN
               'BTW-compensatie'
           ELSE
               '?'
       END AS Elementsoort,
       ELEM.Productboekingsgroep,
       PROD.Verhuurrekening,
       GA.[Name] AS [Rekeningnaam verhuurrekening],
       ELEM.Administratie,
       ELEM.Diversen,
       ELEM.Eenmalig,
	   CASE WHEN (ELEM.Productboekingsgroep IN ( 'IC HKDOORS', 'IC HKHERST', 'IC HUURKRT' )
				OR LOWER(ELEM.Omschrijving) LIKE '%korting%') THEN 'Filter PBI huurkorting' END AS [Filter voor rapport]
FROM empire_data.dbo.[Staedion$Element] AS ELEM
    LEFT OUTER JOIN empire_data.dbo.[staedion$General_Posting_Setup] AS PROD
        ON PROD.[Gen_ Bus_ Posting Group] = 'NL'
           AND PROD.[Gen_ Prod_ Posting Group] = ELEM.Productboekingsgroep
    LEFT OUTER JOIN empire_data.dbo.[staedion$g_l_account] AS GA
        ON PROD.Verhuurrekening = GA.No_
WHERE ELEM.Tabel = 0 --  ,Cluster,Eenheid,Contract,Indexering,Erfpacht
      AND ELEM.Soort = 0 -- Element,Titel,Totaal,Begintotaal,Eindtotaal
;
GO
