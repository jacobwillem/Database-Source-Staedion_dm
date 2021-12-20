SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_update_business_keys_in_realisatiedetails]
as
begin

  -- update de bk's obv de fk's (dit om niet meer afhankelijk te zijn van dwh).
  update rd
    set 
      rd.eenheidnummer = con.bk_eenheidnr,
      rd.klantnummer = nullif(con.fk_klant_id, '------------------')
  from [Dashboard].[RealisatieDetails] as rd
  join empire_dwh..contract as con on con.id = rd.fk_contract_id
  where rd.klantnummer is null

  update rd
    set 
      rd.eenheidnummer = e.bk_nr_
  from [Dashboard].[RealisatieDetails] as rd
  join empire_dwh..eenheid as e on e.id = rd.fk_eenheid_id
  where rd.eenheidnummer is null

  update rd
    set 
      rd.klantnummer = rd.fk_klant_id
  from [Dashboard].[RealisatieDetails] as rd
  where rd.klantnummer is null

  update rd set
	 rd.[Detail_01] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
	,rd.[Detail_02] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
	,rd.[Detail_03] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
	,rd.[Detail_04] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
	,rd.[Detail_05] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
	,rd.[Detail_06] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
	,rd.[Detail_07] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
	,rd.[Detail_08] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
	,rd.[Detail_09] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
	,rd.[Detail_10] = trim(cast('<t><![CDATA[' + replace(rd.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
	from [Dashboard].[RealisatieDetails] as rd
	where rd.[Detail_01] is null

end
GO
