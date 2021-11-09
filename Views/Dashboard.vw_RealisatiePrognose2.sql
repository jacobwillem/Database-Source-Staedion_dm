SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Dashboard].[vw_RealisatiePrognose2]
as
	select
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
		,[Clusternummer] = R.[bk_clusternummer]
		,[Prognose] = 0
	from [Dashboard].[RealisatieDetails] as R

	union

	select
		 [id] = (P.[id] + 1000000000000)
		,[fk_indicator_id] = P.[fk_indicator_id]
		,[Datum] = P.[Datum]
		,[Laaddatum] = getdate()
		,[Waarde] = P.[Waarde]
		,[Teller] = null
		,[Noemer] = null
		,[Omschrijving] = P.[Omschrijving]
		,[Detail_01] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
		,[Detail_02] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
		,[Detail_03] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
		,[Detail_04] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
		,[Detail_05] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
		,[Detail_06] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
		,[Detail_07] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
		,[Detail_08] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
		,[Detail_09] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
		,[Detail_10] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
		,[Clusternummer] = null
		,[Prognose] = 1
	from [Dashboard].[PrognoseDetails] as P
	where not exists (
	  select 1
	  from Dashboard.RealisatieDetails as RD
	  where RD.[fk_indicator_id] = P.[fk_indicator_id]
	  and year(RD.[Datum]) = year(P.[Datum])
	  and month(RD.[Datum]) = month(P.[Datum])
	)

GO
