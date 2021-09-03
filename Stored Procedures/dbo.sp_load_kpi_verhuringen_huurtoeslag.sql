SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE[dbo].[sp_load_kpi_verhuringen_huurtoeslag](
	@peildatum date = '20191231', @eenzijdig_wijk nvarchar(3) 
)
as
/* #################################################################################################################
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210131', 'Ja'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210131', 'Nee'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210228', 'Ja'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210228', 'Nee'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210331', 'Ja'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210331', 'Nee'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210430', 'Ja'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210430', 'Nee'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210531', 'Ja'
exec staedion_dm.[dbo].[sp_load_kpi_verhuringen_huurtoeslag] '20210531', 'Nee'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Tijdmelding desc
	declare @fk_indicator_id_eenzijdig as smallint
	declare @fk_indicator_id_niet_eenzijdig as smallint
	select @fk_indicator_id_eenzijdig = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%verhuringen in eenz%'
	select @fk_indicator_id_niet_eenzijdig = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%verhuringen in niet-eenz%'
	select @fk_indicator_id_eenzijdig,@fk_indicator_id_niet_eenzijdig

select max(Datum), count(*) from staedion_dm.Dashboard.[RealisatieDetails] where fk_indicator_id in (@fk_indicator_id_eenzijdig,@fk_indicator_id_niet_eenzijdig)
select max(Datum), count(*) from staedion_dm.Dashboard.[Realisatie] where fk_indicator_id in (@fk_indicator_id_eenzijdig,@fk_indicator_id_niet_eenzijdig)
--------------------------------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------------------------------
20210206 JvdW Deze procedure laat data 2020 nu ongemoeid
-- Data 2020 per abuis overschreden met definitie 2021
-- Data 2020 zoals gepubliceerd in T3 rapportage teruggezet - was per abuis met nieuwe definitie overschreden
20210208 JvdW Extra conditie [Controle-opmerking] = OK
20210607 PP: Clusternummer toegevoegd aan output
--------------------------------------------------------------------------------------------------------------------------------------------------------

begin tran t1
;
delete from staedion_dm.Dashboard.[RealisatieDetails]
where fk_indicator_id in ( 1300,1400) and  year(datum) =2020
;
insert into staedion_dm.Dashboard.[RealisatieDetails] (Datum, Waarde, Laaddatum, Omschrijving, fk_indicator_id, fk_eenheid_id, fk_contract_id, fk_klant_id, Teller, Noemer)
select Datum, Waarde, Laaddatum, Omschrijving, fk_indicator_id, fk_eenheid_id, fk_contract_id, fk_klant_id, Teller, Noemer
from staedion_dm.bak.[RealisatieDetails_20210201_1106]
where fk_indicator_id in ( 1300,1400) and  year(datum) =2020 
;
commit tran t1
-- check 76,2% + 64,9%
select year(Datum), fk_indicator_id, avg(WaardE),sum(Teller),sum(Noemer) 
from staedion_dm.Dashboard.[RealisatieDetails]
where fk_indicator_id in ( 1300,1400) and  year(datum) =2020 --and month(datum) = 3 
group by year(Datum), fk_indicator_id
order by 2,1
;



################################################################################################################# */

begin try

	set nocount on

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	declare @fk_indicator_id_eenzijdig as smallint
	declare @fk_indicator_id_niet_eenzijdig as smallint

	set	@start = current_timestamp

	select @fk_indicator_id_eenzijdig = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%verhuringen in eenz%' and @eenzijdig_wijk = 'Ja'
	select @fk_indicator_id_niet_eenzijdig = min(id) from  [Dashboard].[Indicator] where lower([Omschrijving]) like  '%verhuringen in niet-eenz%' and @eenzijdig_wijk = 'Nee'

	delete from Dashboard.[RealisatieDetails] where fk_indicator_id in (@fk_indicator_id_eenzijdig, @fk_indicator_id_niet_eenzijdig) 
					and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)
					AND year(datum)>= 2021

	insert into [Dashboard].[RealisatieDetails] (
		[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,fk_indicator_id
		,[fk_eenheid_id]
		,[fk_contract_id]
		,[Teller]
		,[Noemer]
		,[Clusternummer]
		)
		-- nieuwe berekening
		select Datum =  [Datum ingang contract]
						,Waarde = 1 - BASIS.[Eenzijdige verhuring] -- NB: kpi is nu zo opgesteld: 100% minus verhuringen boven huurtoeslaggrens
						,Laaddatum = GETDATE()
						,Omschrijving = 'Verhuring eenheid ; ' + Eenheid + ' ; ' + convert(nvarchar(20),[Datum ingang contract]) + ' ; ' + replace(BASIS.[Categorie passendheid - CNS],';',',')
						,fk_indicator_id = case when [Soort wijk] = 'Eenzijdige wijk' then @fk_indicator_id_eenzijdig else @fk_indicator_id_niet_eenzijdig end
						,fk_eenheid_id = BASIS.[Sleutel eenheid]
						,fk_contract_id = BASIS.[Sleutel contract]
						,Teller = BASIS.[Eenzijdige verhuring]
						,Noemer = 1
						,[Clusternummer] = (select top 1 [FT clusternr] from staedion_dm.Eenheden.Eigenschappen as EIG where EIG.Eenheidnr = Eenheid order by Ingangsdatum desc)
							-- select top 10 *
		from	 staedion_dm.[Verhuur].[Verantwoordingen] as BASIS
		where	[Datum ingang contract] between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum 
		and		([Soort wijk] = 'Eenzijdige wijk' and @eenzijdig_wijk = 'Ja'
		OR		[Soort wijk] = 'Geen eenzijdige wijk' and @eenzijdig_wijk = 'Nee')
		AND		year([Datum ingang contract])>= 2021
		AND     [Controle-opmerking]  = 'OK'
		and     BASIS.[Corpodata type] in ('WON ONZ', 'WON ZELF') -- jvdw 11-05-2021 toegevoegd
		;
	
	-- Samenvatting opvoeren tbv dashboards
	delete from Dashboard.[Realisatie] where fk_indicator_id in ( @fk_indicator_id_eenzijdig, @fk_indicator_id_niet_eenzijdig)  and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into Dashboard.[Realisatie] (
		fk_indicator_id,
		Datum,
		Waarde,
		Laaddatum
		)
		select det.fk_indicator_id, @peildatum, avg([Waarde] * 1.00), getdate()
		from Dashboard.[RealisatieDetails] det
		where det.fk_indicator_id in ( @fk_indicator_id_eenzijdig, @fk_indicator_id_niet_eenzijdig)  and det.datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
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
