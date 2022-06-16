SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [bak].[sp_load_kpi_huurderving] (
	@peildatum date = '20210731'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_huurderving] '20210731'

################################################################################################################# */

begin try

	set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint

	set	@start = current_timestamp

-----------------------------------------------------------------------------------------------------------
	-- 2640 Huurderving
	select @fk_indicator_id = 2640

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id  
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
					and year(datum)>=2021 -- pas vanaf 2021 in laten gaan

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		,fk_eenheid_id
		,Clusternummer
		)

				select
						 [Datum]							= convert(date,dl.datum)
						,[Derving netto]					= dl.dervingnetto
						,[Laaddatum]						= GETDATE()
						,[Omschrijving]						= een.Eenheidnummer + ' ' + een.Adres + ', ' + een.Plaats + ' ; ' +
																e.[Type description] + ' ; ' +
																vht.staedion_verhuurteam + ' ; ' +
																'Heeft leegstand ultimo maand: ' + case when isnull(dl.dt_einde,'99991231') >= dl.datum then 'Ja' else 'Nee' end + ' ; ' +
																iif(dl.dt_ingang is null, '', FORMAT(convert(date,dl.dt_ingang), 'yyyy-MM-dd')) + ' ; ' +
																iif(dl.dt_einde is null, '', FORMAT(convert(date,dl.dt_einde), 'yyyy-MM-dd')) + ' ; ' +
																cast(DATEDIFF(dd,dl.dt_ingang, isnull(dl.dt_einde,getdate())) as varchar) + ' dagen ; ' +
																rl.descr + ' ; ' +
																iif(dl.dt_ingang_reden is null, '', FORMAT(convert(date,dl.dt_ingang_reden), 'yyyy-MM-dd')) + ' ; ' +
																iif(dl.dt_einde_reden is null, '', FORMAT(convert(date,dl.dt_einde_reden), 'yyyy-MM-dd'))
						,@fk_indicator_id
						,dl.fk_eenheid_id
						,[Clusternummer]					= [FT-Clusternummer]

					from empire_dwh.dbo.d_leegstand as dl
					left join empire_dwh.dbo.redenleegstand as rl on
						rl.id = dl.fk_redenleegstand_id
					left outer join [staedion_dm].[Algemeen].[Eenheid] as een on
						een.Sleutel = dl.fk_eenheid_id
					left outer join empire_dwh.dbo.eenheid as vht on
						vht.bk_nr_ = een.Eenheidnummer
					left outer join [empire_data].[dbo].[Staedion$OGE] e on
						e.[Nr_] = een.[Eenheidnummer]
					where rl.descr in ('Asbestsanering', 'Marktleegstand', 'Technische leegstand')
							and dl.fk_eenheid_id is not null
							and een.Eenheidnummer not like 'MTEH%'
							and	convert(date,dl.datum) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		;

	-- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, sum([Waarde] * 1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		group by det.fk_indicator_id



	set	@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding, Begintijd,Eindtijd)
		select object_name(@@procid),getdate(),  @start, @finish

end try

begin catch

	set	@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage, Begintijd, Eindtijd)
		select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message() , @start, @finish

end catch

GO
