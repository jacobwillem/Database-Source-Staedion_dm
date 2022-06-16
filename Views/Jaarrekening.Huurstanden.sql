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
    ,Huurdernaam = CASE WHEN Meetwaarden.[Eenheidstatus_id] = 0 THEN 'Leegstand' WHEN KLANT.[Name] = '' AND Meetwaarden.Huurdernr = 'KLNT-0070870' THEN 'Lady Sport' WHEN KLANT.[Name] = '' AND Meetwaarden.Huurdernr = 'KLNT-0082389' THEN 'VKO Transport' ELSE KLANT.[Name] END
FROM [staedion_dm].[Eenheden].[Meetwaarden]
JOIN staedion_dm.Eenheden.Bedrijf ON Meetwaarden.Bedrijf_id = Bedrijf.Bedrijf_id
JOIN staedion_dm.Eenheden.Eigenschappen ON Meetwaarden.Eigenschappen_id = Eigenschappen.Eigenschappen_id
JOIN [staedion_dm].[Eenheden].[Exploitatiestatus] ON Meetwaarden.Exploitatiestatus_id = Exploitatiestatus.id
LEFT OUTER JOIN [staedion_dm].Dashboard.vw_Clusterlocatie ON Eigenschappen.[FT clusternr] = vw_Clusterlocatie.Clusternummer
LEFT OUTER JOIN CTE_INTRZOR ON CTE_INTRZOR.Eenheidnummer = Meetwaarden.Eenheidnr
LEFT OUTER JOIN empire_data.dbo.Customer AS KLANT ON KLANT.No_ = Meetwaarden.Huurdernr
WHERE Peildatum >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
	AND exploitatiestatus = 'In exploitatie'
GO
