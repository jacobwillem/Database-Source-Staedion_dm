SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi_energie_gemiddelde_index](@peildatum date)
/**************************************************************************************************************
Door	RvG
Doel	Bepaald van alle zelfstandige eenheden de energieindex. Indien er geen energieindex, maar een EPA label
		bekend is wordt de gemiddelde waarde van de energieindex range genomen die voor het label geld.
		Als de energiewaardering op basis van bouwjaar of isolatie en verwarming plaatsvindt wordt uitgegaan van 
		het bouwjaar en wordt de gemiddelde energie index voor de bouwjaar range toegekend.
		Waarde wordt gevuld met de (berekende) energie index van de eenheid
		In de details worden de (berekende) energieinde als teller en de vste waarde 1 als noemer vastgelegd.
**************************************************************************************************************/
as
begin
	set nocount on

	begin try 

		-- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint
		declare @laaddatum as date

		set	@start = current_timestamp
		set @laaddatum = getdate()

		select @fk_indicator_id = 500

		-- loggen starten van ophalen gegevens

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], Begintijd, Eindtijd)
			select object_name(@@PROCID), @start, @finish

		-- details vullen nadat eventueel aanwezige gegevens zijn verwijderd
	
		delete from Dashboard.RealisatieDetails where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		; with sel (Eenheidnr_, bouwjaar, Ingangsdatum, Volgnummer)
		as (select pva.Eenheidnr_, oge.[Construction Year] bouwjaar, pva.Ingangsdatum, max(pva.Volgnummer) Volgnummer
			from empire_data.dbo.Staedion$OGE oge inner join empire_data.dbo.Staedion$Type typ
			on oge.[Type] = typ.Code
			inner join empire_data.dbo.Staedion$Property_Valuation pva
			on oge.[Nr_] = pva.Eenheidnr_
			where oge.[Begin exploitatie] <= @peildatum and (oge.[Einde exploitatie] = '1753-01-01' or oge.[Einde exploitatie] > @peildatum) and
			pva.Ingangsdatum <= @peildatum and pva.Einddatum >= @peildatum and
			typ.[Analysis Group Code] = 'WON ZELF'
			group by pva.Eenheidnr_, oge.[Construction Year], pva.Ingangsdatum),
		epa ([EPA-Label], [Energy Index])
		as (select code, epa.[Energieindex hoog] + [Energieindex laag] / 2
			from empire_data.dbo.Staedion$Energy_Label epa),
		bjr (van, tm, [Energy Index])
		as (select epa.[From Construction Year], epa.[To Construction Year], epa.[Energieindex hoog] + [Energieindex laag] / 2
			from empire_data.dbo.Staedion$Energy_Label epa
			where epa.[To Construction Year] > 0)
		insert into Dashboard.RealisatieDetails (Datum, Waarde, Laaddatum, Omschrijving, fk_indicator_id, fk_eenheid_id, fk_contract_id, fk_klant_id, Teller, Noemer)
			select @peildatum Datum, case pva.[Energy Validation] when 0 then bjr.[Energy Index]
				when 1 then epa.[Energy Index]
				when 2 then pva.[Energy Index]
				when 3 then bjr.[Energy Index]
				else 40 end Waarde, @laaddatum Laaddatum, pva.Eenheidnr_ + ' - ' + case pva.[Energy Validation] when 0 then 'Verwarming en isolatie ' + convert(varchar(10), sel.bouwjaar) 
					when 1 then 'EPA label ' + pva.[EPA-label] + ' dd ' + convert(varchar(10), pva.[date certificate granted], 105)
					when 2 then 'Energie-index'
					when 3 then 'Bouwjaar ' + convert(varchar(10), sel.bouwjaar)
					else 'Onbekend' end Omschrijving, @fk_indicator_id, enh.id, null contract_id, null fk_klant_id, 
				case pva.[Energy Validation] when 0 then bjr.[Energy Index]
					when 1 then epa.[Energy Index]
					when 2 then pva.[Energy Index]
					when 3 then bjr.[Energy Index]
					else null end Teller, 1 Noemer
			from empire_data.dbo.Staedion$Property_Valuation pva inner join sel
			on pva.Eenheidnr_ = sel.Eenheidnr_ and pva.Ingangsdatum = sel.Ingangsdatum and pva.Volgnummer = sel.Volgnummer
			inner join backup_empire_dwh.dbo.eenheid enh
			on enh.da_bedrijf = 'Staedion' and enh.bk_nr_ = pva.Eenheidnr_
			left outer join epa
			on pva.[EPA-label] = epa.[EPA-Label]
			left outer join bjr
			on sel.[bouwjaar] between bjr.van and bjr.tm
			order by pva.[Energy Validation] desc

		-- obv de details vullen we de totalen

		delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.[Realisatie] (fk_indicator_id, Datum, Waarde, Laaddatum )
			select @fk_indicator_id, @peildatum, Waarde = sum(rd.waarde) / Count(*), @laaddatum
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
