SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Dashboard].[sp_load_wrapper_dashboard_kpis]
(@AlleenUitTeVoerenCommandosTonen bit = 1)
AS

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N''Met deze procedure worden alle procedures aangeroepen uit staedion_dm.dashboard.indicator, op voorwaarde dat:
- naam procedure_naam is opgevoerd
- veld procedure_actief = 1
- 
- 
Daarbij wordt als volgt de historie ook meegenomen:
- @VerversVanaf1Jan: als deze op 1 staat wordt voor elke maand in het verleden van dit jaar een refresh uitgevoerd
- @VerversAantalMaanden: als vorige op 0 staat en deze op n-maanden wordt er voor de laatste n-maanden een refresh uitgevoerd
		,@level0type = N'SCHEMA'
       ,@level0name = 'DatabaseBeheer'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_master VOORSTEL';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------


############################################################################################################################# */


begin
	DECLARE @indicatorid INT,
			@frequentie INT,
			@berekeningswijze INT,
			@procedure NVARCHAR(128),
			@argument VARCHAR(200),
			@sql NVARCHAR(1000),
			@peildatum DATE,
			@VerversVanaf1Jan BIT, 
			@VerversAantalMaanden SMALLINT;

	set nocount on
		
	-- ophalen peildata, nu ingesteld op lopende maand en 2 voorgaande maanden
	drop table if exists ##dat 

	-- standaard laatste 13 maanden genereren, later vergelijken met de instelling per indicator in de betreffende tabel
	;WITH dat (peildatum)
	AS (SELECT IIF(mnd.i = 0,
				   CONVERT(DATE, DATEADD(m, -mnd.i, GETDATE())),
				   EOMONTH(CONVERT(DATE, DATEADD(m, -mnd.i, GETDATE()))))
		FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13)) mnd (i) )
	SELECT dat.peildatum, 		   
			IIF(dat.peildatum = EOMONTH(dat.peildatum), 1, 0) volledig,
			ROW_NUMBER() OVER (ORDER BY dat.peildatum DESC) AS volgnr,
			(SELECT MAX(YEAR(peildatum)) FROM dat) AS jaar
	INTO ##dat
	FROM dat;

	-- cursor voor indicatoren 
	declare kpi cursor for
		select ind.id, fk_frequentie_id frequentie, ind.fk_berekeningswijze_id, ind.procedure_naam [procedure], ind.procedure_argument, ind.verversen_vanaf_1_1, ind.aantal_maanden_te_verversen
		from [Dashboard].[Indicator] ind
		where isnull(ind.procedure_naam, '') <> '' and
		ind.procedure_actief = 1
		-- TEST
		-- AND ind.id = 200
		order by ind.id desc

	open kpi

	fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument, @VerversVanaf1Jan, @VerversAantalMaanden
	
	while @@fetch_status = 0
	begin
		
		-- cursor voor peildata
		DECLARE peildatum cursor for
				SELECT DAT.peildatum
				FROM ##dat AS DAT
				JOIN staedion_dm.dashboard.indicator AS IND
				ON IND.id = @indicatorid
				WHERE DAT.volgnr <= @VerversAantalMaanden
				OR (YEAR(DAT.peildatum) = DAT.jaar AND @VerversVanaf1Jan = 1)
				ORDER by peildatum

						open peildatum

						fetch next from peildatum into @peildatum

						while @@fetch_status = 0
						begin
							-- als @berekeningwijze = 2, dan peildatum altijd wijzigen in laatste van de maand, anders peildatum ongewijzigd doorgeven aan procedure
							set @sql = 'exec [' + @procedure + '] ''' + convert(varchar(10), iif(@berekeningswijze = 2, eomonth(@peildatum), @peildatum), 120) + '''' + isnull(@argument, '')
				
							IF @AlleenUitTeVoerenCommandosTonen = 1 
								BEGIN 
									PRINT @sql 
								END

							IF @AlleenUitTeVoerenCommandosTonen = 0 
								BEGIN 
									EXEC (@sql)
								END
	
							fetch next from peildatum into @peildatum
						end

						close peildatum

						deallocate peildatum

			fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument, @VerversVanaf1Jan, @VerversAantalMaanden

	end

	close kpi

	deallocate kpi
end
GO
