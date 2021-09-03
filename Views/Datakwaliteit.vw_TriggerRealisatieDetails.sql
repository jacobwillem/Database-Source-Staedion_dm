SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Datakwaliteit].[vw_TriggerRealisatieDetails]
as 
/* ###################################################################################################
VAN         
STATUS      Test
CHECK       

---------------------------------------------------------------------------------------------------------
WIJZIGINGEN	
JvdW 30-12-2020 * vervangen door kolom-aanduidingen  + tijdstempel weggehaald bij Laaddatum
################################################################################################### */	

SELECT r.id_samengesteld,
       r.[id], 
       r.[Sleutel entiteit], 
       r.[Entiteit], 
       r.[Attribuut], 
       r.[Controle onderwerp], 
       --Laaddatum = convert(date,r.[Laaddatum]),							-- in mail / excel: 2021-02-02T00:00:00Z					
	   Laaddatum = format(r.[Laaddatum], 'dd-MM-yyyy', 'nl-NL'),
       r.[fk_indicator_id], 
       r.[Teller], 
       r.[Noemer], 
       r.[Eenheidnr], 
       r.[Klantnr], 
       r.[datIngang], 
       r.[datEinde], 
       r.[Aantal], 
       r.[Hyperlink], 
       r.[Omschrijving], 
       [fk_trigger_id] = t.id

FROM [Datakwaliteit].[vw_RealisatieDetails] r
     INNER JOIN [Datakwaliteit].[Trigger] t ON t.id_samengesteld = r.id_samengesteld
     LEFT JOIN [Datakwaliteit].[TriggerUitzondering] u ON u.[fk_trigger_id] = t.id
                                                          AND r.[Sleutel entiteit] = u.[Uitzondering]
WHERE u.[id] IS NULL;

GO
GRANT SELECT ON  [Datakwaliteit].[vw_TriggerRealisatieDetails] TO [STAEDION\svcPowerBI]
GO
