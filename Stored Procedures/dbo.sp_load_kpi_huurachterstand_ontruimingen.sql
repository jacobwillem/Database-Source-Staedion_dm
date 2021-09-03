SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE[dbo].[sp_load_kpi_huurachterstand_ontruimingen](
  @peildatum date
)
as
begin

	begin try

		-- eerst de details laden
		declare @fk_indicator_id as smallint, @start datetime = current_timestamp, @finish datetime
		select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where [Omschrijving] like '%ontruimingen%'
  
		-- verwijderen eerder opgehaalde data voor dezelfde periode (van 1e t/m laatste van de maand)
		delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.[RealisatieDetails](
			fk_indicator_id, 
			Datum,			-- Einddatum van contract
			Waarde,
			Omschrijving,
			Laaddatum,
			fk_contract_id)
			select
				@fk_indicator_id,
				aan.[Datum ontruiming],
				1,
				dwr.Dossiernr_ + ' ; ' + dwr.[Customer No_] + iif(enh.id is not null, ' ; ' + trim(enh.descr) + ' ; ' + enh.da_postcode + ' ; ' + enh.da_plaats, ''), 
				getdate(),
				con.id		
			from empire_data.dbo.Staedion$Aanzegging_ontruiming aan inner join empire_data.dbo.Staedion$Deurwaarderdossier dwr
			on aan.Dossiernr_ = dwr.Dossiernr_
			left outer join empire_dwh.dbo.eenheid enh
			on dwr.[Eenheidnr_] = enh.bk_nr_
			left outer join empire_dwh.dbo.[contract] con
			on dwr.[Customer No_] = con.fk_klant_id and dwr.Eenheidnr_ = con.bk_eenheidnr
			where aan.[Datum ontruiming] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum and
			aan.[Datum afgelasting] = '1753-01-01' and
			aan.[Cause of Eviction Code] in ('ONTRUIM11', 'ONTRUIM12', 'ONTRUIM13')

		-- obv de details vullen we de totalen

		delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.[Realisatie] (
			fk_indicator_id,
			Datum,
			Waarde,
			Laaddatum)
			select
				fk_indicator_id,
				@peildatum,
				sum(rd.[Waarde]),
				getdate()
			from Dashboard.[RealisatieDetails] as rd
			where rd.fk_indicator_id = @fk_indicator_id and
			rd.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
			group by fk_indicator_id

		-- bij geslaagde uitvoer rapporteren in logboek
		set	@finish = current_timestamp

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], Begintijd, Eindtijd)
			select object_name(@@procid), @start, @finish

	end try

	begin catch
		-- bij fout gegevens foutmelding wegschrijven in logboek
		set @finish = current_timestamp

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], TijdMelding, ErrorProcedure, ErrorNumber, ErrorLine, ErrorMessage)
			select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message()		
	end catch
end

GO
