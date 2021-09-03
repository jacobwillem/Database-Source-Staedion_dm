SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Projecten].[OpleveringEnStart_tijdelijk] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Projecten', 'OpleveringEnStart'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'View verwijzend naar handmatig ingelezen excel-gegevens van Maarten Lindenboom. Kopie daarvan: Rapportageportal | O&V | Projecten | Start Bouw en Oplevering Projecten 2020.xlsm',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'OpleveringEnStart_Tijdelijk'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'OpleveringEnStart_Tijdelijk'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'SELECT [Soort Project], [KPI Start bouw] = sum([KPI Start bouw]), [KPI Oplevering bouw] = sum([KPI Oplevering bouw]), [Aantal start gerealiseerd] = sum([Aantal start gerealiseerd]), [Aantal oplevering gerealiseerd] = sum([Aantal oplevering gerealiseerd])
FROM staedion_dm.[Projecten].[OpleveringEnStart_Tijdelijk]
WHERE year([Datum]) = 2020
       AND month([Datum]) = 1
			 group by [Soort Project]',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'OpleveringEnStart_Tijdelijk'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'OpleveringEnStart_Tijdelijk'
;  

######################################################################################### */    


select		Datum															= DP.Datum,	
					Project														= DP.Project,
					[Soort Project]										= P.SoortProject,
					[KPI Start bouw]									= P.KPI_start,
					[KPI Oplevering bouw]							= P.KPI_oplevering,
					[Aantal start gerealiseerd]				= DP.AantalRealisatieBouw,
					[Aantal oplevering gerealiseerd]	=	DP.AantalRealisatieOplevering,
					[Bron]														= DP.Opmerking
from			empire_Staedion_data.excel.DataBouwOpleveringProjecten as DP
left join empire_staedion_data.excel.BouwOpleveringProjecten as P
on				P.Project = DP.Project



GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Projecten', 'VIEW', N'OpleveringEnStart_tijdelijk', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Projecten', 'VIEW', N'OpleveringEnStart_tijdelijk', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View verwijzend naar handmatig ingelezen excel-gegevens van Maarten Lindenboom. Kopie daarvan: Rapportageportal | O&V | Projecten | Start Bouw en Oplevering Projecten 2020.xlsm', 'SCHEMA', N'Projecten', 'VIEW', N'OpleveringEnStart_tijdelijk', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT [Soort Project], [KPI Start bouw] = sum([KPI Start bouw]), [KPI Oplevering bouw] = sum([KPI Oplevering bouw]), [Aantal start gerealiseerd] = sum([Aantal start gerealiseerd]), [Aantal oplevering gerealiseerd] = sum([Aantal oplevering gerealiseerd])
FROM staedion_dm.[Projecten].[OpleveringEnStart_Tijdelijk]
WHERE year([Datum]) = 2020
       AND month([Datum]) = 1
			 group by [Soort Project]', 'SCHEMA', N'Projecten', 'VIEW', N'OpleveringEnStart_tijdelijk', NULL, NULL
GO
