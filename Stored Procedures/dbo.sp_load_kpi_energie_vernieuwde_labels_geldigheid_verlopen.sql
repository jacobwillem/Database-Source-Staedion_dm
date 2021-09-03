SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE procedure [dbo].[sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] (@peildatum date )
/**************************************************************************************************************
Door	MV
Doel	Conform berekeningswijze "CNS" in rapport van O&V

exec staedion_dm.[dbo].[sp_load_kpi_vernieuwde_energielabels]  '20200131'

declare @fk_indicator_id as smallint
select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) = 'aantal vernieuwde energielabels'
select max(Datum), avg(waarde),count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and year(datum) = 2020 and month(datum) =  1
select max(Datum), avg(waarde),count(*)  from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id

delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id
delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id 
**************************************************************************************************************/
as
begin
	set nocount on

	begin try 

		-- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @LoggenDetails bit = 1

		set	@start = current_timestamp
		
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like '%energielabels ivm geldigheid verlopen'

		-- loggen starten van ophalen gegevens

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], Begintijd, Eindtijd)
			select object_name(@@PROCID), @start, @finish

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
			;
				INSERT INTO [Dashboard].[RealisatieDetails] (
							  [Datum]
							 ,[Waarde]
							 ,[Laaddatum]
							 ,[Omschrijving]
							 ,[fk_indicator_id]
							 ,[fk_eenheid_id]
							 )
				--,[fk_contract_id]
				--,[fk_klant_id]
				--,[Teller]
				--,[Noemer]
				SELECT		  [Datum]			= iif(max(ELA.[Status label]) = 'Pre-label', max(ELA.[Opname data]), max(ELA.[Afmeld data]))
							 ,[Waarde]			= 1
							 ,[Laaddatum]		= getdate()
							 ,[Omschrijving]	= max(ELA.[Eenheidnummer] + '; ' + ELA.[Status label] + '; ' + ELA.[Deelvoorraad])
							 ,[fk_indicator_id]	= @fk_indicator_id
							 ,[fk_eenheid_id]	= ELA.[sleutel eenheid]
				-- select count(*), count(distinct ELA.[sleutel eenheid])
				FROM [Algemeen].[Vabi Energielabel eenheden] AS ELA JOIN empire_data.dbo.[Staedion$OGE] AS OGE
				ON OGE.Nr_ = ELA.Eenheidnummer
				JOIN empire_Data.dbo.[Staedion$type] AS TT
				ON TT.[Code] = OGE.[Type] AND TT.Soort = 0
				JOIN [Algemeen].[Energielabel verlopen] AS VAB
				ON VAB.eenheidnr = ELA.Eenheidnummer
				WHERE --eomonth(ELA.[Datum]) = eomonth(@peildatum) AND
				TT.[Analysis Group Code] = 'WON ZELF'
				AND (
						(eomonth(ELA.[Afmeld data]) = eomonth(@peildatum)) --'20200131'
					OR
						(ELA.[Status label] = 'Pre-label' AND eomonth(ELA.[Opname data]) = eomonth(@peildatum))
				)
				GROUP BY ELA.[sleutel eenheid]
		end 
		
		-- obv de details vullen we de totalen
		delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.[Realisatie] (fk_indicator_id, Datum, Waarde, Laaddatum )
			select @fk_indicator_id, @peildatum, sum(rd.waarde) / Count(*), getdate()
			from Dashboard.[RealisatieDetails] as rd
			where rd.Datum = @peildatum	and 
			rd.fk_indicator_id = @fk_indicator_id

		set	@finish = current_timestamp
	
		-- loggen stoppen van ophalen gegevens

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
			select object_name(@@PROCID), @start, @finish
	end try

	begin catch

		set	@finish = current_timestamp

		-- loggen opgetreden fout 
		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], TijdMelding, ErrorProcedure, ErrorNumber, ErrorLine, ErrorMessage)
			select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message()
	end catch

end
GO
