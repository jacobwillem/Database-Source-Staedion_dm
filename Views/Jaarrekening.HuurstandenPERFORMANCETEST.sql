SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Jaarrekening].[HuurstandenPERFORMANCETEST]
AS with cteHS as(
SELECT   [Peildatum]
		,[Eenheidnummer] = Meetwaarden.[Eenheidnr]
		,[Clusternummer] = [FT clusternr]
		,[Netto huur]
		,[Prolongatietermijn]
FROM [staedion_dm].[Eenheden].[Meetwaarden]
JOIN staedion_dm.Eenheden.Eigenschappen ON Meetwaarden.Eigenschappen_id = Eigenschappen.Eigenschappen_id
JOIN [staedion_dm].[Eenheden].[Exploitatiestatus] ON Meetwaarden.Exploitatiestatus_id = Exploitatiestatus.id
WHERE 	Peildatum <= DATEFROMPARTS(2021, 9, 30)
	AND Peildatum >= DATEFROMPARTS(2021, 9, 1)
	AND exploitatiestatus = 'In exploitatie'
	AND Prolongatietermijn = '1M')

	,cteGB as(
	SELECT Eenheidnummer = OGE.[Realty Object No_]
	,Geboekt = sum(iif(GLE.Amount in ('A810200', 'A850150'), GLE.Amount, 0))
	,Omschrijving = string_agg(GLA.[NAME] + ': ' + FORMAT(GLE.Amount, 'C', 'nl-nl') + ' ' + GLE.[Description], '; ')
FROM empire_data.dbo.Staedion$G_L_Entry AS GLE
JOIN empire_Data.dbo.[Staedion$G_L_Account] AS GLA ON GLA.No_ = GLE.[G_L Account No_]
LEFT OUTER JOIN empire_Data.dbo.Staedion$G_L_Entry___Additional_Data AS OGE ON OGE.[G_L Entry No_] = GLE.[Entry No_]
WHERE GLE.[G_L Account No_] IN (
		'A810200'
		,'A850150'
		,'A810450'
		,'A810500'
		)
	AND GLE.[Posting Date] <= DATEFROMPARTS(2021, 9, 30)
	AND GLE.[Posting Date] >= DATEFROMPARTS(2021, 9, 1)
	AND GLE.Amount <> 0
	AND GLE.[Source Code] = 'PROLON'
group by OGE.[Realty Object No_]	)

	Select [Peildatum]
		,cteHS.[Eenheidnummer]
		,[Clusternummer]
		,[Netto huur]
		,[Geboekt] = coalesce(cteGB.Geboekt, 0)
		,[Omschrijving] = 'Netto huur: ' + FORMAT([Netto huur], 'C', 'nl-nl') + '' + coalesce(cteGB.Omschrijving, 'ONBEKEND/NVT')
		,[Waarde] = [Netto huur] + coalesce(cteGB.Geboekt, 0)
		,Controleren = iif(coalesce(-cteGB.Geboekt, 0) = [Netto huur], 0, 1)
		from cteHS
		left outer join cteGB
			on cteHS.Eenheidnummer = cteGB.Eenheidnummer

GO
