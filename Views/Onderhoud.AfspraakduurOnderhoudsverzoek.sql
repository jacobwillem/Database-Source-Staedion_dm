SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Onderhoud].[AfspraakduurOnderhoudsverzoek]
as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Onderhoud', 'AfspraakduurOnderhoudsverzoek'

-- Wijziginge 
20200311: Toch beter om de details hier te laden en de berekening in PBI


-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'Toont obv details onderhoudsverzoeken het verschil in werkdagen tussen onderhoudsorder (afspraakdatum) en onderhoudsverzoek (invoerdatum)',   
@level0type = N'SCHEMA', @level0name = 'Onderhoud',  
@level1type = N'VIEW',  @level1name = 'AfspraakduurOnderhoudsverzoek'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Onderhoud',  
@level1type = N'VIEW',  @level1name = 'AfspraakduurOnderhoudsverzoek'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from Onderhoud.AfspraakduurOnderhoudsverzoek order by Jaar desc, Weeknr desc',   
@level0type = N'SCHEMA', @level0name = 'Onderhoud',  
@level1type = N'VIEW',  @level1name = 'AfspraakduurOnderhoudsverzoek'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Onderhoud',  
@level1type = N'VIEW',  @level1name = 'AfspraakduurOnderhoudsverzoek'
;  
######################################################################################### */    

with cte_week_omschrijving as 
(SELECT datum
       ,isoweeknum
       ,volgnr = row_number() OVER (
              PARTITION BY isoweek ORDER BY datum ASC
              )
       ,omschrijving = convert(NVARCHAR(20), isoweek) + ' (' + convert(NVARCHAR(20), datum, 105) + ')'
--,datepart(iso_week, datum)
FROM empire_dwh.dbo.tijd
WHERE year(datum) >= 2020

) 

SELECT Jaar = year([Verzoek - datum invoer])
       ,Weeknr = year([Verzoek - datum invoer])*100+datepart(iso_week, [Verzoek - datum invoer])
       ,Maand = FORMAT([Verzoek - datum invoer], 'yyyy-MM', 'nl-NL')
       --,Weekomschrijving = 'Week ' + right('0' + convert(NVARCHAR(2), datepart(iso_week, [Verzoek - datum invoer])), 2) 
			 ,Weekomschrijving = 'Week ' +CTE.omschrijving
	     ,Verzoek
       ,[Verzoek - status]
       ,[Order]
       ,[Taak]
       ,[Verzoek - omschrijving]
       ,[Verzoek - datum invoer]
			 ,[Eigen dienst] = iif([Order - eigen dienst] = 1, 'Eigen dienst','Derden')
       ,[Taak - bekwaamheidscode] = coalesce([Taak - bekwaamheidscode], '[Onbekend, nvt]')
			 ,[Order - bekwaamheidscode] = coalesce([Order - bekwaamheidscode], '[Onbekend, nvt]')
       ,[Order - afspraakdatum]
			 ,[Order - leverancier]
			 ,[Verzoek - onderhoudstype]
       ,[Duur in werkdagen: afspraak order - verzoek invoerdatum] = iif([empire_staedion_data].[dbo].[fn_WerkdagenBepalen]([Verzoek - datum invoer], [Order - afspraakdatum], 1) * 1.0 < 0, NULL, [empire_staedion_data].[dbo].[fn_WerkdagenBepalen]([Verzoek - datum invoer], [Order - afspraakdatum], 1) * 1.0)
			 ,Laaddatum = (select loading_day from empire_logic.dbo.dlt_loading_day)
FROM empire_Dwh.dbo.[ITVF_npo_regels]('Aangemaakt', '20190101',DEFAULT, DEFAULT, DEFAULT) as BASIS
left outer join cte_week_omschrijving as CTE
on CTE.isoweeknum = year(BASIS.[Verzoek - datum invoer])*100+datepart(iso_week, BASIS.[Verzoek - datum invoer])
and CTE.volgnr = 1
WHERE [Verzoek - onderhoudstype] = 'Reparatieonderhoud'
--       AND [Order - eigen dienst] = 1
       AND nullif([Order - afspraakdatum], '17530101') IS NOT NULL




GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Onderhoud', 'VIEW', N'AfspraakduurOnderhoudsverzoek', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Onderhoud', 'VIEW', N'AfspraakduurOnderhoudsverzoek', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Toont obv details onderhoudsverzoeken het verschil in werkdagen tussen onderhoudsorder (afspraakdatum) en onderhoudsverzoek (invoerdatum)', 'SCHEMA', N'Onderhoud', 'VIEW', N'AfspraakduurOnderhoudsverzoek', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from Onderhoud.AfspraakduurOnderhoudsverzoek order by Jaar desc, Weeknr desc', 'SCHEMA', N'Onderhoud', 'VIEW', N'AfspraakduurOnderhoudsverzoek', NULL, NULL
GO
