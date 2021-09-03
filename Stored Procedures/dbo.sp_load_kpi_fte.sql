SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE[dbo].[sp_load_kpi_fte] (
	@peildatum date = '20210131'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_fte] '20210131'
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
	-- 1800 Aantal vaste FTE (ultimo)
	select @fk_indicator_id = 1800

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id  
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
					and year(datum)>=2021 -- pas vanaf 2021 in laten gaan

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		)
		SELECT			@peildatum
						,Waarde = sum(FTE) - sum([Tijdelijke formatie]*FTE)
						,Laaddatum = GETDATE()
						,Omschrijving = case when sum(coalesce([Tijdelijke formatie]*FTE,0)) = 0
												then format(Kostenplaats, 'F0') + ' ; ' + Afdeling + ' ; ' + Functie + ' ; ' + format(sum(coalesce(FTE,0)),'N1' )
												else format(Kostenplaats, 'F0') + ' ; ' + Afdeling + ' ; ' + Functie + ' ; ' + format(sum(coalesce(FTE,0)),'N1' )
														+ ' ; ' + ' minus formatie tijdelijk: ' + format(sum(coalesce([Tijdelijke formatie]*FTE,0)),'N1' )
										end
						,@fk_indicator_id											
		FROM	 staedion_dm.Medewerker.[fn_Werknemers] (@peildatum)
		where	 werknemersgroep = 'werknemers'
		and		 convert(date,Laaddatum) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
		AND		year(@peildatum)>=2021 -- pas vanaf 2021 in laten gaan
		GROUP BY Kostenplaats, Afdeling, Functie, Laaddatum
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

	-----------------------------------------------------------------------------------------------------------
	-- 1810 Aantal tijdelijke FTE (ultimo)
	select @fk_indicator_id = 1810

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id  
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
					and year(datum)>=2021 -- pas vanaf 2021 in laten gaan

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		)
		SELECT			@peildatum
						, Waarde = sum([Tijdelijke formatie]*FTE)
						,Laaddatum = GETDATE()
						,Omschrijving = format(Kostenplaats, 'F0') + ' ; ' + Afdeling + ' ; ' + Functie + ' ; ' + 'formatie tijdelijk: ' + format(sum(coalesce([Tijdelijke formatie]*FTE,0)),'N1' )	
						,@fk_indicator_id	
		FROM	 staedion_dm.Medewerker.[fn_Werknemers] (@peildatum)
		where	 werknemersgroep = 'werknemers'
		and		 convert(date,Laaddatum) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
		AND		 year(@peildatum)>=2021 -- pas vanaf 2021 in laten gaan
		and		 nullif([Tijdelijke formatie],0) is not null
		GROUP BY Kostenplaats, Afdeling, Functie, Laaddatum
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

	
	-----------------------------------------------------------------------------------------------------------
	-- 1820 Aantal FTE (ultimo)
	select @fk_indicator_id = 1820

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id  
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
					and year(datum)>=2021 -- pas vanaf 2021 in laten gaan

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		)
		SELECT			@peildatum
						, Waarde = sum(FTE) 
						,Laaddatum = GETDATE()
						,Omschrijving = format(Kostenplaats, 'F0') + ' ; ' + Afdeling + ' ; ' + Functie + ' ; ' + 'aantal fte totaal: ' + format(sum(coalesce(FTE,0)),'N1' )
						,@fk_indicator_id	
		FROM	 staedion_dm.Medewerker.[fn_Werknemers] (@peildatum)
		where	 werknemersgroep = 'werknemers'
		and		 convert(date,Laaddatum) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
		AND		 year(@peildatum)>=2021 -- pas vanaf 2021 in laten gaan
		GROUP BY Kostenplaats, Afdeling, Functie, Laaddatum
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


-----------------------------------------------------------------------------------------------------------
	-- 1830 Aantal externe FTE (ultimo)
	select @fk_indicator_id = 1830

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id  
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
					and year(datum)>=2021 -- pas vanaf 2021 in laten gaan

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		)
		SELECT			@peildatum
						, Waarde = sum(FTE) 
						,Laaddatum = GETDATE()
						,Omschrijving = case when sum(coalesce([Tijdelijke formatie]*FTE,0)) = 0 
												then format(Kostenplaats, 'F0') + ' ; ' + Afdeling + ' ; ' + Functie + ' ; ' + format(sum(coalesce(FTE,0)),'N1' )
												else format(Kostenplaats, 'F0') + ' ; ' + Afdeling + ' ; ' + Functie + ' ; ' + format(sum(coalesce(FTE,0)),'N1' )
														+ ' ; ' + 'waarvan formatie tijdelijk: ' + format(sum(coalesce([Tijdelijke formatie]*FTE,0)),'N1' )
										end	
						,@fk_indicator_id	
		FROM	 staedion_dm.Medewerker.[fn_Werknemers] (@peildatum)
		where	 werknemersgroep = 'externen'
		and		 convert(date,Laaddatum) between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
		AND		 year(@peildatum)>=2021 -- pas vanaf 2021 in laten gaan
		GROUP BY Kostenplaats, Afdeling, Functie, Laaddatum
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
