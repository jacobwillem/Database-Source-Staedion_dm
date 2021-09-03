SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg](
  @peildatum date = '20191231', @onderwerp nvarchar(100), @filter nvarchar(100)
)
as
/* #################################################################################################################
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200131', '%eigen%dienst%EKG%', 'Eigen dienst'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200131', '%derden%EKG%',  'Extern'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200229', '%eigen%dienst%EKG%', 'Eigen dienst'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200229', '%derden%EKG%', 'Extern'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200331', '%eigen%dienst%EKG%', 'Eigen dienst'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200331', '%derden%EKG%','Extern'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200430', '%eigen%dienst%EKG%', 'Eigen dienst'
exec staedion_dm.[dbo].[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '20200430', '%derden%EKG%', 'Extern'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
declare @fk_indicator_id as smallint
select @fk_indicator_id = min(id) from [Dashboard].[Indicator] where lower([Omschrijving]) like '%eigen%dienst%EKG%'
select * from [Dashboard].[Indicator] where id = @fk_indicator_id
select fk_indicator_id,  max(Datum), avg(waarde*1.00),count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id between 1000 and 1006 and year(datum) = 2020 and month(datum) = 1 group by fk_indicator_id
select fk_indicator_id,  max(Datum), avg(waarde*1.00),count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id between 1000 and 1006 and year(datum) = 2020 and month(datum) = 1 group by fk_indicator_id
----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210201 JvdW: jaargang 2020 ongemoeid laten - vandaar extra conditie toegevoegd bij delete en insert
################################################################################################################# */
begin try

	set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint
	declare @AantalRecords as int
	declare @Bericht as nvarchar(255)
	DECLARE @Bron nvarchar(100) =  OBJECT_NAME(@@PROCID)
	set	@start =current_timestamp

	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like @onderwerp

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
	-- JvdW 20210201
	and year(Datum) >= 2021
	;
	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,Waarde
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		,[fk_eenheid_id]
		,Teller
		,Noemer)
		select Datum
			,iif([Aantal benodigde bezoeken volgens klant] = '1 keer', 1, 0) 
			,getdate()
			,Reparatieverzoeknr
			,@fk_indicator_id
			,[sleutel eenheid]
			,iif([Aantal benodigde bezoeken volgens klant] = '1 keer', 1, 0) 
			,1
		from staedion_dm.[Klanttevredenheid].DagelijksOnderhoud_Handmatig
		where Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum and
		(Bron = @filter or @filter = '')
					-- JvdW 20210201
		and year(Datum) >= 2021
		
	SET @AantalRecords = @@rowcount;	
	SET @Bericht = 'Stap: ' + replace(@Onderwerp,'%',' ' ) + ' - records: ';
	SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
	EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht, @Bron;

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
		select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		-- JvdW 20210201
		and year(Datum) >= 2021
		group by det.fk_indicator_id

	SET @AantalRecords = @@rowcount;	
	SET @Bericht = 'Stap: realisatie ' + replace(@Onderwerp,'%',' ' ) + ' - records: ';
	SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
	EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht, @Bron;

	set	@finish = current_timestamp
	
	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
		select @bron, @start, @finish

end try

begin catch

	set	@finish = current_timestamp

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT	ERROR_PROCEDURE() 
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE() 
end catch
GO
