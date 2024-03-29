SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Dashboard].[vw_RealisatiePrognose2]
AS
	SELECT
		 R.[id]
		,R.[fk_indicator_id]
		,R.[Datum]
		,R.[Laaddatum]
		,R.[Waarde]
		,R.[Teller]
		,R.[Noemer]
		,R.[Omschrijving]
		,[Detail_01]
		,[Detail_02]
		,[Detail_03]
		,[Detail_04]
		,[Detail_05]
		,[Detail_06]
		,[Detail_07]
		,[Detail_08]
		,[Detail_09]
		,[Detail_10]
		,[Clusternummer] = R.[clusternummer]
		,[Prognose] = 0
	FROM [Dashboard].[RealisatieDetails] AS R
  --where fk_indicator_id between 1500 and 1550

	UNION

	SELECT
		 [id] = (P.[id] + 1000000000000)
		,[fk_indicator_id] = P.[fk_indicator_id]
		,[Datum] = P.[Datum]
		,[Laaddatum] = GETDATE()
		,[Waarde] = P.[Waarde]
		,[Teller] = NULL
		,[Noemer] = NULL
		,[Omschrijving] = P.[Omschrijving]
		,[Detail_01] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
		,[Detail_02] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
		,[Detail_03] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
		,[Detail_04] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
		,[Detail_05] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
		,[Detail_06] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
		,[Detail_07] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
		,[Detail_08] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
		,[Detail_09] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
		,[Detail_10] = TRIM(CAST('<t><![CDATA[' + REPLACE(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
		,[Clusternummer] = NULL
		,[Prognose] = 1
	FROM [Dashboard].[PrognoseDetails] AS P
	WHERE NOT EXISTS (
	  SELECT 1
	  FROM Dashboard.RealisatieDetails AS RD
	  WHERE RD.[fk_indicator_id] = P.[fk_indicator_id]
	  AND YEAR(RD.[Datum]) = YEAR(P.[Datum])
	  AND MONTH(RD.[Datum]) = MONTH(P.[Datum])
	)

	/*
	UNION

	SELECT
		 [id] = (ROW_NUMBER() OVER (ORDER BY I.[id]) + 2000000000000)
		,[fk_indicator_id] = I.[id]
		,[Datum] = CAST(GETDATE() AS DATE)
		,[Laaddatum] = GETDATE()
		,[Waarde] = S.[id]
		,[Teller] = NULL
		,[Noemer] = NULL
		,[Omschrijving] = S.[Omschrijving]
		,[Detail_01] = NULL
		,[Detail_02] = NULL
		,[Detail_03] = NULL
		,[Detail_04] = NULL
		,[Detail_05] = NULL
		,[Detail_06] = NULL
		,[Detail_07] = NULL
		,[Detail_08] = NULL
		,[Detail_09] = NULL
		,[Detail_10] = NULL
		,[Clusternummer]  = NULL
		,[Prognose] = 0
	FROM [Dashboard].[Indicator] AS I
	INNER JOIN [Dashboard].[Status] AS S ON S.[id] = I.[fk_status_id]
	AND S.[Omschrijving] <> 'Gereed'
	*/
GO
