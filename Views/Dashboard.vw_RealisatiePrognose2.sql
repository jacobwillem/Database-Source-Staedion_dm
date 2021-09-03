SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Dashboard].[vw_RealisatiePrognose2]
AS
SELECT
	 R.[id]
	,R.[Datum]
	,R.[Waarde]
	,R.[Laaddatum]
	,R.[Omschrijving]
	,R.[fk_indicator_id]
	,R.[fk_eenheid_id]
	,R.[fk_contract_id]
	,R.[fk_klant_id]
	,R.[Teller]
	,R.[Noemer]
	,R.[Clusternummer]
	,[Prognose] = 0
	,[Detail.01] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
	,[Detail.02] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
	,[Detail.03] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
	,[Detail.04] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
	,[Detail.05] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
	,[Detail.06] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
	,[Detail.07] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
	,[Detail.08] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
	,[Detail.09] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
	,[Detail.10] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
	--,[Detail.11] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[11]','varchar(128)'))
	--,[Detail.12] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[12]','varchar(128)'))
FROM [Dashboard].[RealisatieDetails] AS R
--WHERE R.[fk_indicator_id] = 110
--JOIN [Dashboard].[vw_Indicator] AS I
--	ON I.[id] = R.[fk_indicator_id]
--	AND I.[Jaargang] = year(R.[Datum])
	--AND I.[Zichtbaar] = 1 /* UITGESCHAKELD ZODAT INDICATOR IN RAPPORT IN AANBOUW ZICHTBAAR WORDT. */
UNION
SELECT
	 [id] = (P.[id] + 1000000000000)
	,[Datum] = P.[Datum]
	,[Waarde] = P.[Waarde]
	,[Laaddatum] = getdate()
	,[Omschrijving] = P.[Omschrijving]
	,[fk_indicator_id] = P.[fk_indicator_id]
	,[fk_eenheid_id] = null
	,[fk_contract_id] = null
	,[fk_klant_id] = null
	,[Teller] = null
	,[Noemer] = null
	,[Clusternummer] = null
	,[Prognose] = 1
	,[Detail.01] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
	,[Detail.02] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
	,[Detail.03] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
	,[Detail.04] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
	,[Detail.05] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
	,[Detail.06] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
	,[Detail.07] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
	,[Detail.08] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
	,[Detail.09] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
	,[Detail.10] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
	--,[Detail.11] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[11]','varchar(128)'))
	--,[Detail.12] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[12]','varchar(128)'))
FROM [Dashboard].[PrognoseDetails] AS P
--JOIN [Dashboard].[vw_Indicator] AS I
--	ON I.[id] = P.[fk_indicator_id]
--	AND I.[Jaargang] = year(P.[Datum])
	--AND I.[Zichtbaar] = 1 /* UITGESCHAKELD ZODAT INDICATOR IN RAPPORT IN AANBOUW ZICHTBAAR WORDT. */
WHERE NOT EXISTS (
  SELECT 1
  FROM Dashboard.RealisatieDetails AS RD
  WHERE RD.[fk_indicator_id] = P.[fk_indicator_id]
  AND year(RD.[Datum]) = year(P.[Datum])
  AND month(RD.[Datum]) = month(P.[Datum])
)
GO
