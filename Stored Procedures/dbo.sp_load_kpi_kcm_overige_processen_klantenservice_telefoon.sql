SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE[dbo].[sp_load_kpi_kcm_overige_processen_klantenservice_telefoon](
	@peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_kcm_overige_processen_klantenservice_telefoon] '20200229'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = 1206
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = 1206
delete from Dashboard.[Realisatie] where fk_indicator_id = 1206
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = 1206
----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210201 JvdW: jaargang 2020 ongemoeid laten - vandaar extra conditie toegevoegd bij delete en insert
20210607 PP: Clusternummer toegevoegd aan output
################################################################################################################# */

begin try

	set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint

	set	@start = current_timestamp

	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%Klantenservic%telefoon%'

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
	-- JvdW 20210201
	and year(Datum) >= 2021
	;
	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		,[Clusternummer]
		--,[fk_eenheid_id]
		--,[fk_contract_id]
		--,[fk_klant_id]
		--,[Teller]
		--,[Noemer]
		)
		select kcm.[INGEVULDE GEGEVENS] Datum, 
			convert(int, kcm.[Welk rapportcijfer geeft u voor het telefonische contact met onz]) Waarde, 
			getdate(), 
			kcm.[Bouwblok] + ' ; ' + kcm.[Bouwbloknaam] + ' ; ' + cast(cast(kcm.[InteractieID] as int) as varchar) + ' ; ' + kcm.[Naam behandelend medewerker Staedion] [Omschrijving],
			@fk_indicator_id, convert(nvarchar(7),[clusternr])
		from empire_staedion_data.kcm.STN420_Ingevulde_gegevens kcm 
		where isnumeric(kcm.[Welk rapportcijfer geeft u voor het telefonische contact met onz]) = 1 and
		convert(date,kcm.[INGEVULDE GEGEVENS]) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		-- JvdW 20210201
		and year(convert(date,kcm.[INGEVULDE GEGEVENS])) >= 2021
		
	-- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
	-- JvdW 20210201
	and year(Datum) >= 2021
	;
	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, avg([Waarde] * 1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		-- JvdW 20210201
		and year(Datum) >= 2021
		group by det.fk_indicator_id

	set	@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
		select object_name(@@procid), @start, @finish

end try

begin catch

	set	@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
		select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message() 

end catch

GO
