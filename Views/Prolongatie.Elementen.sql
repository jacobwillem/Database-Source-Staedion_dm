SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Prolongatie].[Elementen] as
/* #########################################################################################
JvdW tbv PBI Service-abonnementen

######################################################################################### */    
SELECT Elementnr = EL.Nr_
       ,[Element omschrijving] = EL.omschrijving
       ,Element = EL.Nr_ + ': ' + EL.omschrijving
			 ,Productboekingsgroep = EL.productboekingsgroep
			 ,Verhuurrekening = BOEK.Verhuurrekening
FROM empire_Data.dbo.[staedion$Element] AS EL
left outer join empire_Data.dbo.[staedion$General_Posting_Setup] as BOEK
on BOEK.[Gen_ Bus_ Posting Group] = 'NL' 
and EL.productboekingsgroep = BOEK.[Gen_ Prod_ Posting Group]
WHERE EL.[Tabel] = 0
;



GO
