SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE[dbo].[sp_load_kpi_verhuringen_doorstroom](
  @peildatum date
)
as
begin

	-- eerst de details laden
	declare @indicator int = 102

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
		where vhr.categorie = 'Doorstroming' and
		vhr.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum

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
