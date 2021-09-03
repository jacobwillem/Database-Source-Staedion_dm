SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_kpi_huurachterstand_betalingsregelingen](
  @peildatum date
)
as
begin

	-- eerst de details laden
	declare @fk_indicator_id int = 1502

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[RealisatieDetails](
		fk_indicator_id, 
		Datum, 
		Waarde, 
		Omschrijving,
		Laaddatum)
		select
			@fk_indicator_id,
			btr.[Last Date Modified],
			-- Code BV is succesvol beëindigde betalingsregeling, het gewenste resultaat
			iif(btr.[Termination Code] = 'BV', 1.0, 0.0),
			btr.[Code] + ' - ' + btr.[Customer No_],
			getdate()
		from empire_data.dbo.Staedion$Payment_Scheme btr inner join empire_data.dbo.Staedion$Termination_Code_Paymnt_Scheme tec
		on btr.[Termination Code] = tec.[Code] and btr.[Termination Code] not in ('FB', 'NB') -- foutieve betalingsredenen uitsluiten
		inner join empire_dwh.dbo.klant kla
		on btr.[Customer No_] = kla.id
		where btr.[Last Date Modified] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum


	-- obv de details vullen we de totalen

	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	-- vanwege deling eerst afvangen delen door 0
	if (select count(*)
		from Dashboard.[RealisatieDetails] as rd
		where rd.Datum = @peildatum and 
		rd.fk_indicator_id = @fk_indicator_id) = 0
		-- als de count 0 oplevert, dan waarde 0 invullen
		insert into Dashboard.[Realisatie] (
			fk_indicator_id,
			Datum,
			Waarde,
			Laaddatum)
			select
				@fk_indicator_id,
				@peildatum,
				0,
				getdate()
	else
		-- als count <> 0 dan percentage berekenen
		insert into Dashboard.[Realisatie] (
			fk_indicator_id,
			Datum,
			Waarde,
			Laaddatum)
			select
				fk_indicator_id,
				@peildatum,
				Waarde = SUM(rd.waarde) / count(*),
				getdate()
			from Dashboard.[RealisatieDetails] as rd
			where rd.Datum = @peildatum and 
			rd.fk_indicator_id = @fk_indicator_id
			group by rd.fk_indicator_id, rd.Datum

end
GO
