SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Datakwaliteit].[vw_TelefoonnummersVeldenNietGebruiken] AS 
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
	,[Telefoon (klantkaart)] = CUST.[Phone No_]
	,[Telefoon (huishoudkaart)] = CONT.[Phone No_]	
	,[Telefoon overdag (klantkaart)] = CUST.[Telefoon overdag]
	,[Telefoon 3 (klantkaart)] = CUST.[Telefoon 3]
	,[Telefoon 4 (klantkaart)] = CUST.[Telefoon 4]
	,[Telefoon 5 (klantkaart)] = CUST.[Telefoon 5]
	,[Mobiel (klantkaart)] = CUST.[Mobiel]
	,[Mobiel 2 (klantkaart)] = CUST.[Mobiel 2]
	,[Mobiel 3 (klantkaart)] = CUST.[Mobiel 3]
	,[Mobiel 4 (klantkaart)] = CUST.[Mobiel 4]
	,[Mobiel 5 (klantkaart)] = CUST.[Mobiel 5]
	,[Rol] = ROL.[Role Code]
FROM cte_actieve_huurderset  AS CTE
LEFT OUTER JOIN  empire_data.dbo.Customer AS CUST
ON CUST.No_ = CTE.Klantnr
LEFT OUTER JOIN  empire_data.dbo.Contact AS CONT 
ON CTE.Huishoudnr = CONT.No_
LEFT OUTER JOIN  empire_data.dbo.Contact_Role AS ROL
ON CUST.[contact no_] = ROL.[Related Contact No_]
AND ROL.[Show first] = 1
WHERE (CUST.[Phone No_] = '' AND CUST.[Telefoon overdag] = '')
AND (CUST.[Telefoon 2] <> '' 
OR CUST.[Telefoon 3] <> ''
OR CUST.[Telefoon 4] <> ''
OR CUST.[Telefoon 5] <> ''
OR CUST.[Mobiel] <> ''
OR CUST.[Mobiel 2] <> ''
OR CUST.[Mobiel 3] <> ''
OR CUST.[Mobiel 4] <> ''
OR CUST.[Mobiel 5] <> '')
--and CTE.Klantnr = 'KLNT-0073151'
;
GO
