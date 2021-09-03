SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Datakwaliteit].[CheckAfwijkingenServiceAbonnementen]
AS
/*
JvdW 20210203 Losse query in Service-abonnementen PBI

-- 2:37 maar kan ook langer gaan duren !
-- geen index op view te plaatsen want die verwijst naar andere database (je moet 'm with schemabinding maken)
-- of data wegschrijven naar [Contracten].[ActueleContractRegelsServiceAbonnementen] ?


*/
WITH cte_ActueleContractRegels
AS (
	SELECT Eenheidnr
		,Huurdernr
		,Huurdernaam
		,Volgnummer
		,Elementnr
		,Bedrag
		,Eenmalig
		,[Afwijking standaardprijs]
	FROM staedion_dm.[Contracten].[ActueleContractRegels]
	WHERE -- 1= 0 
		Elementnr IN (
			'404'
			,'405'
			,'407'
			,'408'
			,'409'
			,'410'
			,'411'
			,'412'
			,'413'
			,'415'
			)
	)
SELECT Toelichting = ' Afwijking standaardprijs 404,413,415'
       , Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs]
FROM cte_ActueleContractRegels
WHERE  [Afwijking standaardprijs] IS NOT NULL
       AND Elementnr IN (
              '404'
              ,'413'
              ,'415'
              )
UNION
SELECT Toelichting = 'Service-abonnement niet op woning'
       , Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs]
FROM cte_ActueleContractRegels
WHERE Eenheidnr NOT IN (
              SELECT Eenheidnummer
              FROM staedion_dm.algemeen.Eenheid
              WHERE [Eenheidtype Corpodata] LIKE 'WON%'
                     AND bedrijf = 'Staedion'
              )
UNION
SELECT Toelichting = 'Service-abonnement niet op woning'
       , Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs]
FROM cte_ActueleContractRegels
WHERE Elementnr NOT IN (
              '404'
              ,'413'
              ,'415'
              )
UNION
SELECT Toelichting = 'Kortingselementen komen 2 meer voor'
	,Eenheidnr
	,Huurdernr
	,Huurdernaam
	,Volgnummer
	,Elementnr
	,Bedrag
	,Eenmalig
	,[Afwijking standaardprijs]
FROM cte_ActueleContractRegels AS BASIS
WHERE Elementnr IN (
		'413'
		,'415'
		)
	AND 1 < (
		SELECT count(*)
		FROM cte_ActueleContractRegels AS BAK
		WHERE Elementnr IN (
				'413'
				,'415'
				)
			AND BAK.Eenheidnr = BASIS.Eenheidnr
		)

UNION

SELECT Toelichting = 'Meerdere service-elementen bij 1 contract'
	,Eenheidnr
	,Huurdernr
	,Huurdernaam
	,Volgnummer
	,Elementnr
	,Bedrag
	,Eenmalig
	,[Afwijking standaardprijs]
FROM cte_ActueleContractRegels AS BASIS
WHERE Elementnr IN (
		'404'
		,'408'
		,'409'
		,'410'
		,'411'
		,'412'
		)
	AND 1 < (
		SELECT count(*)
		FROM cte_ActueleContractRegels AS BAK
		WHERE Elementnr IN (
				'404'
				,'408'
				,'409'
				,'410'
				,'411'
				,'412'
				)
			AND BAK.Eenheidnr = BASIS.Eenheidnr
		)
GO
