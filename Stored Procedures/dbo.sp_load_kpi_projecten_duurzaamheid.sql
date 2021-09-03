SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE[dbo].[sp_load_kpi_projecten_duurzaamheid](
  @peildatum date = '20191231', @indicator nvarchar(255), @ingreep nvarchar(255)
)
as
/* #################################################################################################################
Procedure wordt gebruikt voor indicatoren 501, 503 en 504

exec staedion_dm.[dbo].[sp_load_kpi_projecten_duurzaamheid] '20200131', @LoggenDetails=1
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%hr-toestel%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint
	declare @LoggenDetails bit = 1

	set	@start =current_timestamp

	-- parameter @indicator bevat de selectiestring voor de juiste indicator inclusief wildcards bv '%hr-toestel%'
	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like @indicator

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

			INSERT INTO [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,[fk_indicator_id]
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum]			= w.[Datum gereed]
						,[Waarde]			= w.[Teller]
						,[Laaddatum]		= getdate()
						,[Omschrijving]		= w.Projectnummer + ' ; ' + w.Eenheid + ' ; ' + o.Straatnaam + ' ' + trim(o.Huisnr_ + o.Toevoegsel) + ' ; ' + o.Postcode + ' ; ' + o.Plaats
						,[fk_indicator_id]	= @fk_indicator_id
			from		 [staedion_dm].[Projecten].[WerksoortenDuurzaamheid] w
			inner join	 [empire_data].[dbo].[vw_lt_mg_oge] o on w.Eenheid = o.[Nr_]
			inner join	 [empire_data].[dbo].[staedion$type] t on o.[Type] = t.[Code]
			-- de parameter @ingreep bevat het soort ingreep bv 'HR-toestel'
			where	     w.[Soort ingreep] = @ingreep -- HR-toestel, HR-Glas, PV-paneel
			and			 w.[Status] = 'TECH.GER' -- Status technisch gereed
			and			 w.[Datum gereed] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
			and		     (o.[Einde exploitatie]  = '1753-01-01' or  o.[Einde exploitatie]  > @peildatum)
			and		     (o.[Begin exploitatie] <> '1753-01-01' and o.[Begin exploitatie] <= @peildatum)
			and			 o.[Common Area] = 0 and o.mg_bedrijf = 'Staedion'
			and			 t.[Analysis Group Code] in ('WON ZELF', 'WON ONZ') -- Woning
			and			 left(o.Nr_, 4) = 'OGEH'
		end 
		
  -- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, avg([Waarde]*1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id = @fk_indicator_id and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
		group by det.fk_indicator_id

	set		@finish = current_timestamp
	
 
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish

	set		@finish = current_timestamp
	
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish
					
END TRY

BEGIN CATCH

	set		@finish = current_timestamp

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT	ERROR_PROCEDURE() 
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE() 
		


END CATCH

GO
