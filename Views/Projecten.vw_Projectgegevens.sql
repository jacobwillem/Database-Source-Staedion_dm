SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE view [Projecten].[vw_Projectgegevens]
as 
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
JvdW 20210823 TBV PBI rapportage budgetrapportage planmatig onderhoud
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Projecten', 'vw_Projectgegevens'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------


################################################################################################################################## */    
	SELECT prj.id project_id
	,prj.bedrijf_id
	,bdr.Bedrijf
	,Projectnr = prj.Nr_
	,prj.Naam
	,Projectnaam = prj.Nr_ + coalesce(' ' + prj.Naam, '') + coalescE(' - ' + prj.Omschrijving, '')
	,prj.Omschrijving
	,pty.Projecttype
	,pty.Omschrijving Projecttype_oms
	,psa.[Status] projectstatus
	,psa.Omschrijving projectstatus_oms
	,pfa.Projectfase
	,pfa.Omschrijving Projectfase_oms
	,prj.Geblokkeerd
	,prj.Startdatum
	,Begrotingsjaar = prj.Jaar -- JvdW 23-08-2021 - anders verwarrend in PBI
	,[Begrotingsjaar relatief] = CASE 
		WHEN month(getdate()) <> 1
			THEN CASE 
					WHEN year(getdate()) = prj.Jaar
						THEN 'Huidig jaar'
					ELSE CASE 
							WHEN right(convert(NVARCHAR(4), year(getdate())), 2) = substring(prj.Nr_, 6, 2)
								THEN 'Huidig jaar volgens projectnr ?'
							ELSE CASE 
									WHEN year(getdate()) > prj.Jaar
										THEN 'Voorgaande jaren'
									END
							END
					END
		END
	,prj.[Nr_ Hoofdproject]
	,prj.[Aangemaakt op]
	,prj.[Finish Year]
	,prj.[Date Closed]
	,[Actief] = iif(prj.Actief = 1, 'Ja', 'Nee')
	,fn1.Functie AS [Functie 1]
	,fn1.Omschrijving AS Functie1_oms
	,prj.[Contact No_1]
	,fn2.Functie AS [Functie 2]
	,fn2.Omschrijving AS Functie2_oms
	,prj.[Contact No_2]
	,fn3.Functie AS [Functie 3]
	,fn3.Omschrijving Functie3_oms
	,prj.[Contact No_3]
	,prj.Projectleider_id
	,prj.Projectleider
	-- JVDW: tijdelijk toegevoegd voor Power BI-test			-- 20210823 Afhankelijkheden uitschakelen met cns-db
	--,Projectleider_dwh = (
	--       SELECT pl.descr
	--       FROM empire_dwh.dbo.emp_project AS p
	--       JOIN empire_dwh.dbo.emp_projectleider AS pl
	--              ON pl.id = p.fk_emp_projectleider_id
	--       WHERE p.bk_nr_ = prj.Nr_
	--       )
	,[Opzichter] = coalesce(C.Name, '[Onbekend,nvt]')
	,[Projectmanager] = coalesce(PM.Name, '[Onbekend,nvt]') -- 20210406 Toegevoegd
	,[Niet begroot] = CASE 
		WHEN prj.id IN (
				SELECT B.project_id
				FROM [Projecten].[Budget] AS B
				GROUP BY B.project_id
				HAVING sum(coalesce([Budget_incl_btw], 0)) <= 0.01
				)
			THEN 'Niet begroot'
		ELSE 'Wel begroot'
		END
FROM projecten.Project AS prj
INNER JOIN projecten.Bedrijf AS bdr ON prj.bedrijf_id = bdr.id
INNER JOIN projecten.ProjectType AS pty ON prj.Projecttype_id = pty.id
INNER JOIN projecten.ProjectFase AS pfa ON prj.Projectfase_id = pfa.id
INNER JOIN projecten.ProjectStatus AS psa ON prj.Status_id = psa.id
LEFT OUTER JOIN projecten.Functie AS fn1 ON prj.Functie1_id = fn1.id
LEFT OUTER JOIN projecten.Functie AS fn2 ON prj.Functie2_id = fn2.id
LEFT OUTER JOIN projecten.Functie AS fn3 ON prj.Functie3_id = fn3.id
LEFT OUTER JOIN empire_data.dbo.Contact AS C ON C.No_ = CASE 
		WHEN fn1.Functie = 'OPZ'
			THEN prj.[Contact No_1]
		ELSE CASE 
				WHEN fn2.Functie = 'OPZ'
					THEN prj.[Contact No_2]
				ELSE CASE 
						WHEN fn3.Functie = 'OPZ'
							THEN prj.[Contact No_3]
						END
				END
		END
LEFT OUTER JOIN empire_data.dbo.Contact AS PM ON PM.No_ = CASE 
		WHEN fn1.Functie = 'PM'
			THEN prj.[Contact No_1]
		ELSE CASE 
				WHEN fn2.Functie = 'PM'
					THEN prj.[Contact No_2]
				ELSE CASE 
						WHEN fn3.Functie = 'PM'
							THEN prj.[Contact No_3]
						END
				END
		END
	--where prj.Nr_ = 'PLOH-2100208'
	--WHERE prj.Nr_ LIKE 'PLOH-20%'
GO
