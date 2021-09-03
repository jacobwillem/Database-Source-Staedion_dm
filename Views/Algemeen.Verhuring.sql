SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Algemeen].[Verhuring]
as
/******************************************************************************
* Theoretisch kan een contract in meerdere categorieën vallen, er is een keuze 
* gemaakt om dan 1 van de mogelijke categorieën te kiezen:
* Als er sprake is van Woonfraude bij het voorgaande contract wordt de verhuring gelabeld als Woonfraude
*	bij geen woonfraude wordt gekeken of het voorgaande contract als opzegreden heeft 'Doorstroming'
*   bij geen 'Doorstroming' wordt gekeken of het voorgaande contract als opzegreden heeft 'Woningruil'
*   bij geen 'Woningruil' wordt gekeken het een verhuring betreft aan livable of vps met een huur ongelijk 0 => label 'Tijdelijk'
* alle andere verhuringen worden gelabeld als 'Regulier'
*
******************************************************************************/
with opz (voorgaand_contract_id, reden, volgnr)
	-- bij meerdere mogelijkheden tot labeling wordt eerst gekeken naar label Woonfraude, vervolgens naar Doorstroming en ten slotte naar Woningruil
as (select tot.voorgaand_contract_id, tot.reden, row_number() over (partition by tot.voorgaand_contract_id order by tot.prioriteit desc) volgnr
	from (select opz.fk_contract_id voorgaand_contract_id, red.descr reden, iif(red.id = '05', 100, 500) prioriteit
		from empire_dwh.dbo.opzegging_verhuurcontract opz inner join empire_dwh.dbo.redenopzegging red
		on opz.fk_redenopzegging_id = red.id
		where red.id in ('05', -- Woningruil
						 '10') -- nog te bepalen leegstandscodering voor doorstroming
		union
		select wfd.Contract_id, 'Woonfraude', 1000
		from Verhuur.Leefbaarheidsdossiers wfd
		where wfd.Contract_id is not null and
		wfd.Opmerking = 'Telt mee voor KPI-woonfraude'
		and wfd.[Afhandeling dossier] <> '1753-01-01'
		and wfd.[Dossierstatus] = 'VOLTOOID' and
       (wfd.Leefbaarheidsdossiertype = 'ONRMGEBR' or wfd.Dossiersoortomschrijving IN ('Woonfraude', 'Hennep')) -- onrechtmatige bewoning or 
       and wfd.Afhandelingsreden in ('HUUROPZ', 'ONTRUIM')) as tot),
con ([Sleutel contract], [Datum], [Sleutel eenheid], [Sleutel voorgaand contract], [Verhuring cyclus], [fk_klant_id], [nettohuur_bij_ingang])
as (select [Sleutel contract]           = c.id,
		[Datum]                         = c.dt_ingang,
		[Sleutel eenheid]               = c.fk_eenheid_id,
		-- ophalen sleutel van het voorgaande contract op dezelfde eenheid
		[Sleutel voorgaand contract]    = lag(c.id, 1, 0) over(partition by c.fk_eenheid_id order by c.dt_ingang asc),
		ROW_NUMBER() over (partition by c.fk_eenheid_id order by c.dt_ingang asc) as [Verhuring cyclus],
		c.fk_klant_id, c.nettohuur_bij_ingang
	from empire_dwh.dbo.contract as c
	where c.dt_ingang is not null)
select con.[Sleutel contract], con.[Datum], con.[Sleutel eenheid], con.[Sleutel voorgaand contract], con.[Verhuring cyclus], 
	case when opz.reden is not null then opz.reden
		when con.fk_klant_id in ('KLNT-0068802', 'KLNT-0059119', -- klantnrs Livable
								'KLNT-0054303', 'KLNT-0058527') -- klantnrs VPS
								and con.nettohuur_bij_ingang <> 0 then 'Tijdelijk'
		else 'Regulier' end categorie
from con left outer join opz
on con.[Sleutel voorgaand contract] = opz.voorgaand_contract_id and opz.volgnr = 1
GO
