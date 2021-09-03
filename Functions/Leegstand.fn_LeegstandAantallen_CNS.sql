SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE function [Leegstand].[fn_LeegstandAantallen_CNS] (@Peildatum date = null ) 
returns table 
as
/* #################################################################################################################################
VAN			
------------------------------------------------------------------------------------------------------------------------------------
20210715 

LATER
- reden leegstand meegeven als parameter
- gecheckt met stand juni dwex-rapport Technische leegstand detail

################################################################################################################################# */
RETURN
SELECT eenheidnr = enh.bk_nr_
	,[Eenheidnr + adres] = enh.descr
	,[Datum ingang leegstand] = enh.staed_dt_ingang_leegstand
	,Verhuurteam = enh.staedion_verhuurteam
	,
	--    [dagen leegstand vanaf ingang reden]= sum(dl.dagen_vanaf_ingang_reden), 
	[Soort leegstand] = rl.descr
	,[Datum ingang reden leegstand] = dl.dt_ingang_reden
	,[Datum einde reden leegstand] = dl.dt_einde_reden
	,Peildatum = @Peildatum
--select dl.*
FROM empire_dwh.dbo.eenheid enh
JOIN empire_dwh.dbo.d_leegstand dl ON enh.id = dl.fk_eenheid_id
JOIN empire_dwh.dbo.technischtype tt ON enh.fk_technischtype_id = tt.id
JOIN empire_dwh.dbo.redenleegstand AS rl ON dl.fk_redenleegstand_id = rl.id
JOIN empire_dwh.dbo.exploitatiestatus AS es ON es.id = enh.fk_exploitatiestatus_id
WHERE 1 = 1
	--and ts.tijdset = 'huidige maand'
	and eomonth(dl.datum) = eomonth(@Peildatum)
	--and month(dl.datum) = month(@Peildatum)
	AND enh.fk_exploitatiestatus_id = 1 -- in exploitatie
	AND enh.da_bedrijf = 'Staedion'
	--AND dl.fk_statuseenheid_id_eenheid = 0
	--  and (dl.dt_einde_reden >= dl.datum or dl.dt_einde_reden is null)
	AND tt.fk_eenheid_type_corpodata_id IN (
		'WON ONZ'
		,'WON ZELF'
		)
	AND dl.fk_redenleegstand_id IN (
		'01'
		,'02'
		,'09'
		)
			--and enh.bk_nr_  =  'OGEH-0028451'
	AND dl.dt_ingang_reden <= @Peildatum -- week 28
	AND (
		dl.dt_einde_reden IS NULL
		OR dl.dt_einde_reden >= @Peildatum
		)

GO
