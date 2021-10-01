SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [Datakwaliteit].[vw_TelefoonnummersVeldenTeWissen] AS 
WITH cte_actieve_huurderset
AS (
	SELECT *
	FROM staedion_dm.Datakwaliteit.SetHuurdersTeChecken
	)
SELECT CTE.Klantnr, CTE.Peildatum, CTE.Huishoudnr
	,[Telefoon 3 (klantkaart)] = CUST.[Telefoon 3] --'"="'+CUST.[Telefoon 3]+'"'
	,[Telefoon 3 (huishoudkaart)] = CONT.[Telefoon 3] --'"=""'+CONT.[Telefoon 3]+'"""'	
	,[Telefoon 4 (klantkaart)] = CUST.[Telefoon 4] --'"=""'+CUST.[Telefoon 4]+'"""'
	,[Telefoon 4 (huishoudkaart)] = CONT.[Telefoon 4] --'"=""'+CONT.[Telefoon 4]+'"""'	
	,[Telefoon 5 (klantkaart)] = CUST.[Telefoon 5] --'"=""'+CUST.[Telefoon 5]+'"""'
	,[Telefoon 5 (huishoudkaart)] = CONT.[Telefoon 5] --'"=""'+CONT.[Telefoon 5]+'"""'
	,[Telefoon overdag (klantkaart)] = CUST.[Telefoon overdag] --'"=""'+CUST.[Telefoon overdag]+'"""'	
	,[Telefoon overdag (huishoudkaart)] = CONT.[Telefoon overdag] --'"=""'+CONT.[Telefoon overdag]+'"""'	
	,[Rol] = ROL.[Role Code]
FROM cte_actieve_huurderset  AS CTE
LEFT OUTER JOIN  empire_data.dbo.Customer AS CUST
ON CUST.No_ = CTE.Klantnr
LEFT OUTER JOIN  empire_data.dbo.Contact AS CONT 
ON CTE.Huishoudnr = CONT.No_
LEFT OUTER JOIN  empire_data.dbo.Contact_Role AS ROL
ON CUST.[contact no_] = ROL.[Related Contact No_]
and ROL.[Show first] = 1
where CUST.[Telefoon 3] <> ''
or CUST.[Telefoon 4] <> ''
or CUST.[Telefoon 5] <> ''
or CUST.[Telefoon overdag] <> ''
or CONT.[Telefoon 3] <> ''
or CONT.[Telefoon 4] <> ''
or CONT.[Telefoon 5] <> ''
or CONT.[Telefoon overdag] <> ''
;
GO
