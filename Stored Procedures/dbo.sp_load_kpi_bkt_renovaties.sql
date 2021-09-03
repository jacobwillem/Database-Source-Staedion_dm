SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_load_kpi_bkt_renovaties](
	@peildatum date = '20191231'
)
as
/* #################################################################################################################
20210122 JvdW - overheel 2020 blijken er dubbele tellingen in te zitten

exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200131'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200229'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200331'
exec staedion_dm.[dbo].sp_load_kpi_bkt_renovaties '20200430'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200531'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200630'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200731'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200831'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20200930'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20201031'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20201130'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties] '20201231'

--------------------------------------------------------------------------------------
-- select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
declare @fk_indicator_id as smallint
select @fk_indicator_id = id from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%uitgevoerde%BKT%renovaties%'
select @fk_indicator_id

select E.bk_nr_, D.*
FROM staedion_dm.Dashboard.[RealisatieDetails] as D
left outer join empire_Dwh.dbo.eenheid as E
on D.fk_eenheid_id = E.id
WHERE YEAR(Datum) = 2020
	AND month(Datum) <= 12
	and fk_indicator_id =  @fk_indicator_id
	--and Waarde = 1
	and fk_eenheid_id in (select id from empire_dwh.dbo.eenheid 
			where bk_nr_ in ('OGEH-0003768','OGEH-0004354','OGEH-0004835'
			,'OGEH-0005242','OGEH-0017191','OGEH-0019427','OGEH-0020817'
			,'OGEH-0021600','OGEH-0021602','OGEH-0027008','OGEH-0027664'
			,'OGEH-0031800','OGEH-0042565','OGEH-0043068','OGEH-0053376'
			,'OGEH-0057353')
	--and bk_nr_ = 'OGEH-0004354'
	)
order by 1, Waarde desc

except
select	distinct Eenheidnr,count(distinct [BKT groep])
FROM staedion_dm.Onderhoud.[BKT renovaties - gereedgemeld]
WHERE year(Datum) = 2020
group by Eenheidnr
--------------------------------------------------------------------------------------
-- wissen oude regels
delete
--into empire_staedion_data.bak.RealisatieDetails_20210122_303
FROM staedion_dm.Dashboard.[RealisatieDetails]
WHERE fk_indicator_id =  303

################################################################################################################# */

begin try

	--set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id as smallint

	set	@start = current_timestamp

	select @fk_indicator_id = max(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%uitgevoerde%BKT%renovaties%'

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
	-- JvdW zeker zijn dat stand van 2020 niet wordt overschreven
	and year(datum) >= 2021

	drop table If exists #hulp
	;
	with cte_alles as 
	(SELECT	OmschrijvingInclSjabloon = [BKT groep] + ' ' +[Eenheidnr] + ' ; '+ [Adres]+ ' ; '+ [Onderhoudsverzoek] + ' ; ' +[Sjablooncode taak]
			,UniekeCombi = [BKT groep] + ' ; '+[Eenheidnr] 
			,Eenheidnr
			,[BKT groep]
			,[Sjablooncode taak]
			,Datum
			,[sleutel eenheid]
			,Volgnr = row_number() over (partition by Eenheidnr,[BKT groep] order by Datum)
			--,ff1 = lag([Sjablooncode taak]) over (partition by Eenheidnr,[BKT groep],[Sjablooncode taak] order by Datum)
			--,ff2 = lag([Sjablooncode taak]) over (partition by Eenheidnr,[BKT groep] order by [Sjablooncode taak])
				-- select top 10 * 
	FROM staedion_dm.Onderhoud.[BKT renovaties - gereedgemeld]
	WHERE year(Datum) >= 2020
	)select *
	into	#hulp
	from	cte_alles
	--where Eenheidnr = 'OGEH-0004354' 
	;

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		,[fk_eenheid_id]
		)
		SELECT Datum
			   ,Waarde = iif(Volgnr = 1,1,0)  -- dubbele regel telt tweede keer niet mee
			   ,Laaddatum = getdate()
			   ,Omschrijving = iif(Volgnr = 1, OmschrijvingInclSjabloon, OmschrijvingInclSjabloon + ' (dubbel deze periode)')
		       ,@fk_indicator_id
			   ,[sleutel eenheid]
					 -- select top 10 * 
		FROM #hulp as HULP
		WHERE HULP.Datum BETWEEN dateadd(d, 1 - day(@peildatum), @peildatum)
									AND @peildatum
		and   not exists 
				(select 1 
				from   [Dashboard].[RealisatieDetails] as ORIG
				where  ORIG.[fk_eenheid_id] = HULP.[sleutel eenheid]
				and    ORIG.[Waarde] = 1
				and    ORIG.[Omschrijving] like '%'+HULP.[BKT groep] + '%'
				and    ORIG.Datum between DATEFROMPARTS(year(@peildatum),1,1)
						AND dateadd(d, 0 - day(@peildatum), @peildatum)
				)
		-- JvdW zeker zijn dat stand van 2020 niet wordt overschreven
		and year(datum) >= 2021
		;
	insert into [Dashboard].[RealisatieDetails] (
			[Datum]
			,[Waarde]
			,[Laaddatum]
			,[Omschrijving]
			,fk_indicator_id
			,[fk_eenheid_id]
			)
		SELECT Datum
			   ,Waarde =  0 -- Telt niet meer mee - komt in vorige periodes al voor
			   ,Laaddatum = getdate()
			   ,Omschrijving = OmschrijvingInclSjabloon + ' (kwam al voor in een vorige periode)'
		       ,@fk_indicator_id
			   ,[sleutel eenheid]
					 -- select top 10 * 
		FROM #hulp as HULP
		WHERE HULP.Datum BETWEEN dateadd(d, 1 - day(@peildatum), @peildatum)
									AND @peildatum
		and    exists 
				(select 1 
				from   [Dashboard].[RealisatieDetails] as ORIG
				where  ORIG.[fk_eenheid_id] = HULP.[sleutel eenheid]
				and    ORIG.[Waarde] = 1
				and    ORIG.[Omschrijving] like '%'+HULP.[BKT groep] + '%'
				and    ORIG.Datum between DATEFROMPARTS(year(@peildatum),1,1)
						AND dateadd(d, 0 - day(@peildatum), @peildatum)
				)

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

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
		select object_name(@@procid), @start, @finish

end try

begin catch

	set	@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
		select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message() 

end catch

GO
