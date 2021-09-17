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
		,U.[id]
		,[Uitzondering] = iif(U.[id] IS NULL, 0, 1)
		,U.[Aangemaakt]
		,[Aangemaakt_door] = U.[Aangemaakt_door]
		,U.[Startdatum]
		,U.[Einddatum]
		,U.[Opmerking]
from [Datakwaliteit].[RealisatieDetails] as R
JOIN Datakwaliteit.[Indicator] as I
       on I.[id_samengesteld] = R.[id_samengesteld]
JOIN Datakwaliteit.[Indicator] as I_parent
       on I_parent.[id] = I.[parent_id]
LEFT JOIN [Datakwaliteit].[Uitzondering] as U
		on U.[sleutel_entiteit] = case I_parent.[Omschrijving]
											when 'Eenheid' then R.[Eenheidnr]
											when 'Klant' then R.[Klantnr]
											when 'Relaties' then right(R.[Omschrijving], 12)
											--when 'Contracten' then coalesce(R.Eenheidnr,'OGEH-?') + '-' +  coalesce(R.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R.datIngang, 105),'ingangsdatum ?')
											when 'Contracten' then coalesce(nullif(R.[Eenheidnr],''),'OGEH-?') + '-' +  coalesce(nullif(R.[Klantnr],''),'KLNT-?')
											when 'Medewerker' then R.[fk_medewerker_id]
											else 'Volgt - zie vw_RealisatieDetails'
										end
		AND U.[id_samengesteld] = R.[id_samengesteld]
		AND getdate() between U.[Startdatum] and coalesce(dateadd(day, 1, U.[Einddatum]), dateadd(day, 1, getdate()))
WHERE I.[Zichtbaar] = 1
and R.Laaddatum = (SELECT MAX(Laaddatum) FROM Datakwaliteit.RealisatieDetails where Laaddatum <=getdate())

UNION

select distinct 
		 [id_samengesteld]
		,[sleutel_entiteit]
		,[id]
		,[Uitzondering] = 1
		,[Aangemaakt]
		,[Aangemaakt_door]
		,[Startdatum]
		,[Einddatum]
		,[Opmerking]
from [Datakwaliteit].[Uitzondering]

GO
