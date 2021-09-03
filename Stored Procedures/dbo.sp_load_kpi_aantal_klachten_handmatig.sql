SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create  procedure [dbo].[sp_load_kpi_aantal_klachten_handmatig](
  @peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_aantal_klachten_handmatig] '20200630'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures

declare @fk_indicator_id as smallint
select min(id),fk_frequentie_id from  [Dashboard].[Indicator] where omschrijving = 'Aantal klachten' group by fk_frequentie_id
select * from staedion_dm.dashboard.frequentie
select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 

----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210713 JvdW: Toegevoegd in overleg met Martijn

-- Query vanuit Postgres ingelezen in 
select * 
into TS_data.iris.MeldingenIris
from FF...FF

-- Query 
SELECT subj.description as "Categorie Iris",
       chnl.description as Kanaal,
       stat.label as "Status afhandeling" ,
       DATE(cas.created_datetime) "Datum" ,
       count(distinct cas.id) as "Aantal"
-- select cas.*       
FROM vault.facts.fac_iris4_case cas
INNER JOIN vault.dimensions.dim_iris4_direction dir ON cas.direction_id = dir.kubion_id
AND dir.description = 'Huurder'
INNER JOIN vault.dimensions.dim_iris4_channel chnl ON cas.channel_id = chnl.kubion_id --AND chnl.description = 'Telefoon'
INNER JOIN vault.dimensions.dim_iris4_subject subj ON cas.subject_id = subj.kubion_id --AND subj.description = 'DAGEONDERH Reparatieverzoek'
INNER JOIN vault.dimensions.dim_iris4_casestatus stat ON cas.status_id = stat.kubion_id --AND stat.label = 'Afgehandeld'
INNER JOIN vault.dimensions.dim_iris4_autuser aut ON cas.created_user_id = aut.kubion_id
INNER JOIN vault.facts.fac_iris4_indexobject idobj ON cas.kubion_id = idobj.case_id
INNER JOIN vault.dimensions.dim_empire_customers cust ON cust.contact_no = idobj.relation_id
AND cust.DATE_TO = '2199-12-31 23:59:59.999'
WHERE cas.created_datetime > '2021-01-01 00:00:00.999' --CURRENT_DATE - Interval '2 day'
and (subj.description like 'KLACLABEZW%'
     or subj.description like 'PLANONDERH Vraag/klacht%'
     or subj.description like 'SOCMEL&BEH%')
and subj.description <> 'SOCMEL&BEH Welkomstgesprek'
group by subj.description,
         chnl.description,
         stat.label,
         DATE(cas.created_datetime)
--EXTRACT(DAY FROM TIMESTAMP cas.created_datetime ),,EXTRACT(DAY FROM TIMESTAMP cas.created_datetime )
 
################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start =current_timestamp
		
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where omschrijving = 'Aantal klachten'
		
  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete 
			from	Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 
			and		datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
			-- JvdW 20210201
			and year(Datum) >= 2021
			;
			INSERT INTO [Dashboard].[RealisatieDetails]
						([Datum]
						,[Waarde]
						,[Laaddatum]
						,[Omschrijving]
						,fk_indicator_id
						--,[fk_contract_id]
						--,[fk_klant_id]
						--,[Teller]
						--,[Noemer]	
						)

			SELECT  Datum, sum(Aantal), getdate(),[Categorie Iris], @fk_indicator_id
			FROM	TS_data.iris.MeldingenIris
			WHERE   datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
			and year(Datum) >= 2021
			group by Datum,[Categorie Iris]

		end 
		
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
