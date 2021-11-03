SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Datakwaliteit].[vw_TelefoonnummersKlantkaartHuishoudkaart] AS 
WITH cte_actieve_huurderset
AS (
	SELECT *
	FROM staedion_dm.Datakwaliteit.SetHuurdersTeChecken
	)
SELECT  CTE.Klantnr
	,CTE.Peildatum
	,CTE.Huishoudnr
	,CTE.[Actief huurcontract]
	,CTE.Laaddatum
	,[Telefoon (klantkaart)] = ''+CUST.[Phone No_]
	,[Telefoon (huishoudkaart)] = ''+CONT.[Phone No_]	
	,[Telefoon 2 (klantkaart)] = ''+CUST.[Telefoon 2]
	,[Telefoon 2 (huishoudkaart)] = ''+CONT.[Telefoon 2]	
	,[Telefoon overdag (klantkaart)] = ''+CUST.[Telefoon overdag]
	,[Telefoon overdag (huishoudkaart)] = ''+CONT.[Telefoon overdag]
	,[Rol] = ROL.[Role Code]
FROM cte_actieve_huurderset  AS CTE
LEFT OUTER JOIN  empire_data.dbo.Customer AS CUST
ON CUST.No_ = CTE.Klantnr
LEFT OUTER JOIN  empire_data.dbo.Contact AS CONT 
ON CTE.Huishoudnr = CONT.No_
LEFT OUTER JOIN  empire_data.dbo.Contact_Role AS ROL
ON CUST.[contact no_] = ROL.[Related Contact No_]
AND ROL.[Show first] = 1
WHERE CUST.[Phone No_] <> CONT.[Phone No_]
OR CUST.[Telefoon 2] <> CONT.[Telefoon 2]
OR CUST.[Telefoon overdag] <> CONT.[Telefoon overdag]
;
GO
