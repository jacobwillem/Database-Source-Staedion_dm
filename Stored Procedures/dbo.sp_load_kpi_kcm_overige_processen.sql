SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_load_kpi_kcm_overige_processen] (@peildatum as date = '20191231') 

as
/* #################################################################################################################
exec staedion_dm.[dbo].[sp_load_kpi_kcm_overige_processen] '20200131'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_overige_processen] '20200229'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_overige_processen] '20200331'
	declare @fk_indicator_id as smallint
	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%dienstverlening - Overige processen'
	select @fk_indicator_id

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id

--delete from Dashboard.[Realisatie] where fk_indicator_id = 1200
--delete from Dashboard.[RealisatieDetails] where fk_indicator_id = 1200
----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210201 JvdW: jaargang 2020 ongemoeid laten - vandaar extra conditie toegevoegd bij delete en insert
20210607 PP: Clusternummer toegevoegd aan output
################################################################################################################# */

begin 
	
	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint

	set	@start = current_timestamp
	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%dienstverlening - Overige processen'

	exec [staedion_dm].[dbo].[sp_load_kpi_kcm_overige_processen_groenonderhoud] @peildatum
	exec [staedion_dm].[dbo].sp_load_kpi_kcm_overige_processen_bkt_renovaties @peildatum
	exec [staedion_dm].[dbo].sp_load_kpi_kcm_overige_processen_klantenservice_telefoon @peildatum
	exec [staedion_dm].[dbo].sp_load_kpi_kcm_overige_processen_planmatig_onderhoud @peildatum
	exec [staedion_dm].[dbo].sp_load_kpi_kcm_overige_processen_schoonmaakonderhoud @peildatum
	exec [staedion_dm].[dbo].sp_load_kpi_kcm_overige_processen_servicekosten @peildatum
	exec [staedion_dm].[dbo].sp_load_kpi_kcm_overige_processen_stookkosten @peildatum

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
		)
		select [Datum], 
			[Waarde], 
			[Laaddatum], 
			[Omschrijving],
			@fk_indicator_id,
			[Clusternummer]
		FROM [Dashboard].[RealisatieDetails]
		where  fk_indicator_id >= 1201 AND fk_indicator_id < 1300 
		and	[Datum] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		-- JvdW 20210201
		and year(Datum) >= 2021
	
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
end
GO
