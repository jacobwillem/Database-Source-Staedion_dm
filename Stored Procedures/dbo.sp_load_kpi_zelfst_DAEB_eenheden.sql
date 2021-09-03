SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi_zelfst_DAEB_eenheden](@peildatum date)
/**************************************************************************************************************
Door	RvG
Doel	Bepaald van alle zelfstandige DAEB eenheden of de netto huurprijs > 90% max toegestane huur is of niet
		Waarde = 1 als huurprijs boven 90% is
		In de details worden de nettohuur als teller en de max toegestane huur als noemer vastgelegd.
		Opmerking woningen zonder woningwaardering (en dus zonder vastgestelde max. toegestane huur) worden
		als woningen met een huur < 90% van de max toegestane huur gerapporteerd.
**************************************************************************************************************/
as
begin
	set nocount on

	begin try 

		-- Diverse variabelen
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as smallint

		set	@start = current_timestamp

		select @fk_indicator_id = 600

		-- loggen starten van ophalen gegevens

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], Begintijd, Eindtijd)
			select object_name(@@PROCID), @start, @finish

		-- details vullen nadat eventueel aanwezige gegevens zijn verwijderd
	
		delete from Dashboard.RealisatieDetails where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.RealisatieDetails (Datum, Waarde, Laaddatum, Omschrijving, fk_indicator_id, fk_eenheid_id, fk_contract_id, fk_klant_id, Teller, Noemer)
			select @peildatum Datum, iif(wwd.Maximaal_toegestane_huur is null, null, iif(isnull(hpr.nettohuur, 0) / wwd.Maximaal_toegestane_huur > .9, 1, 0)), getdate() Laaddatum
			, [Omschrijving] = oge.Nr_ + ' ; nettohuur: ' + format(coalesce(hpr.nettohuur,0) ,'N2') + ' ; maximaal redelijke huur: ' + format(coalesce(wwd.Maximaal_toegestane_huur,0), 'N2')
				, @fk_indicator_id, enh.id, null, null, hpr.nettohuur [Teller], wwd.Maximaal_toegestane_huur [Noemer]
			from empire_data.dbo.Staedion$OGE oge inner join empire_data.dbo.Staedion$Type typ
			on oge.[Type] = typ.Code
			inner join empire_data..Staedion$Oge_Administrative_Owner oao
			on oge.Nr_ = oao.[Realty Object No_] and oao.[Start Date] <= @peildatum and (oao.[End Date] = '1753-01-01' or oao.[End Date] >= @peildatum)
			inner join Backup_empire_dwh.dbo.eenheid enh
			on enh.da_bedrijf = 'Staedion' and enh.bk_nr_ = oge.Nr_	and enh.staedion_verhuurteam not like 'Verhuurteam 3 - studenten'
			outer apply empire_staedion_data.dbo.[ITVfnStreefhuur](oge.nr_, @peildatum) as wwd
			outer apply empire_staedion_data.dbo.[ITVfnHuurprijs](oge.nr_, @peildatum) as hpr
			where oao.[Dimension Value] = 'DAEB' and -- woningen uit de DAEB tak
			oge.Woonruimte = 0 and -- Alleen zelfstandig
			oge.[Common Area] = 0 and
			typ.[Analysis Group Code] = 'WON ZELF' and
			oge.[Begin exploitatie] <= @peildatum and (oge.[Einde exploitatie] = '1753-01-01' or oge.[Einde exploitatie] > @peildatum)

		-- obv de details vullen we de totalen

		delete from Dashboard.[Realisatie] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

		insert into Dashboard.[Realisatie] (fk_indicator_id, Datum, Waarde, Laaddatum )
			select @fk_indicator_id, @peildatum, Waarde = sum(rd.waarde) / Count(*), getdate()
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
