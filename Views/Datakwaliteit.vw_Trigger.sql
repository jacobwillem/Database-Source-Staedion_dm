SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [Datakwaliteit].[vw_Trigger]
as 
/* ###################################################################################################
VAN         
STATUS      Test
CHECK       

TO DO: Filteren op juiste datum in normen tabel

---------------------------------------------------------------------------------------------------------
WIJZIGINGEN	
20201230 JvdW outer join Normen
20210324 MV Veld Waarde en NormOverschreden toegevoegd
################################################################################################### */	

with cte_waarde as (
	select r.id_samengesteld, Aantal = sum(r.[Aantal])
	from [Datakwaliteit].[vw_TriggerRealisatieDetails] r
	group by r.id_samengesteld
)

select
     k.id_samengesteld
	,[fk_indicator_id]	= k.[id]
	,[fk_trigger_id]	= t.[id]
	,[Trigger]			= upper(left(k.[Omschrijving], 1)) + lower(substring(k.[Omschrijving], 2, len(k.[Omschrijving]))) + ': ' + upper(left(t.[Naam], 1)) + lower(substring(t.[Naam], 2, len(t.[Naam])))
	,[Bron]				= 'select * from [staedion_dm].[Datakwaliteit].[vw_RealisatieDetails] where [id_samengesteld] = ' + convert(nvarchar(128), k.[id_samengesteld])
	,[Laatste]			= isnull(t.[Laatste], '1753-01-01 00:00:00.000')
	,[Ouderdom]			= datediff(hour, isnull(t.Laatste, '1753-01-01 00:00:00.000'), getdate())
	,[maxOuderdom]		= t.[maxOuderdom]
	,[verstuurMail]		= iif(datepart(weekday, getdate()) between 2 and 6, iif(datediff(hour, isnull(t.Laatste, '1753-01-01 00:00:00.000'), getdate()) >= t.maxOuderdom, 1, 0), 0)
	,[Melding]			= t.[Melding]
	,[Norm]				= coalesce(t.[Norm], n.[Waarde])
	,[Waarde]			= isnull(r.[Aantal], 0)
	,[NormOverschreden] = iif(isnull(r.[Aantal], 0) > coalesce(t.[Norm], n.[Waarde]), 1, 0)
from [Datakwaliteit].[Indicator] k
inner join [Datakwaliteit].[Trigger] t on k.id_samengesteld = t.id_samengesteld
left outer join [Datakwaliteit].[Normen] n on k.id = n.fk_indicator_id
left outer join  cte_waarde r on r.id_samengesteld = k.id_samengesteld   


GO
GRANT SELECT ON  [Datakwaliteit].[vw_Trigger] TO [STAEDION\svcPowerBI]
GO
