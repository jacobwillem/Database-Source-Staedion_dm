SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Leegstand].[HuidigeLeegstandInclWorkflow] 
AS 

/* ###################################################################################################
VAN			JvdW
BETREFT		specifiek extra informatie rondom technische / asbest leegstand

-----------------------------------------------------------------------------------
WIJZIGINGEN	
-----------------------------------------------------------------------------------
20211014 JvdW, aangemaakt vanuit empire_dwh.dbo.dsp_rs_verzendlijst_technische_leegstand van Lotje Riksen, CNS, obv 18 07 388 Verzendlijst technische leegstand

-----------------------------------------------------------------------------------
CHECK
-----------------------------------------------------------------------------------
select * from staedion_dm.leegstand.leegstandInclWorkflow

20211012 JvdW: is er een afgeronde leegstandsperiode geweest van hetzelfde leegstandssoort dan wil Ralph dat kunnen zien incl totale leegstandsduur
> cte van basis gemaakt en gezocht naar 1 eerdere afgeronde periode van zelfde leegstandsnummer (tweede periode kwam niet voor en vind ik te complex voor nu)
> exec backup_empire_dwh.dbo.[dsp_rs_verzendlijst_technische_leegstand] -- 310
> exec empire_dwh.dbo.[dsp_rs_verzendlijst_technische_leegstand] -- 310
----------------------------------------------------------------------------------
-- dagen boekingsgroep tm staat hier al in: dus incl eerdere perioden !
select * from staedion_dm.leegstand.leegstanden where eenheidnr =  'OGEH-0000965' order by Peildatum desc 
-- dagen boekingsgroep tm staat hier niet in: dus excl eerdere perioden !
select * from empire_dwh.dbo.d_leegstand AS dl JOIN dbo.eenheid AS E ON E.id = dl.fk_eenheid_id where E.bk_nr_ = 'OGEH-0000965' order by dl.Datum desc -- dagen boekingsgroep tm staat hier al in !
################################################################################################### */	
	

	 WITH cte_basis
	AS (
		SELECT 
			Eenheidnr = enh.bk_nr_
			,eenheid = enh.descr
			,Clusternr = CL.bk_nr_
			,complex = enh.da_complex
			,datum_ingang_leegstand = enh.staed_dt_ingang_leegstand
			,huidige_labelconditie = hlc.descr
			,verhuurteam = enh.staedion_verhuurteam
			,dagen_leegstand_vanaf_ingang_reden = sum(dl.dagen_vanaf_ingang_reden)
			,dt_ingang_reden = MIN(dl.dt_ingang_reden)
			--behandelend_inspecteur_workflow     = wf.EMPIRE_Inspecteur_1eVooropname,
			,behandelend_inspecteur_workflow = wf.BehandelendInspecteurValue
			,opmerkingen_workflow = convert(VARCHAR(max), Replace(Replace(opmerkingen, CHAR(13), ''), CHAR(10), ' '))
			,datumOplevering = wf.DatumOplevering
			,[datumVerhuurbaarPer - Flow] = wf.VerhuurbaarPer
			,[datumVerhuurbaarPer - Emp] = nullif(opz.[Verhuurbaar Per], '17530101')
			,[soort leegstand] = rl.descr
			,dl.leegstandsnummer
			,dl.fk_redenleegstand_id
			,dl.datum
		FROM empire_dwh.dbo.eenheid enh
		JOIN empire_dwh.dbo.d_leegstand dl ON enh.id = dl.fk_eenheid_id
		JOIN empire_dwh.dbo.huidigelabelconditie hlc ON enh.fk_huidigelabelconditie_id = hlc.id
		JOIN empire_dwh.dbo.technischtype tt ON enh.fk_technischtype_id = tt.id
		LEFT OUTER JOIN empire_dwh.dbo.cluster CL ON CL.id = ENH.staedion_fk_ftcluster_id
		JOIN empire_dwh.dbo.redenleegstand AS rl ON dl.fk_redenleegstand_id = rl.id
		JOIN empire_dwh.dbo.vw_tijdset ts ON dl.datum = ts.datum
		--left join empire_staedion_data.workflow.SSISVerhuisFlowOpenstaandeTaken wf on enh.bk_nr_ = wf.empire_oge and wf.taaknaam like '1.3.5%'
		LEFT JOIN empire_staedion_data.workflow.[vw_AlleTaken] wf ON enh.bk_nr_ = wf.eenheidnr
			AND wf.taaknaam LIKE '1.3.5%'
		LEFT JOIN empire_data.[dbo].[vw_lt_mg_opzegging_verhuurcontract] AS opz ON opz.mg_bedrijf = enh.da_bedrijf
			AND opz.Eenheidnr_ = enh.bk_nr_
			AND opz.[Einde huur klant] = dateadd(d, - 1, enh.dt_ingang_leegstand)
		WHERE 1 = 1
			AND ts.tijdset = 'huidige maand'
			AND enh.fk_exploitatiestatus_id = 1
			AND enh.da_bedrijf = 'Staedion'
			AND dl.fk_statuseenheid_id_eenheid = 0
			AND (
				dl.dt_einde_reden >= dl.datum
				OR dl.dt_einde_reden IS NULL
				)
			AND tt.fk_eenheid_type_corpodata_id IN (
				'WON ONZ'
				,'WON ZELF'
				)
			AND dl.fk_redenleegstand_id IN (
				'01'
				,'09'
				)
			--AND enh.bk_nr_ = 'OGEH-0000965'
		GROUP BY 
			CL.bk_nr_
			,enh.bk_nr_
			,dl.leegstandsnummer
			,dl.fk_redenleegstand_id
			,dl.datum
			,enh.descr
			,enh.da_complex
			,enh.staed_dt_ingang_leegstand
			,hlc.descr
			,enh.staedion_verhuurteam
			,enh.dt_laatstecontract
			,
			--wf.EMPIRE_Inspecteur_1eVooropname,
			wf.BehandelendInspecteurValue
			,convert(VARCHAR(max), Replace(Replace(opmerkingen, CHAR(13), ''), CHAR(10), ' '))
			,wf.DatumOplevering
			,wf.VerhuurbaarPer
			,opz.[Verhuurbaar Per]
			,rl.descr
		)
		,cte_voorafgaand_1
	AS (
		SELECT dl.leegstandsnummer
			,dl.datum
			,dl.dt_ingang_reden
			,dl.dt_einde_reden
			,dagen_vanaf_ingang_reden
			,Opmerking = 'Eerdere periode = ' + CONVERT(NVARCHAR(20), dl.dt_ingang_reden,105) + '- ' + CONVERT(NVARCHAR(20), dl.dt_einde_reden,105)
			,volgnr = ROW_NUMBER() OVER (
				PARTITION BY dl.leegstandsnummer ORDER BY dl.datum DESC
				)
		FROM empire_dwh.dbo.d_leegstand dl
		JOIN (
			SELECT DISTINCT leegstandsnummer
				,fk_redenleegstand_id
				,datum
				,dt_ingang_reden
			FROM cte_basis
			) AS CTE ON cte.leegstandsnummer = dl.leegstandsnummer
			AND cte.fk_redenleegstand_id = dl.fk_redenleegstand_id
			AND cte.datum > dl.datum
			AND dl.dt_ingang_reden <> cte.dt_ingang_reden
			AND dl.dt_einde_reden IS NOT NULL
		)
	SELECT  BASIS.Eenheidnr
			,Clusternr
			,[Cluster] = BASIS.complex 
			,[Datum ingang leegstand] = BASIS.datum_ingang_leegstand 
			,[Huidige labelconditie] = BASIS.huidige_labelconditie
			,[Verhuurteam] = BASIS.verhuurteam
			,[Totaal dagen leegstand reden] = BASIS.dagen_leegstand_vanaf_ingang_reden + COALESCE(CTE_1.dagen_vanaf_ingang_reden,0)
			,[Opmerking dagen leegstand] = 'NB: dagen is inclusief eerdere periode met deze leegstandscode: '+ CTE_1.Opmerking + ' ('+FORMAT(COALESCE(CTE_1.dagen_vanaf_ingang_reden,0),'N0') +' dagen)'
			,[Behandelend inspecteur workflow] = BASIS.behandelend_inspecteur_workflow
			,[Opmerkingen workflow] = BASIS.opmerkingen_workflow 
			,[Datum oplevering] = BASIS.datumOplevering
			,[Datum verhuurbaar per volgens Worlflow] = BASIS.[datumVerhuurbaarPer - Flow]
			,[Datum verhuurbaar per volgens Empire] = BASIS.[datumVerhuurbaarPer - Emp]
			,[Reden leegstand] = BASIS.[soort leegstand] 
			--,dl.leegstandsnummer
			--,dl.fk_redenleegstand_id
			--,dl.datum
	FROM cte_basis AS BASIS
	LEFT OUTER JOIN cte_voorafgaand_1 AS CTE_1 ON CTE_1.leegstandsnummer = BASIS.leegstandsnummer AND CTE_1.volgnr = 1
	-- WHERE BASIS.Eenheid like 'OGEH-0062772%'

;
GO
