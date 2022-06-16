SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Datakwaliteit].[vw_Trigger]
AS 
/* ###################################################################################################
VAN         
STATUS      Test
CHECK       

TO DO: Filteren op juiste datum in normen tabel

---------------------------------------------------------------------------------------------------------
WIJZIGINGEN	
20201230 JvdW outer join Normen
20210324 MV Veld Waarde en NormOverschreden toegevoegd
20220223 RvG uitgecommentarieerde CTE zorgde voor veel vertraging: triggers konden in PowerApps ook niet snel worden opgehaald
################################################################################################### */	
/*
-- Te traag
with cte_waarde as (
	select r.id_samengesteld, Aantal = sum(r.[Aantal])
	from [Datakwaliteit].[vw_TriggerRealisatieDetails] r
	group by r.id_samengesteld
)

*/
WITH dat ([id_samengesteld], Laaddatum)
AS (SELECT rea.[id_samengesteld], MAX(rea.[Laaddatum])
	FROM Datakwaliteit.Realisatie rea
	WHERE rea.[Laaddatum] <= CONVERT(DATE, GETDATE())
	GROUP BY rea.[id_samengesteld]),
cte_waarde ([id_samengesteld], [Aantal])
AS (SELECT det.[id_samengesteld], COUNT(*)
	FROM dat INNER JOIN Datakwaliteit.RealisatieDetails det 
	ON dat.[id_samengesteld] = det.[id_samengesteld] AND dat.[Laaddatum] = det.[Laaddatum]
	GROUP BY det.[id_samengesteld])


SELECT 
     k.id_samengesteld
	,[fk_indicator_id]	= k.[id]
	,[fk_trigger_id]	= t.[id]
	,[Trigger]			= UPPER(LEFT(k.[Omschrijving], 1)) + LOWER(SUBSTRING(k.[Omschrijving], 2, LEN(k.[Omschrijving]))) + ': ' + UPPER(LEFT(t.[Naam], 1)) + LOWER(SUBSTRING(t.[Naam], 2, LEN(t.[Naam])))
	,[Bron]				= 'select * from [staedion_dm].[Datakwaliteit].[vw_RealisatieDetails] where [id_samengesteld] = ' + CONVERT(NVARCHAR(128), k.[id_samengesteld])
	,[Laatste]			= ISNULL(t.[Laatste], '1753-01-01 00:00:00.000')
	,[Ouderdom]			= DATEDIFF(HOUR, ISNULL(t.Laatste, '1753-01-01 00:00:00.000'), GETDATE())
	,[maxOuderdom]		= t.[maxOuderdom]
	,[verstuurMail]		= IIF(DATEPART(WEEKDAY, GETDATE()) BETWEEN 2 AND 6, IIF(DATEDIFF(HOUR, ISNULL(t.Laatste, '1753-01-01 00:00:00.000'), GETDATE()) >= t.maxOuderdom, 1, 0), 0)
	,[Melding]			= t.[Melding]
	,[Norm]				= COALESCE(t.[Norm], n.[Waarde])
	,[Waarde]			= ISNULL(r.[Aantal], 0)
	,[NormOverschreden] = IIF(ISNULL(r.[Aantal], 0) > COALESCE(t.[Norm], n.[Waarde]), 1, 0)
FROM [Datakwaliteit].[Indicator] k
INNER JOIN [Datakwaliteit].[Trigger] t ON k.id_samengesteld = t.id_samengesteld
LEFT OUTER JOIN [Datakwaliteit].[Normen] n ON k.id = n.fk_indicator_id
LEFT OUTER JOIN  cte_waarde r ON r.id_samengesteld = k.id_samengesteld   
order by 4
offset 0 rows
GO
GRANT SELECT ON  [Datakwaliteit].[vw_Trigger] TO [STAEDION\svcPowerBI]
GO
