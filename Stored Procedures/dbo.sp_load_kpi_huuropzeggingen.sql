SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE[dbo].[sp_load_kpi_huuropzeggingen] (
	@peildatum date = '20210731'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_huuropzeggingen] '20210731'
select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
	declare @fk_indicator_id as smallint
	select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%fte%'
	select @fk_indicator_id

select max(Datum), sum(Waarde), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id in (@fk_indicator_id) and  year(datum) =2020 and month(datum) = 12
select max(Datum), sum(Waarde), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id in (@fk_indicator_id) and  year(datum) =2020 and month(datum) = 12

select I.omschrijving, month(Datum), sum(Waarde),sum(Teller),sum(Noemer) 
from staedion_dm.Dashboard.[RealisatieDetails] as D
join staedion_dm.Dashboard.[Indicator] as I
on I.id = D.fk_indicator_id
where D.fk_indicator_id in (1800,1810,1820)
and  year(D.datum) =2021 and month(D.datum) = 1
group by I.omschrijving, month(D.Datum)
order by 2,1
;
select * from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = 1800 and  year(datum) =2021 and month(datum) = 1
select * from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = 1800 and  year(datum) =2021 and month(datum) = 1

----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210201 JvdW Laaddatum vervangen door convert(date,Laaddatum)
20210414 PP Details op kostenplaats, afdeling, functie, laaddatum niveau tbv HR formatie rapport, toevoeging van niet-zichtbare kpi 1830 Aantal externe FTE (ultimo)
################################################################################################################# */

begin try

	set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint

	set	@start = current_timestamp

-----------------------------------------------------------------------------------------------------------
	-- 120 Aantal huuropzeggingen
	select @fk_indicator_id = 120

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
		,fk_contract_id
		,Clusternummer
		,[Detail_01]
		,[Detail_02]
		)

		SELECT			 [d_opzegging].datum
						,Waarde = 1
						,Laaddatum = GETDATE()
						,Omschrijving = Eenheid.descr + ' ; ' + staedion_verhuurteam
						,@fk_indicator_id
						,[contract].fk_eenheid_id
						,[contract].id
						,eenheid.pmc_nr
						,[Datail_01] = Eenheid.descr
						,[Detail_02] = staedion_verhuurteam
		FROM [empire_dwh].[dbo].[d_opzegging]
		left outer join empire_dwh.dbo.[contract] on [d_opzegging].[fk_contract_id] = [contract].[id]
		left outer join empire_dwh.dbo.eenheid on [contract].fk_eenheid_id = [eenheid].id
		where bk_nr_ is not null
			and bk_nr_ not like 'MTEH%'
			and	convert(date,datum) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
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
