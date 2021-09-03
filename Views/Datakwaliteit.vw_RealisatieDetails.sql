SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE  view [Datakwaliteit].[vw_RealisatieDetails]
AS
-- JvdW 30-12-2020 Geen ; maar - ivm output naar csv
SELECT	I.id_samengesteld
		,R.id
		,[Sleutel entiteit] = case I_parent.[Omschrijving]
									when 'Eenheid' then R.[Eenheidnr]
									when 'Klant' then R.[Klantnr]
									when 'Relaties' then right(R.[Omschrijving], 12)
									--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
									when 'Contracten' then coalesce(nullif(R.[Eenheidnr],''),'OGEH-?') + '-' +  coalesce(nullif(R.[Klantnr],''),'KLNT-?')
									when 'Medewerker' then R.[fk_medewerker_id]
									else 'Volgt - zie vw_RealisatieDetails'
								end
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
	   ,Hyperlink = case when I.Omschrijving = 'bouwjaar' 
							then empire_staedion_data.empire.fnEmpireLink('Staedion', 11024009, 'Nr.=''' + R.Eenheidnr + '''', 'view')
							else R.Hyperlink end
	   ,R.Omschrijving
--       ,[Ontbrekend] = R.Noemer - R.Teller
--       ,I.Procedure_completeness
FROM Datakwaliteit.RealisatieDetails AS R
JOIN Datakwaliteit.[Indicator] AS I
       ON I.id_samengesteld = R.id_samengesteld
JOIN Datakwaliteit.[Indicator] AS I_parent
       ON I_parent.[id] = I.parent_id
JOIN [staedion_dm].[Datakwaliteit].Indicatordimensie AS DIM
       ON DIM.id = R.fk_indicatordimensie_id
LEFT JOIN [Datakwaliteit].[Uitzondering] AS UIT
		ON UIT.[sleutel_entiteit] = case I_parent.[Omschrijving]
											when 'Eenheid' then R.[Eenheidnr]
											when 'Klant' then R.[Klantnr]
											when 'Relaties' then right(R.[Omschrijving], 12)
											--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
											when 'Contracten' then coalesce(nullif(R.[Eenheidnr],''),'OGEH-?') + '-' +  coalesce(nullif(R.[Klantnr],''),'KLNT-?')
											when 'Medewerker' then R.[fk_medewerker_id]
											else 'Volgt - zie vw_RealisatieDetails'
										end
		AND UIT.[id_samengesteld] = I.[id_samengesteld]
		AND getdate() between UIT.[Startdatum] and coalesce(dateadd(day, 1, UIT.[Einddatum]), dateadd(day, 1, getdate()))
WHERE I.[Zichtbaar] = 1
and UIT.[id] is null
and R.Laaddatum = (SELECT MAX(Laaddatum) FROM Datakwaliteit.RealisatieDetails where Laaddatum <=getdate() )  -- per abuis kwam 1-7 lopend jaar ook voor ?!
--and I.omschrijving like '%bouwjaar%'
GO
