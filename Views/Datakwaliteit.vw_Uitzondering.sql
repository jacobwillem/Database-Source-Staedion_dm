SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Datakwaliteit].[vw_Uitzondering]
as 

select distinct
		 R.[id_samengesteld]
		,[sleutel_entiteit] = case I_parent.[Omschrijving]
									when 'Eenheid' then R.[Eenheidnr]
									when 'Klant' then R.[Klantnr]
									when 'Relaties' then right(R.[Omschrijving], 12)
									--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
									when 'Contracten' then coalesce(nullif(R.[Eenheidnr],''),'OGEH-?') + '-' +  coalesce(nullif(R.[Klantnr],''),'KLNT-?')
									when 'Medewerker' then R.[fk_medewerker_id]
									else 'Volgt - zie vw_RealisatieDetails'
								end
		,UIT.[id]
		,[Uitzondering] = iif(UIT.[id] IS NULL, 0, 1)
		,UIT.[Aangemaakt]
		,[Aangemaakt_door] = UIT.[Aangemaakt_door]
		,UIT.[Startdatum]
		,UIT.[Einddatum]
		,UIT.[Opmerking]
from [Datakwaliteit].[RealisatieDetails] as R
JOIN Datakwaliteit.[Indicator] as I
       on I.[id_samengesteld] = R.[id_samengesteld]
JOIN Datakwaliteit.[Indicator] as I_parent
       on I_parent.[id] = I.[parent_id]
LEFT JOIN [Datakwaliteit].[Uitzondering] as UIT
		on UIT.[sleutel_entiteit] = case I_parent.[Omschrijving]
											when 'Eenheid' then R.[Eenheidnr]
											when 'Klant' then R.[Klantnr]
											when 'Relaties' then right(R.[Omschrijving], 12)
											--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
											when 'Contracten' then coalesce(nullif(R.[Eenheidnr],''),'OGEH-?') + '-' +  coalesce(nullif(R.[Klantnr],''),'KLNT-?')
											when 'Medewerker' then R.[fk_medewerker_id]
											else 'Volgt - zie vw_RealisatieDetails'
										end
		AND UIT.[id_samengesteld] = R.[id_samengesteld]
		AND getdate() between UIT.[Startdatum] and coalesce(dateadd(day, 1, UIT.[Einddatum]), dateadd(day, 1, getdate()))
WHERE I.[Zichtbaar] = 1
and R.Laaddatum = (SELECT MAX(Laaddatum) FROM Datakwaliteit.RealisatieDetails where Laaddatum <=getdate())

GO
