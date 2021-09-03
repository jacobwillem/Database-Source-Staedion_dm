SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE PROCEDURE[dbo].[sp_load_kpi_herstructurering](
  @peildatum date = '20210722'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_herstructurering] '20210722'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures
		declare @fk_indicator_id as smallint
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%personeelslasten%'

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 


################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id smallint

		set	@start = current_timestamp

--------------------------------------------------------------------------------------------------------
	-- 1029 Eigen dienst - ∆ werkdagen vanaf order gegund tot order openstaand op peildatum

	IF @peildatum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
		BEGIN
		select @fk_indicator_id = 2700
		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

		with
			[Eenheden] as 
				( 
						SELECT  distinct [FT clusternr], [FT clusternaam]
						FROM
						staedion_dm.Eenheden.Eigenschappen 
						WHERE   @peildatum BETWEEN Ingangsdatum
									AND Einddatum
								OR @peildatum >= Ingangsdatum
								AND Einddatum IS NULL
								and [FT clusternr] is not null
				),

			Details as(

						SELECT Waarde = FORMAT(COUNT([Eenheidnummer]), 'D0')
							  ,Project
							  ,[Project startdatum] = FORMAT([Project startdatum], N'yyyy-MM-dd')
							  ,Clusternummer
							  ,Cluster = [Clusternummer] + ' ' + [FT clusternaam]
							  ,[Project einddatum] = iif(max([Project einddatum]) is not null, FORMAT(max([Project einddatum]), N'yyyy-MM-dd'), 'Onbekend/NVT')
							  ,[Redelijk voorstel] = coalesce(FORMAT(max([Brief 4 redelijk voorstel verzenddatum]), N'yyyy-MM-dd'), 'Onbekend/NVT')
							  ,[Akkoordpercentage] = FORMAT(cast(SUM(iif(Akkoord = 'Ja', 1, 0)) as float) / cast(COUNT([Eenheidnummer]) as float), 'P0')
							  ,[Akkoordrespons] = FORMAT(cast(SUM(iif(Akkoord = 'Wacht op antwoord', 0, 1)) as float) / cast(COUNT([Eenheidnummer]) as float), 'P0')
							  ,[Uitvoering startdatum] = coalesce(FORMAT(max([Uitvoering startdatum]), N'yyyy-MM-dd'), 'Onbekend/NVT')
							  ,[Logeerwoningen] = FORMAT(SUM(iif(Logeerwoning = 'Ja', 1, 0)), 'D0')
							  ,[Terugkeer] = FORMAT(SUM(iif(Terugkeer = 'Ja', 1, 0)), 'D0')
						  FROM [empire_staedion_data].[sharepoint].[HerstructureringHuurderslijst]
							left outer join Eenheden
								on Clusternummer = [FT clusternr]
						  where [Is verwijderd] = 0
						  group by Project, [Project startdatum], Clusternummer, [FT clusternaam])

			insert into [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						,Clusternummer
						--,[fk_eenheid_id]
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]
						)

			select		 [Datum]				= @peildatum
						,[Waarde]				
						,[Laaddatum]			= getdate()
						,[Omschrijving]			=   Project + '; ' +
													[Project startdatum] + '; ' +
													Cluster + '; ' +
													'Einddatum: ' + [Project einddatum] + '; ' +
													'Redelijk voorstel: ' + [Redelijk voorstel] + '; ' +
													Akkoordpercentage + ' akkoord; ' +
													Akkoordrespons + ' respons; ' +
													'Start uitvoering: ' + [Uitvoering startdatum] + '; ' +
													'Logeerwoningen: ' + Logeerwoningen + '; ' +
													'Terugkeer: ' + Terugkeer
						,@fk_indicator_id 
						,[Clusternummer]
			from		 [Details];
			
		
		
		  -- Samenvatting opvoeren tbv dashboards
			delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date));

			insert into Dashboard.[Realisatie] (
				fk_indicator_id,
				Datum,
				Waarde,
				Laaddatum
				)
				select det.fk_indicator_id, cast(getdate() as date), sum([Waarde]*1.00), getdate()
				from Dashboard.[RealisatieDetails] det
				where det.fk_indicator_id = @fk_indicator_id and det.Datum between dateadd(d, 1-day(cast(getdate() as date)), cast(getdate() as date)) and eomonth(cast(getdate() as date))
				group by det.fk_indicator_id;
		END


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
