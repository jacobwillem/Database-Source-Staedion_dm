SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Jaarrekening].[Huurstanden]
AS
WITH CTE_INTRZOR
AS (
	SELECT DISTINCT [Eenheidnummer] = SUBSTRING([Sleutel], CHARINDEX('OGEH', [Sleutel]), (CHARINDEX(',V', [Sleutel]) - CHARINDEX('OGEH', [Sleutel])))
		,[Intrm zorg type] = 'INTR ZOR'
	FROM [empire_data].[dbo].[Staedion$Attribute_Value_Entry]
	WHERE [Value] LIKE '%Intramur%'
	)
SELECT [Peildatum]
	,[Eenheidnummer] = Meetwaarden.[Eenheidnr]
	,[Clusternummer] = [FT clusternr]
	,vw_Clusterlocatie.[Gemeente]
	,[Exploitatiestatus] = [detailstatus]
	,[Netto huur]
	,[Prolongatietermijn]
	,[Bedrijf]
	,[Administratief eigenaar]
	,[Juridisch eigenaar]
	,[Intrm zorg type] = CTE_INTRZOR.[Intrm zorg type]
	,Huurdernummer = Meetwaarden.Huurdernr
    ,Huurdernaam = case when Meetwaarden.[Eenheidstatus_id] = 0 then 'Leegstand' when KLANT.[Name] = '' and Meetwaarden.Huurdernr = 'KLNT-0070870' then 'Lady Sport' when KLANT.[Name] = '' and Meetwaarden.Huurdernr = 'KLNT-0082389' then 'VKO Transport' else KLANT.[Name] end
FROM [staedion_dm].[Eenheden].[Meetwaarden]
JOIN staedion_dm.Eenheden.Bedrijf ON Meetwaarden.Bedrijf_id = Bedrijf.Bedrijf_id
JOIN staedion_dm.Eenheden.Eigenschappen ON Meetwaarden.Eigenschappen_id = Eigenschappen.Eigenschappen_id
JOIN [staedion_dm].[Eenheden].[Exploitatiestatus] ON Meetwaarden.Exploitatiestatus_id = Exploitatiestatus.id
JOIN [staedion_dm].Dashboard.vw_Clusterlocatie ON Eigenschappen.[FT clusternr] = vw_Clusterlocatie.Clusternummer
Left outer join CTE_INTRZOR on CTE_INTRZOR.Eenheidnummer = Meetwaarden.Eenheidnr
left outer join empire_data.dbo.Customer as KLANT on KLANT.No_ = Meetwaarden.Huurdernr
WHERE Peildatum >= DATEFROMPARTS(YEAR(getdate()) - 1, 1, 1)
	AND exploitatiestatus = 'In exploitatie'
GO
