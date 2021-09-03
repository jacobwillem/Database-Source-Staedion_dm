SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_load_kpi_bkt_renovaties_handmatig](
	@peildatum date = '20191231'
)
as
/* #################################################################################################################
20210129 JvdW - Nav overleg met Hailey, Youness, Leo, Andre, Jos
=> gerapporteerde BKT's over 2020 van 1044 kan niet kloppen, gaat iets mis in Empire
=> aantal van 984  (financieel afgewikkeld) moet worden aangehouden, op 30.000 (meerwerk) spoort dat ook goed met kosten A815340
= details uit PBI gehaald en via deze procedure in jaarplan gezet

exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200131'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200229'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200331'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200430'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200531'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200630'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200731'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200831'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20200930'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20201031'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20201130'
exec staedion_dm.[dbo].[sp_load_kpi_bkt_renovaties_handmatig] '20201231'

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
	and year(datum) = 2020

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		)
		SELECT [Laatste Datum]
			   ,Waarde = [BKT-teller]
			   ,Laaddatum = getdate()
			   ,Omschrijving = Omschrijving
		       ,@fk_indicator_id
				 -- select top 10 * 
		FROM  staedion_dm.Excel.Jaarplan_BKT_2020_OenV  as  HULP
		WHERE HULP.[Laatste Datum] BETWEEN dateadd(d, 1 - day(@peildatum), @peildatum)
									AND @peildatum
		and year(HULP.[Laatste Datum] ) = 2020
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

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
		select object_name(@@procid), @start, @finish

end try

begin catch

	set	@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
		select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message() 

end catch

GO
