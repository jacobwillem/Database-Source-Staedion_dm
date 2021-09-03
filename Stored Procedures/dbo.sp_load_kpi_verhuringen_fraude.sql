SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE[dbo].[sp_load_kpi_verhuringen_fraude](
  @peildatum date
)
as
begin

	-- eerst de details laden
	declare @indicator int = 101

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @indicator and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[RealisatieDetails](
		fk_indicator_id, 
		Datum,
		Waarde, 
		Omschrijving,
		Laaddatum,
		fk_contract_id)
		select
			@indicator,
			vhr.Datum,
			1,
			con.fk_klant_id + ' ; ' + trim(enh.descr) + ' ; ' + enh.da_postcode + ' ; ' + enh.da_plaats,
			GETDATE(),
			con.id 
		from Algemeen.Verhuring vhr inner join empire_dwh.dbo.[Contract] con
		on vhr.[Sleutel contract] = con.id
		inner join empire_dwh.dbo.eenheid enh
		on con.fk_eenheid_id = enh.id
		inner join empire_dwh.dbo.technischtype typ
		on enh.fk_technischtype_id = typ.id
		where vhr.categorie = 'Woonfraude' and
		vhr.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum and
		typ.fk_eenheid_type_corpodata_id in ('WON ZELF', 'WON ONZ')

	-- obv de details vullen we de totalen

	delete from Dashboard.[Realisatie] where fk_indicator_id = @indicator and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

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
		where rd.fk_indicator_id = @indicator and
		rd.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		group by rd.fk_indicator_id
	
	/* Uitgezet op verzoek van Directeur Woonservice 20200303 MV
	-- maximaal 40 fraude verhuringen dubbel tellen door ze toe te voegen bij regulier, zovbeel mogelijk verdeeld over het jaar
	if year(@peildatum) = 2020 -- alleen voor 2020 zorg dat in volgende jaren geen overlap in de definitie ontstaat!!
	begin

		delete from Dashboard.RealisatieDetails 
		where fk_indicator_id = 105 and
		datum between datefromparts(year(@peildatum), 1, 1) and datefromparts(year(@peildatum), 12, 31) and
		Omschrijving like 'Overgenomen van woonfraude%'

		; with rea (maand, aantal)
		as (select month(det.datum) maand, count(*) aantal
			from Dashboard.RealisatieDetails det 
			where det.fk_indicator_id = 101 and det.datum between datefromparts(year(@peildatum), 1, 1) and datefromparts(year(@peildatum), 12, 31)
			group by month(det.datum)),
		sub (maand, gewenst)
		as (select n.m, iif(n.a < isnull(rea.aantal, 0), n.a, isnull(rea.aantal, 0))
 			from rea full outer join (values (1, 3), (2, 3), (3, 4), (4, 3), (5, 3), (6, 4), (7, 3), (8, 3), (9, 4), (10, 3), (11, 3), (12, 4)) n(m, a)
			on rea.maand = n.m),
		ord (maand, gewenst, id, volgnr)
		as (select sub.maand, sub.gewenst, det.id, row_number() over (partition by month(det.datum) order by det.datum) volgnr
			from Dashboard.RealisatieDetails det inner join sub 
			on month(det.datum) = sub.maand
			where det.fk_indicator_id = 101 and
			det.datum between datefromparts(year(@peildatum), 1, 1) and datefromparts(year(@peildatum), 12, 31)),
		sel (id, sort, maand, volgnr)
		as (select top 40 id, iif(volgnr <= gewenst, 0, 1) sort, maand, volgnr
			from ord 
			order by sort, maand, volgnr)
		insert into Dashboard.RealisatieDetails (Datum, waarde, Laaddatum, Omschrijving, fk_indicator_id, fk_eenheid_id, fk_contract_id, fk_klant_id, Teller, Noemer)
			select det.Datum, det.waarde, det.Laaddatum, 'Overgenomen van woonfraude ' + det.Omschrijving, 105 fk_indicator_id, fk_eenheid_id, fk_contract_id, fk_klant_id, Teller, Noemer
			from sel inner join Dashboard.RealisatieDetails det 
			on sel.id = det.id
	end
	*/
end

GO
