SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE[dbo].[sp_load_kpi_beeindigde_fraude](
  @peildatum date
)
as
begin

	-- eerst de details laden
	-- 20210607 PP: Clusternummer toegevoegd aan output
	-- exec staedion_dm.[dbo].[sp_load_kpi_beeindigde_fraude] '20210131'
	declare @indicator int = 110

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @indicator and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

;with fraude as (
	select
		fk_indicator_id = @indicator,
		Datum = con.dt_einde,
		Waarde = 1,
		Omschrijving = concat(wfd.[Omschrijving dossier], ';',
								wfd.Dossiersoortomschrijving, ';',
								case wfd.Afhandelingsreden
								when 'HUUROPZ' then 'Huuropzegging'
								when 'ONTRUIM' then 'Ontruiming'
								end, ';',
								wfd.Leefbaarheidsdossier, ';',
								con.bk_eenheidnr, ';',
								wfd.Adres, ';',
								con.fk_klant_id, ';',
								wfd.[Afgehandeld door], ';',
								'Doorlooptijd in dagen: ', wfd.Doorlooptijd, ';',
								wfd.[Dossierstatus]),
		Laaddatum = getdate(),
		fk_contract_id = wfd.Contract_id,
		fk_eenheid_id = con.fk_eenheid_id,
		fk_klant_id = con.fk_klant_id,
		-- Ontdubbelen op eenheidnr + klantnr gesorteerd op doorlooptijd leefbaarheidsdossier:
		volgnr = row_number() OVER (partition by con.bk_eenheidnr, con.fk_klant_id order by wfd.Doorlooptijd desc)
		,[Clusternummer] = (select top 1 [FT clusternr] from staedion_dm.Eenheden.Eigenschappen as EIG where EIG.Eenheidnr = con.bk_eenheidnr order by Ingangsdatum desc)
	from staedion_dm.Verhuur.Leefbaarheidsdossiers as wfd
	left outer join empire_dwh.dbo.[contract] as con
			on wfd.Contract_id = con.id
	where wfd.Contract_id is not null
			-- 202103 MV: Conform afspraak met business ook niet afgesloten dossiers meetellen. Geannuleerde worden wel gefilterd.
			-- and wfd.[Afhandeling dossier] <> '1753-01-01'
			and wfd.[Dossierstatus] not in ('GEANNUL')
			and (
					wfd.Leefbaarheidsdossiertype = 'ONRMGEBR'
					or wfd.Dossiersoortomschrijving in (
							'Woonfraude'
							,'Hennep'
							,'Onderhuur'
							)
					) 
			and wfd.Afhandelingsreden in (
					'HUUROPZ'
					,'ONTRUIM'
					)
			and year(con.dt_einde) = year(@peildatum)
			and	con.dt_einde between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
)

	insert into Dashboard.[RealisatieDetails](
		fk_indicator_id, 
		Datum, 
		Waarde, 
		Omschrijving,
		Laaddatum,
		fk_contract_id,
		fk_eenheid_id,
		[Clusternummer]
		--fk_klant_id
		)
	select
		fk_indicator_id, 
		Datum, 
		Waarde, 
		Omschrijving,
		Laaddatum,
		fk_contract_id,
		fk_eenheid_id,
		[Clusternummer]
		--fk_klant_id
	from fraude
	where volgnr = 1

	-- obv de details vullen we de totalen
	
	delete from Dashboard.[Realisatie] where fk_indicator_id = @indicator and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum)
		select
			fk_indicator_id,
			@peildatum,
			Waarde = SUM(rd.waarde),
			getdate()
		from Dashboard.[RealisatieDetails] as rd
		where rd.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum and 
		rd.fk_indicator_id = @indicator
		group by rd.fk_indicator_id
		
end

GO
