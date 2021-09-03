SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Datakwaliteit].[vw_TriggerLog]
as 
/* ###################################################################################################
VAN         
STATUS      Test
CHECK       
---------------------------------------------------------------------------------------------------------
WIJZIGINGEN	

################################################################################################### */	

SELECT
     k.id_samengesteld
	,[fk_indicator_id]		= k.[id]
	,[fk_trigger_id]		= t.[id]
	,[Trigger]				= upper(left(k.[Omschrijving], 1)) + lower(substring(k.[Omschrijving], 2, len(k.[Omschrijving]))) + ': ' + upper(left(t.[Naam], 1)) + lower(substring(t.[Naam], 2, len(t.[Naam])))
	,[Melding]				= t.[Melding]
	,[Norm]					= coalesce(t.[Norm], n.[Waarde])
	,[Laatste]				= isnull(t.[Laatste], '1753-01-01 00:00:00.000')
	,[Ouderdom]				= datediff(hour, isnull(t.[Laatste], '1753-01-01 00:00:00.000'), getdate())
	,[maxOuderdom]			= t.[maxOuderdom]
	,[Abonnee]				= e.[Emailadres]
	,[Ontvanger]			= m.[Emailadres]
	,[Notificatie]			= m.[Datum]
	,[Waarde]				= m.[Waarde]
from [Datakwaliteit].[Indicator] k
inner join [Datakwaliteit].[Trigger] t on k.id_samengesteld = t.id_samengesteld
left outer join [Datakwaliteit].[Normen] n on k.id = n.fk_indicator_id
left outer join [Datakwaliteit].[TriggerEmailadres] e on t.id = e.fk_trigger_id
left outer join [Datakwaliteit].[TriggerNotificatie] m on t.id = m.fk_trigger_id and e.Emailadres = m.Emailadres

GO
