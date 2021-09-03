SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Leegstand].[vw_Leegstaande_Parkeerplaatsen]
AS

SELECT 	 Peildatum = FORMAT(GETDATE(), 'yyyy-MM-dd')
		,EENH.Eenheidnr
		,Clusternummer = EENH.[FT clusternr]
		,Clusternaam = EENH.[FT clusternaam]
		,Plaats = EENH.Plaats
		,Postcode = EENH.Postcode
        ,Straatnaam = EENH.Straatnaam
	    ,Huisnummer = case when EENH.[Huisnummer] <> '' then EENH.[Huisnummer]
								when EENH.[Huisnummer toevoeging] like 'THV %' and EENH.[Huisnummer toevoeging] like '%-P%'
									then SUBSTRING(EENH.[Huisnummer toevoeging], CHARINDEX('THV ', EENH.[Huisnummer toevoeging]) + 4, CHARINDEX('-P', EENH.[Huisnummer toevoeging]) - CHARINDEX('THV ', EENH.[Huisnummer toevoeging]) - 4)
								when EENH.[Huisnummer toevoeging] like 'NST %' and EENH.[Huisnummer toevoeging] like '%-P%' then SUBSTRING(EENH.[Huisnummer toevoeging], CHARINDEX('NST ', EENH.[Huisnummer toevoeging]) + 4, CHARINDEX('-P', EENH.[Huisnummer toevoeging]) - CHARINDEX('NST ', EENH.[Huisnummer toevoeging]) - 4)
								else ''
								end
	   ,[Omschrijving huisnummers] = EENH.Huisnummer + iif(EENH.Huisnummer = '', '', ' ') + EENH.[Huisnummer toevoeging]
	   ,LBG.Leegstandsreden
	   ,TTY.[Technisch type]
FROM [staedion_dm].Leegstand.[Leegstanden] AS LST
INNER JOIN [staedion_dm].Leegstand.[Leegstandsboekingsgroep] AS LBG ON LST.Boekingsgroep = LBG.[Boekingsgroep]
LEFT OUTER JOIN [staedion_dm].[Eenheden].[Eigenschappen] AS EENH ON EENH.eenheidnr = LST.Eenheidnr
       AND EENH.Einddatum IS NULL -- huidige kenmerken van de eenheid
INNER JOIN [staedion_dm].Eenheden.[Technisch type] AS TTY ON EENH.[Technisch type_id] = TTY.[Technisch type_id]
LEFT OUTER JOIN staedion_dm.eenheden.EenheidStatus AS ES ON ES.EenheidStatus_id = EENH.Eenheidstatus_id
left outer join staedion_dm.eenheden.Corpodatatype as CORPO on CORPO.[Corpodatatype_id] = EENH.[Corpodatatype_id]
WHERE LBG.Leegstandsreden = 'Marktleegstand'
       AND year(LSt.Peildatum) = YEAR(getdate())
       AND month(LSt.Peildatum) = MONTH(GETDATE())
       AND CORPO.Code LIKE '%PP%'
       AND LST.[Einddatum] >= cast(dateadd(d,-1,cast(GETDATE() as date)) as date)
	   AND NOT EENH.[FT clusternr] IN ('FT-1168', 'FT-1331', 'FT-1345', 'FT-1425', 'FT-1567')


GO
