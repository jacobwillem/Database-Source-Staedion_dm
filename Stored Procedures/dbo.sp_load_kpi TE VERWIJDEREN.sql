SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi TE VERWIJDEREN]
as
/* ###############################################################################################################################
20211110 JvdW Welke statements worden uitgevoerd ?
20220202 JvdW in procedurenaam kun je nu ook ander schemanaam opgeven - [] moet je dan zelf in procedure_naam opnemen - in dit script weggehaald

############################################################################################################################### */
begin
	declare @indicatorid int, @frequentie int, @berekeningswijze int, @procedure nvarchar(1000), @argument varchar(1000), @sql nvarchar(4000), @peildatum date

	set nocount on
		
	-- ophalen peildata, nu ingesteld op lopende maand en 2 voorgaande maanden
	drop table if exists #dat_load_kpi 

	; with dat (peildatum)
	as (select iif(mnd.i = 0, convert(date, dateadd(m, -mnd.i, getdate())), eomonth(convert(date, dateadd(m, -mnd.i, getdate()))))
		from (values (0), (1), (2)) mnd(i))
	select dat.peildatum, iif(dat.peildatum = eomonth(dat.peildatum), 1, 0) volledig
	into #dat_load_kpi 
	from dat

	-- cursor voor indicatoren 
	declare kpi cursor for
		select ind.id, fk_frequentie_id frequentie, ind.fk_berekeningswijze_id, ind.procedure_naam [procedure], ind.procedure_argument
		from [Dashboard].[Indicator] ind
		where isnull(ind.procedure_naam, '') <> '' and
		ind.procedure_actief = 1
		-- TEST
		-- AND ind.id = 1300


		order by ind.id desc

	open kpi

	fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument
	
	while @@fetch_status = 0
	begin
		
		-- cursor voor peildata
		declare peildatum cursor for
			select dat.peildatum
			from #dat_load_kpi dat
			where dat.volledig = 1 or @frequentie < 3
			order by dat.peildatum

		open peildatum

		fetch next from peildatum into @peildatum

		while @@fetch_status = 0
		begin
			-- als @berekeningwijze = 2, dan peildatum altijd wijzigen in laatste van de maand, anders peildatum ongewijzigd doorgeven aan procedure
			--set @sql = 'exec [' + @procedure + '] ''' + convert(varchar(10), iif(@berekeningswijze = 2, eomonth(@peildatum), @peildatum), 120) + '''' + isnull(@argument, '')
			set @sql = 'exec ' + @procedure + ' ''' + convert(varchar(10), iif(@berekeningswijze = 2, eomonth(@peildatum), @peildatum), 120) + '''' + isnull(@argument, '')
		
			print @sql 
			--exec (@sql)

			fetch next from peildatum into @peildatum
		end

		close peildatum

		deallocate peildatum

		fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument

	end

	close kpi

	deallocate kpi
end
GO
