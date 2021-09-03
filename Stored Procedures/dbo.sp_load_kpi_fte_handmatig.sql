SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE[dbo].[sp_load_kpi_fte_handmatig](
	@peildatum date = '20191231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_fte_handmatig] '20200229'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
	declare @fk_indicator_id as smallint
	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%fte%'
	select @fk_indicator_id

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id in (@fk_indicator_id)
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id in (@fk_indicator_id)

select month(Datum), fk_indicator_id, avg(Waarde),sum(Teller),sum(Noemer) 
from staedion_dm.Dashboard.[RealisatieDetails]
where fk_indicator_id in (@fk_indicator_id)
and  year(datum) =2020 --and month(datum) = 3 
group by month(Datum), fk_indicator_id
order by 2,1
;

################################################################################################################# */

begin try

	set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint

	set	@start = current_timestamp

	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%fte%'

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id  
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		)
		-- nieuwe berekening
		select Datum =  F.datum
						,Waarde = sum(F.fte_ultimo) - sum(coalesce(F.tijdelijk,0))
						,Laaddatum = GETDATE()
						,Omschrijving = AFD.Hoofdafdeling + ' ; ' + coalesce(F.Subafdeling,'?') + ' ; ' + 'Minus formatie tijdelijk: ' + 
																format(sum(coalesce(F.tijdelijk,0)),'N0' )
						,@fk_indicator_id
				 -- select month(Datum), FTE = sum(fte_ultimo)
				 -- select * 
		FROM empire_Staedion_data.visma.f_fte_ultimo AS F
		JOIN [empire_staedion_data].[visma].[AfdelingStructuur] AS AFD
					 ON F.subafdeling = AFD.subafdeling
		WHERE F.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
		group by AFD.Hoofdafdeling, F.Subafdeling, F.datum
		;
	
	-- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, avg([Waarde] * 1.00), getdate()
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
