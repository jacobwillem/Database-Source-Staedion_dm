SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Verhuur].[AfgeslotenWoonfraudeDossiers_TE_VERWIJDEREN_20201028MV]
as
	select ldo.Dossiertype Leefbaarheidsdossiertype, ldo.[No_] Leefbaarheidsdossier, ldo.[Description] [Omschrijving dossier],
		isnull(ldc.Code, 'Niet ingevuld') Dossiersoort, ldc.[Description] Dossiersoortomschrijving, spc.[Show on Form] [Toon op kaart],
		ldo.Afhandelingsreden, iif(ldo.[Juridische kosten] = 1, 'Ja', 'Nee') [Juridische procedure], ldo.Dossierstatus, ldo.Datum [Start dossier], 
		(select min(lda.[Date])
		from empire_data.dbo.Staedion$Livability_DossierAction_Line lda inner join empire_data.dbo.Staedion$Livability_Action act
		on lda.Actie = act.Code and act.[Gerechtelijke procedure] = 1
		where lda.DossierNo_ = ldo.[No_]) [Datum gerechtelijke procedure], 
		case when ldo.[Dossierstatus] = 'VOLTOOID' and ldo.Afhandelingsreden in ('HUUROPZ', 'ONTRUIM') then 'Telt mee voor KPI-woonfraude'
			when ldo.[Dossierstatus] = 'VOLTOOID' and ldo.Afhandelingsreden not in ('HUUROPZ', 'ONTRUIM') then 'Telt mee niet voor KPI-woonfraude'
			else 'Lopende zaak' end [Opmerking],
		ldo.[Afgehandeld per] [Afhandeling dossier], datediff(d, ldo.Datum, ldo.[Afgehandeld per]) [Doorlooptijd], 
		replace(oge.Straatnaam + ' ' + oge.[Huisnr_] + ' ' + oge.Toevoegsel, '  ', ' ') [Adres],
		oge.Nr_ sleutel_eenheid, wkn.Code [Afgehandeld door],
		(select adi.[Customer No_]
		from empire_data.dbo.Staedion$Additioneel adi
		where adi.Eenheidnr_ = oge.[Nr_] and adi.Ingangsdatum <= ldo.[Datum] and (adi.Einddatum = '1753-01-01' or adi.Einddatum >= ldo.[Datum])) [Customer No_],
		(select con.id
		from empire_dwh.dbo.[contract] con
		where con.bk_eenheidnr = oge.[Nr_] and con.dt_ingang <= ldo.[Datum] and (con.dt_einde is null or con.dt_einde >= ldo.[Datum])) Contract_id
	from empire_data.dbo.Staedion$Livability_Dossier ldo inner join empire_data.dbo.Staedion$Liv__Dossier_Closing_Reason lcr
	on ldo.Afhandelingsreden = lcr.Code
	inner join empire_data.dbo.salesperson_purchaser wkn
	on ldo.[Assigned Person Code] = wkn.Code
	left outer join empire_data.dbo.Staedion$Liv__Dossier_Type ldt
	on ldo.Dossiertype = ldt.Code
	left outer join empire_data.dbo.Staedion$Liv__Dossier_Specification spc
	on ldo.No_ = spc.[Dossier No_]
	left outer join empire_data.dbo.Staedion$Liv__Dossier_Complaint_Type ldc
	on spc.Code = ldc.Code
	left outer join empire_data.dbo.Staedion$OGE oge
	on ldo.Eenheidnr_ = oge.Nr_
	where ldo.[Afgehandeld per] <> '1753-01-01' and
	ldo.[Dossierstatus] = 'VOLTOOID' and
	(ldt.code = 'ONRMGEBR' or ldc.[Description] IN ('Woonfraude', 'Hennep')) -- onrechtmatige bewoning or 
	and ldo.Afhandelingsreden in ('HUUROPZ', 'ONTRUIM')
GO
