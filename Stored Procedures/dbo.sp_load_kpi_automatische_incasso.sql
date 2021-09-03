SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE[dbo].[sp_load_kpi_automatische_incasso](
  @peildatum date
)
as
begin

	begin try

		-- eerst de details laden
		declare @fk_indicator_id as smallint, @start datetime = current_timestamp, @finish datetime
		select @fk_indicator_id = max(id) from  [Dashboard].[Indicator] where [Omschrijving] like '%Percentage%automatische%incasso%'
  
		-- verwijderen eerder opgehaalde data voor dezelfde periode (van 1e t/m laatste van de maand)
		delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.[RealisatieDetails](
			fk_indicator_id, 
			Datum,
			Waarde,			-- 1 als automatische incasso anders 0
			Omschrijving,
			Laaddatum,
			fk_contract_id) 
			select
				@fk_indicator_id,
				@peildatum,
				iif(bkl.[Transaction Mode Code] in ('INCHUUR'), 1, 0),
				bkl.[Customer No_] + ' ; ' + trim(enh.descr) + ' ; ' + enh.da_postcode + ' ; ' + enh.da_plaats + ' ; ' + bkl.[Transaction Mode Code], 
				GETDATE(),
				con.id		
			from empire_data.dbo.Staedion$Additioneel adi inner join empire_data.dbo.Staedion$OGE oge
			on adi.Eenheidnr_ = oge.Nr_ and
			-- alleen contracten die actief zijn op peildatum
			adi.Ingangsdatum <= @peildatum and (adi.Einddatum = '1753-01-01' or adi.Einddatum >= @peildatum)
			inner join empire_data.dbo.Staedion$Type typ
			on oge.[Type] = typ.Code
			inner join empire_data.dbo.Staedion$Betalingsgegevens_klant bkl
			-- als in betaalwijze geen eenheidnr is gevuld dan geldt betaalwijze voor alle contracten
			on adi.[Customer No_] = bkl.[Customer No_] and (adi.Eenheidnr_ = bkl.Eenheidnr_ or bkl.Eenheidnr_ = '') and
			-- alleen op peildatum geldige betaalwijze meetellen
			bkl.Ingangsdatum <= @peildatum and (bkl.Einddatum = '1753-01-01' or bkl.Einddatum >= @peildatum)
			-- koppeling naar contract maken om te zien of huurcontract actief is op peildatum
			-- koppelen DWH tabellen tbv DWH id's
			inner join empire_dwh.dbo.[contract] con
			on adi.[Customer No_] = con.fk_klant_id and adi.Eenheidnr_ = con.bk_eenheidnr
			inner join empire_dwh.dbo.eenheid enh
			on adi.[Eenheidnr_] = enh.bk_nr_
			-- Indicator is alleen voor woningen
			-- in filter worden zelfstandige en onzelfstandige woningen opgehaald
			-- where typ.[Analysis Group Code] in ('WON ZELF', 'WON ONZ')

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
				avg(rd.[Waarde] * 1.0),
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
