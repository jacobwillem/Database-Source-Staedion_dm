SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE  VIEW [Datakwaliteit].[vw_RealisatieDetails]
AS
-- JvdW 30-12-2020 Geen ; maar - ivm output naar csv
SELECT	I.id_samengesteld
		,R.id
		,[Sleutel entiteit] = CASE I_parent.[Omschrijving]
									WHEN 'Eenheid' THEN R.[Eenheidnr]
									WHEN 'Klant' THEN R.[Klantnr]
									-- JvdW 20211020 R.Relatienr toegevoegd
									-- JvdW 2021103 R.[Klantnr] toegevoegd
									WHEN 'Relaties' THEN COALESCE(R.Relatienr, R.[Klantnr],RIGHT(R.[Omschrijving], 12))
									--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
									WHEN 'Contracten' THEN COALESCE(NULLIF(R.[Eenheidnr],''),'OGEH-?') + '-' +  COALESCE(NULLIF(R.[Klantnr],''),'KLNT-?')
									WHEN 'Medewerker' THEN R.[fk_medewerker_id]
									ELSE 'Volgt - zie vw_RealisatieDetails'
								END
	   ,Entiteit = I_parent.Omschrijving
       ,Attribuut = I.Omschrijving
       ,[Controle onderwerp] = DIM.Vertaling
       ,[Laaddatum] = R.[Laaddatum]
       ,R.[fk_indicator_id]
       ,R.[Teller]
       ,R.[Noemer]
	   ,R.Eenheidnr
	   ,R.Klantnr
	   ,R.datIngang
	   ,R.datEinde
	   ,Aantal = 1
	   ,Hyperlink = CASE WHEN I.Omschrijving = 'bouwjaar' 
							THEN empire_staedion_data.empire.fnEmpireLink('Staedion', 11024009, 'Nr.=''' + R.Eenheidnr + '''', 'view')
							ELSE R.Hyperlink END
	   ,R.Omschrijving
	   ,R.Bevinding
--       ,[Ontbrekend] = R.Noemer - R.Teller
--       ,I.Procedure_completeness
-- select top 10 *
FROM Datakwaliteit.RealisatieDetails AS R
JOIN Datakwaliteit.[Indicator] AS I
       ON I.id_samengesteld = R.id_samengesteld
JOIN Datakwaliteit.[Indicator] AS I_parent
       ON I_parent.[id] = I.parent_id
JOIN [staedion_dm].[Datakwaliteit].Indicatordimensie AS DIM
       ON DIM.id = R.fk_indicatordimensie_id
LEFT JOIN [Datakwaliteit].[Uitzondering] AS UIT
		ON UIT.[sleutel_entiteit] = CASE I_parent.[Omschrijving]
											WHEN 'Eenheid' THEN R.[Eenheidnr]
											WHEN 'Klant' THEN R.[Klantnr]
											-- 20211020 JvdW R.huishoudnr toegevoegd
											WHEN 'Relaties' THEN COALESCE(R.Relatienr, RIGHT(R.[Omschrijving], 12))
											--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
											WHEN 'Contracten' THEN COALESCE(NULLIF(R.[Eenheidnr],''),'OGEH-?') + '-' +  COALESCE(NULLIF(R.[Klantnr],''),'KLNT-?')
											WHEN 'Medewerker' THEN R.[fk_medewerker_id]
											ELSE 'Volgt - zie vw_RealisatieDetails'
										END
		AND UIT.[id_samengesteld] = I.[id_samengesteld]
		AND GETDATE() BETWEEN UIT.[Startdatum] AND COALESCE(DATEADD(DAY, 1, UIT.[Einddatum]), DATEADD(DAY, 1, GETDATE()))
WHERE I.[Zichtbaar] = 1
AND UIT.[id] IS NULL
AND R.Laaddatum = (SELECT MAX(Laaddatum) FROM Datakwaliteit.RealisatieDetails WHERE Laaddatum <=GETDATE() )  -- per abuis kwam 1-7 lopend jaar ook voor ?!
--and I.omschrijving like '%bouwjaar%'
GO
