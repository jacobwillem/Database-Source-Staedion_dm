SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_load_kpi_energie](
  @peildatum date = '20211231', @indicator nvarchar(255), @meeteenheid nvarchar(255)
)
/**************************************************************************************************************
Door	JvdW
Doel	Conform berekeningswijze "CNS" in rapport van O&V

exec staedion_dm.[dbo].[sp_load_kpi_gemiddelde_energieindex_alternatief]  '20200131', 1

declare @fk_indicator_id as smallint
select @fk_indicator_id = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%energie%index%'
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
		declare	@sql nvarchar(max)

		set	@start =current_timestamp

		-- parameter @indicator bevat de selectiestring voor de juiste indicator inclusief wildcards bv '%primaire fossiele energievraag%'
		select @fk_indicator_id = min(id) from [Dashboard].[Indicator] where lower([Omschrijving]) like @indicator

		-- loggen starten van ophalen gegevens

		insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], Begintijd, Eindtijd)
			select object_name(@@PROCID), @start, @finish

  -- Standaard bewaren voor kpi's de details wel
	if @LoggenDetails = 1
		begin 		
			delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
			;

			select @sql = N' INSERT INTO [Dashboard].[RealisatieDetails] (
									  [Datum]
									 ,[Waarde]
									 ,[Laaddatum]
									 ,[Omschrijving]
									 ,[Clusternummer]
									 ,[fk_indicator_id]
									 ,[fk_eenheid_id]
									 )
									--,[fk_contract_id]
									--,[fk_klant_id]
									--,[Teller]
									--,[Noemer]
				SELECT		  ' + quotename(@peildatum, '''') + '
							 ,ELA.' + quotename(@meeteenheid) + '
							 ,getdate()
							 ,ELA.[Eenheidnummer]
							 ,CLU.[Clusternr_]
							 ,' + quotename(@fk_indicator_id, '''') + '
							 ,ELA.[sleutel eenheid]
				-- select count(*), count(distinct ELA.[sleutel eenheid])
				FROM [Algemeen].[Vabi Energielabel eenheden] AS ELA JOIN empire_data.dbo.[Staedion$OGE] AS OGE
				ON OGE.[Nr_] = ELA.[Eenheidnummer]
				JOIN [empire_data].dbo.[Staedion$type] AS TT
				ON TT.[Code] = OGE.[Type] AND TT.Soort = 0
				LEFT JOIN [empire_data].[dbo].[Staedion$Cluster_OGE] AS CLU
				ON CLU.[Eenheidnr_] = ELA.[Eenheidnummer] AND CLU.[Clustersoort] = ''FTCLUSTER''
				WHERE eomonth(ELA.Datum) = eomonth(' + quotename(@peildatum, '''') + ')
							 AND TT.[Analysis Group Code] = ''WON ZELF''
							 AND OGE.[Begin exploitatie] <> ''17530101''
							 AND OGE.[Begin exploitatie] <= ' + quotename(@peildatum, '''') + '
							 AND (OGE.[Einde exploitatie] >= ' + quotename(@peildatum, '''') + '
							  OR  OGE.[Einde exploitatie] = ''17530101'')
							 AND ELA.' + quotename(@meeteenheid) + ' IS NOT NULL
							 AND ELA.' + quotename(@meeteenheid) + ' <> 0'
			print(@sql)
			exec sp_executesql @sql

				/*insert into [Dashboard].[RealisatieDetailsTest] (
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
				SELECT		  @peildatum
							 ,quotename(@meeteenheid)
							 ,getdate()
							 ,ELA.Eenheidnummer
							 ,@fk_indicator_id
							 ,ELA.[sleutel eenheid]
				-- select count(*), count(distinct ELA.[sleutel eenheid])
				FROM [Algemeen].[Vabi Energielabel eenheden] AS ELA JOIN empire_data.dbo.[Staedion$OGE] AS OGE
				ON OGE.Nr_ = ELA.Eenheidnummer
				JOIN empire_Data.dbo.[Staedion$type] AS TT
				ON TT.[Code] = OGE.[Type] AND TT.Soort = 0
				WHERE eomonth(ELA.Datum) = eomonth(@peildatum) --'20200131'
							 AND TT.[Analysis Group Code] = 'WON ZELF'
							 AND OGE.[Begin exploitatie] <> '17530101'
							 AND OGE.[Begin exploitatie] <= @peildatum
							 AND (OGE.[Einde exploitatie] >= @peildatum
							  OR  OGE.[Einde exploitatie] = '17530101')
							 AND ELA.Energieindex IS NOT NULL
							 */
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
