SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Projecten].[vw_Projectgegevens]
AS 
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
JvdW 20210823 TBV PBI rapportage budgetrapportage planmatig onderhoud
JvdW 20210908 Contractnr toegevoegd - topdeskverzoek Nicole
JvdW 20211229 Toegevoegd: [projectfase dan wel status]
JvdW 20220222 Tijdelijk toegevoegd: nu staan verwijderde projecten nog in de datamart - wordt aangepast - eruitfilteren
-- vooraf 7057: select count(*), count (distinct Projectnr) from staedion_dm.[Projecten].[vw_Projectgegevens] 
-- hierna 7051: ok
RvG  20220222 In de load worden verwijdere projectkaarten nu gemarkeerd in de kolom [Verwijder] met de waarde 1
			  In de view wordt gefilterd op [Verwijderd] = 0 zodat de verwijderde projecten niet worden meegenomen
JvdW 20220223 Hyperlink Empire toegevoegd zodat ie PBI mbv html-viewer getooond kan worden
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
	WITH dat (peildatum)
	AS (SELECT DATEADD(MONTH, -1, CONVERT(DATE, GETDATE())))
	SELECT prj.id project_id
	,prj.bedrijf_id
	,bdr.Bedrijf
	,Projectnr = prj.Nr_
	,prj.Naam
	,Projectnaam = prj.Nr_ + COALESCE(' ' + prj.Naam, '') + COALESCE(' - ' + prj.Omschrijving, '')
	,prj.Omschrijving
	,pty.Projecttype
	,pty.Omschrijving Projecttype_oms
	,psa.[Status] projectstatus
	,coalesce(psa.Omschrijving,'[Onbekend, nvt]') as projectstatus_oms
	,pfa.Projectfase
	,coalesce(pfa.Omschrijving,'[Onbekend, nvt]') as  Projectfase_oms

	,CASE WHEN pfa.Omschrijving = '[Onbekend, nvt]'
				THEN 'Status: '+psa.Omschrijving ELSE 'Fase: '+ pfa.Omschrijving END AS [projectfase dan wel status]

	,prj.Geblokkeerd
	,prj.Startdatum
	,prj.Contractnr
	,Begrotingsjaar = prj.Jaar -- JvdW 23-08-2021 - anders verwarrend in PBI
	,[Begrotingsjaar relatief] = 
		CASE WHEN prj.jaar > 0 AND YEAR(dat.peildatum) = prj.jaar THEN 'Huidig jaar'
			WHEN RIGHT(CONVERT(VARCHAR(10), YEAR(dat.peildatum)), 2) = SUBSTRING(prj.Nr_, 6, 2) THEN 'Huidig jaar volgens projectnr ?'
			ELSE 'Voorgaande jaren' END
	/*
	CASE 
		WHEN MONTH(GETDATE()) <> 1
			THEN CASE 
					WHEN YEAR(GETDATE()) = prj.Jaar
						THEN 'Huidig jaar'
					ELSE CASE 
							WHEN RIGHT(CONVERT(NVARCHAR(4), YEAR(GETDATE())), 2) = SUBSTRING(prj.Nr_, 6, 2)
								THEN 'Huidig jaar volgens projectnr ?'
							ELSE CASE 
									WHEN YEAR(GETDATE()) > prj.Jaar
										THEN 'Voorgaande jaren'
									END
							END
					END
		END
	*/
	,prj.[Nr_ Hoofdproject]
	,prj.[Aangemaakt op]
	,prj.[Finish Year]
	,prj.[Date Closed]
	,[Actief] = IIF(prj.Actief = 1, 'Ja', 'Nee')
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
	,[Opzichter] = COALESCE(C.Name, '[Onbekend,nvt]')
	,[Projectmanager] = COALESCE(PM.Name, '[Onbekend,nvt]') -- 20210406 Toegevoegd
	,[Niet begroot] = CASE 
		WHEN prj.id IN (
				SELECT B.project_id
				FROM [Projecten].[Budget] AS B
				GROUP BY B.project_id
				HAVING SUM(COALESCE([Budget_incl_btw], 0)) <= 0.01
				)
			THEN 'Niet begroot'
		ELSE 'Wel begroot'
		END
	 ,COALESCE('<a href="'+empire_staedion_data.empire.fnEmpireLink('Staedion', 11030452, 'Nr.='+prj.Nr_+',Type='+pty.Projecttype+'',  'view')+'">Project ' + prj.Nr_ + '</a>', NULL) AS HyperlinkEmpire
FROM projecten.Project AS prj
INNER JOIN dat ON 1 = 1
INNER JOIN [Algemeen].[Bedrijven] AS bdr ON prj.bedrijf_id = bdr.Bedrijf_id
INNER JOIN projecten.ProjectType AS pty ON prj.Projecttype_id = pty.id
left outer JOIN projecten.ProjectFase AS pfa ON prj.Projectfase_id = pfa.id
left outer JOIN projecten.ProjectStatus AS psa ON prj.Status_id = psa.id
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
--	where prj.Nr_ = 'POCO-2200052'
	--WHERE prj.Nr_ LIKE 'PLOH-20%'
	WHERE prj.Verwijderd = 0

GO
