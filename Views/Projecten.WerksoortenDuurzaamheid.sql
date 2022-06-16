SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [Projecten].[WerksoortenDuurzaamheid] AS

/* #########################################################################################

------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------------------------
20200316 JvdW Aanzet
EVT:
- empire_data.dbo.[Staedion$Projectstatusmutaties] -- houdt logboek bij van status
- Common Table Expressie om te voorkomen dat je dubbele regels krijgt per eenheid
20200424 JvdW
> join met [Staedion$Type] gecorrigeerd

------------------------------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------------------------------
TOELICHTING: 
Op basis van opgeleverde woningen ultimo 2020 of eerder daar waar mogelijk. 
 
BRON:
Projecten in Empire module Planmatig onderhoud.
 
FILTERS: 
Jaar = 2020
Project = 11030452
WERKSOORT = P31010 of omschrijving = "HR+" 
Projectbudgetregel = 11030453
projectstatus = 'technisch gereed' 


------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Projecten', 'WerksoortenDuurzaamheid'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'View op data module Planmatig Onderhoud om te bepalen welke eenheden planmatig onderhoud hebben gehad van bepaalde werksoort',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'WerksoortenDuurzaamheid'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'WerksoortenDuurzaamheid'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select count(distinct Eenheid ) from staedion_dm.[Projecten].[WerksoortenDuurzaamheid] where [Corpodata type] like ''WON%''  and year([Datum gereed]) = 2019'  ,   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'WerksoortenDuurzaamheid'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Projecten',  
@level1type = N'VIEW',  @level1name = 'WerksoortenDuurzaamheid'
;  

######################################################################################### */    



SELECT DISTINCT Projectnummer = PROJ.Nr_
       ,PROJ.Naam
       ,[Omschrijving project] = PROJ.Omschrijving
       ,PROJ.[Status]
       ,PROJ.[Startdatum]
       ,PROJ.[Opleverdatum]
       ,PROJ.[Datum gereed]
       --     ,BR.Budgetregelnr_
       ,Werksoort = BR.Werksoort
       ,Leverancier = BR.[Orderleveranciernr_]
       --     ,BR.[Omschrijving 2]
       ,[Omschrijving werksoort] = WS.Omschrijving
       ,[Corpodata type] = TT.[Analysis Group Code]
       ,Eenheid = EENH.Eenheidnr_
       ,EENH.Teller -- Er kunnen eenheden zijn opgehaald die niet mee tellen: checken of afgevangen moet worden op teller
       ,[Soort ingreep] = CASE 
              WHEN (
                            BR.Werksoort = 'P31010'
                            OR UPPER(BR.Omschrijving) LIKE '%HR+%'
                            )
                     THEN 'HR-glas'
              WHEN (
                            BR.Werksoort = 'P51100'
							OR BR.Omschrijving LIKE '%individuele CV installatie%'
							OR BR.Omschrijving LIKE '%individuele CV-installatie%'
							OR BR.Omschrijving LIKE '%individuele CV ketel%'
							OR BR.Omschrijving LIKE '%individuele CV-ketel%'
                            )
                     THEN 'HR-toestel'
              WHEN (
	                -- JvdW P61011 moet er volgens mij bij
							BR.Werksoort IN ( 'P61010' , 'P61011')
							OR BR.Omschrijving LIKE '%PV panelen%'
							OR BR.Omschrijving LIKE '%PV-panelen%'
							OR BR.Omschrijving LIKE '%PV paneel%'
							OR BR.Omschrijving LIKE '%PV-paneel%'
                            )
                     THEN 'PV-paneel'
             WHEN (
							BR.Werksoort = 'P57500'
							OR BR.Omschrijving LIKE '%MV installatie%'
							OR BR.Omschrijving LIKE '%MV-installatie%'
							OR BR.Omschrijving LIKE '%MVI%'
                            ) AND (
							PROJ.Omschrijving LIKE '%vv%'
							OR PROJ.Omschrijving LIKE '%vervang%'
							)
                     THEN 'MV-vervangen'
             WHEN (
							BR.Werksoort = 'P57500'
							OR BR.Omschrijving LIKE '%MV installatie%'
							OR BR.Omschrijving LIKE '%MV-installatie%'
							OR BR.Omschrijving LIKE '%MVI%'
                            ) AND PROJ.Omschrijving LIKE '%aanbreng%'
                     THEN 'MV-aanbrengen'
              END
--     ,EENH.Werksoort
-- select BR.*
FROM empire_data.dbo.[staedion$Empire_project] AS PROJ
JOIN empire_data.dbo.[Staedion$Empire_Projectbudg_det_regel] AS BR
       ON BR.Projectnr_ = PROJ.Nr_
LEFT OUTER JOIN empire_Data.dbo.[Staedion$Empire_Projecttype_werksoorten] AS WS
       ON WS.Werksoortcode = BR.Werksoort
              AND PROJ.[Type] = WS.Projecttype
LEFT OUTER JOIN Empire_Data.dbo.[staedion$Eenheden_per_projectregel] AS EENH
       ON EENH.Projectnr_ = PROJ.Nr_
              AND EENH.Budgetregelnr_ = BR.Budgetregelnr_
LEFT OUTER JOIN empire_data.dbo.[Staedion$OGE] AS OGE
       ON OGE.Nr_ = EENH.Eenheidnr_
              AND OGE.[Common Area] = 0
LEFT OUTER JOIN empire_data.dbo.[Staedion$Type] AS TT
       ON TT.Soort <> 2
              AND TT.Code = OGE.[Type]
WHERE PROJ.Nr_ LIKE 'PLOH%'
       -- Hier kunnen meerdere criteria worden opgenomen voor proces-kpi's mbt werksoorten Planmatig onderhoud
       AND (
				-- HR-glas:
				(
				BR.Werksoort = 'P31010'
				OR UPPER(BR.Omschrijving) LIKE '%HR+%'
				) 
					OR
				-- HR-toestel:
				(
				BR.Werksoort = 'P51100'
				OR BR.Omschrijving LIKE '%individuele CV installatie%'
				OR BR.Omschrijving LIKE '%individuele CV ketel%'
				)
					OR
				-- PV-paneel:
				(
                -- JvdW P61011 moet er volgens mij bij
				BR.Werksoort IN ( 'P61010' , 'P61011')
				OR BR.Omschrijving LIKE '%PV panelen%'
				OR BR.Omschrijving LIKE '%PV-panelen%'
				OR BR.Omschrijving LIKE '%PV paneel%'
				OR BR.Omschrijving LIKE '%PV-paneel%'
                )
					OR
				-- MV:
				(
				BR.Werksoort = 'P57500'
				OR BR.Omschrijving LIKE '%MV installatie%'
				OR BR.Omschrijving LIKE '%MV-installatie%'
				)
		   )


GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Projecten', 'VIEW', N'WerksoortenDuurzaamheid', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Projecten', 'VIEW', N'WerksoortenDuurzaamheid', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op data module Planmatig Onderhoud om te bepalen welke eenheden planmatig onderhoud hebben gehad van bepaalde werksoort', 'SCHEMA', N'Projecten', 'VIEW', N'WerksoortenDuurzaamheid', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select count(distinct Eenheid ) from staedion_dm.[Projecten].[WerksoortenDuurzaamheid] where [Corpodata type] like ''WON%''  and year([Datum gereed]) = 2019', 'SCHEMA', N'Projecten', 'VIEW', N'WerksoortenDuurzaamheid', NULL, NULL
GO
