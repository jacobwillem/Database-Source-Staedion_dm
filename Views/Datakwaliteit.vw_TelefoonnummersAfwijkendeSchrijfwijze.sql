SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [Datakwaliteit].[vw_TelefoonnummersAfwijkendeSchrijfwijze] 
AS 
WITH cte_actieve_huurderset
AS (
	SELECT *
	FROM staedion_dm.Datakwaliteit.SetHuurdersTeChecken
	)
SELECT CTE.*
	,[Telefoon (klantkaart)] = CUST.[Phone No_]
	,[Telefoon (huishoudkaart)] = CONT.[Phone No_]	
	,[Telefoon 2 (klantkaart)] = CUST.[Telefoon 2]
	,[Telefoon 2 (huishoudkaart)] = CONT.[Telefoon 2]	
	,[Rol] = ROL.[Role Code]
FROM cte_actieve_huurderset AS CTE
LEFT OUTER JOIN empire_data.dbo.Customer AS CUST ON CUST.No_ = CTE.Klantnr
LEFT OUTER JOIN empire_data.dbo.Contact AS CONT ON CTE.Huishoudnr = CONT.No_
LEFT OUTER JOIN empire_data.dbo.Contact_Role AS ROL ON CUST.[contact no_] = ROL.[Related Contact No_]
	AND ROL.[Show first] = 1
WHERE (
		CUST.[Phone No_] <> ''
		AND staedion_dm.[Datakwaliteit].[fn_check_telefoon](CUST.[Phone No_]) = 0
		)
	OR (
		CONT.[Phone No_] <> ''
		AND staedion_dm.[Datakwaliteit].[fn_check_telefoon](CONT.[Phone No_]) = 0
		)
	OR (
		CUST.[Telefoon 2] <> ''
		AND staedion_dm.[Datakwaliteit].[fn_check_telefoon](CUST.[Telefoon 2]) = 0
		)
	OR (
		CONT.[Telefoon 2] <> ''
		AND staedion_dm.[Datakwaliteit].[fn_check_telefoon](CONT.[Telefoon 2]) = 0
		);

GO
