SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE function [Leegstand].[fn_LeegstandAantallen] (@Peildatum date = null ) 
returns table 
as
/* #################################################################################################################################
VAN			
------------------------------------------------------------------------------------------------------------------------------------
20210715 

LATER
- reden leegstand meegeven als parameter
- gecheckt met stand juni dwex-rapport Technische leegstand detail
- join met Eigenschappen nog verfijnen
select * from [Leegstand].[fn_LeegstandAantallen] ('20210711' )

################################################################################################################################# */
RETURN
with cte_peildatum as 
(
select peildatum = max(datum) 
from empire_Dwh.dbo.tijd 
where isoweek = (select isoweek from empire_Dwh.dbo.tijd where day_relative = -7) -- einde vorige week
)

SELECT LST.Eenheidnr
	,[Soort leegstand] = LST.Boekingsgroep
	,[Datum ingang reden leegstand] = LST.Ingangsdatum
	,[Datum einde reden leegstand] = LST.Einddatum
	--,LST.Dagen							-- NB: hele maand
	--,LST.[Derving netto]				-- NB: maandbedrag
	--,LST.[Leegstandsduur]
	,[Eenheidnr + adres] = LST.Eenheidnr + ' '+ EIG.Straatnaam + ' '+EIG.Huisnummer + ' ' + EIG.[Huisnummer toevoeging]
	,Verhuurteam = EIG.Verhuurteam
	,Peildatum = coalesce(@Peildatum,P.Peildatum)
-- select LST.*
FROM staedion_dm.Leegstand.Leegstanden AS LST
JOIN staedion_dm.[Eenheden].[Eigenschappen] AS EIG ON EIG.Eenheidnr = LST.Eenheidnr
	AND EIG.Einddatum IS NULL
JOIN staedion_dm.[Eenheden].Corpodatatype AS CORPO ON CORPO.Corpodatatype_id = EIG.Corpodatatype_id
JOIN [staedion_dm].[Leegstand].[Leegstandsboekingsgroep] AS LBG ON LBG.[Boekingsgroep] = LST.Boekingsgroep
join cte_peildatum as P on 1=1
WHERE eomonth(LST.Peildatum) = eomonth(coalesce(@Peildatum,P.Peildatum))
	--AND LST.Eenheidnr = 'OGEH-0027540'
	AND LBG.Leegstandsreden IN (
		'Technische leegstand'
		,'Marktleegstand'
		,'Asbestsanering'
		)
	AND (
		EIG.[Datum in exploitatie] <= coalesce(@Peildatum,P.Peildatum)
		and EIG.[Datum in exploitatie] <> '17530101'
		AND (EIG.[Datum uit exploitatie] = '17530101'
		OR EIG.[Datum uit exploitatie] >= coalesce(@Peildatum,P.Peildatum))
		)
	AND LST.Ingangsdatum <= coalesce(@Peildatum,P.Peildatum)
	AND (
		LST.[Einddatum] >= coalesce(@Peildatum,P.Peildatum)
		OR LST.[Einddatum] IS NULL
		)
	AND CORPO.Code LIKE '%WON%'
GO
