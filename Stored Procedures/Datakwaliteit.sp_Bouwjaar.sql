SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_Bouwjaar] (@fk_indicator_id int, @fk_indicatordimensie_id int)
as
begin try
/*
	exec [Datakwaliteit].[sp_Bouwjaar] @fk_indicator_id = 1180, @fk_indicatordimensie_id = 15
	exec [Datakwaliteit].[sp_Bouwjaar] @fk_indicator_id = 1180, @fk_indicatordimensie_id = 19
	exec [Datakwaliteit].[sp_Bouwjaar] @fk_indicator_id = 1180, @fk_indicatordimensie_id = 20
*/
  -- Diverse variabelen
	set nocount on;

	declare @start as datetime;
	declare @finish as datetime;
	declare @Teller bigint;
	declare @Noemer bigint;
	declare @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: staedion_dm..';
	declare @VersieNr NVARCHAR(80) = ' - Versie 5 20201202 JvdW - gebruik maken @@RowCount'	;
	set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
	declare @Bericht NVARCHAR(255)
	declare @parent_id int;
		
	DECLARE @AantalRecords int;

	DECLARE @Laaddatum as date
	DECLARE @Entiteit as nvarchar(50) = 'Eenheid'
	DECLARE @Attribuut as nvarchar(50) = 'Bouwjaar'
	
	select @parent_id = id 
	from staedion_Dm.Datakwaliteit.Indicator 
	where id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id

	PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @Entiteit = '+@Entiteit ;
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @Attribuut = '+@Attribuut ;
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @parent_id = '+coalesce(format(@parent_id,'N0' ),'GEEN !');
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicator = '+coalesce(format(@fk_indicator_id,'N0' ),'GEEN !');
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicatordimensie_id = '+coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !');

	set	@start = current_timestamp;
	
	select @Laaddatum = getdate()

	PRINT convert(VARCHAR(20), getdate(), 121) + + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );

	set @bericht = 'Ongeldige parameters voor entiteit ' + @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		', @fk_indicatordimensie_id = ' + coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !')

	-- procedure alleen uitvoeren als er geldige parameters zijn meegegeven om te voorkomen dat er 
	-- verkeerde gegevens worden verwijderd
	if (select count(*)
		from (values (1180, 15),
					(1180, 19),
					(1180, 20)) lst(indicator_id, indicatordimensie_id)
		where lst.indicator_id = @fk_indicator_id and lst.indicatordimensie_id = @fk_indicatordimensie_id) = 0
		-- genereer custom error
		raiserror (@bericht, 11, 1)

	-- verwijderen gegevens indien al aanwezig
	delete from [staedion_dm].[Datakwaliteit].[RealisatieDetails] 
	where fk_indicator_id = @fk_indicator_id and 
	fk_indicatordimensie_id = @fk_indicatordimensie_id and
	[Laaddatum] = @Laaddatum
	
	set @bericht = 'Entiteit '+ @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		+ coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !') + ' - RealisatieDetails verwijderd: ' + format(@@ROWCOUNT, 'N0');
	exec empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	if @fk_indicatordimensie_id = 15 -- volledigheid
		begin
			-- Alle eenheden hebben een bouwjaar
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'OGEHnr  = ' + oge.[Nr_] + '; Adres = ' + oge.[Straatnaam] + iif(oge.[Huisnr_] > '', ' ' + oge.[Huisnr_], '') + iif(oge.[Toevoegsel] > '', ' ' + oge.[Toevoegsel], '') [Omschrijving],
					'1) Geen bouwjaar ingevoerd.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					oge.[Nr_] [Eenheidnr]

				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				where oge.[Common Area] = 0 and
				oge.[Begin exploitatie] <= getdate() and
				(oge.[Einde Exploitatie] = '1753-01-01' or oge.[Einde Exploitatie] >= convert(date, getdate())) and
				oge.[Common Area] = 0 and
				oge.[Construction Year] = 0

			set @AantalRecords = @@ROWCOUNT

		end

	if @fk_indicatordimensie_id = 19 -- accuratesse
		begin

			-- Alle eenheden in een Bouwblok hebben hetzelfde bouwjaar
			; with bbl ([Bouwblok], [Bouwjaar])
			as (select cok.[Clusternr_] [Bouwblok], oge.[Construction Year] [Bouwjaar]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-Kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] and cok.[Clustersoort] = 'BOUWBLOK'
				where oge.[Begin exploitatie] <= getdate() and
				(oge.[Einde Exploitatie] = '1753-01-01' or oge.[Einde Exploitatie] >= convert(date, getdate())) and
				oge.[Common Area] = 0 and
				oge.[Construction Year] > 0),
			afw ([Bouwblok], [min Bouwjaar], [max Bouwjaar])
			as (select bbl.[Bouwblok], min(bbl.[Bouwjaar]), max(bbl.[Bouwjaar])
				from bbl
				group by bbl.[Bouwblok]
				having min(bbl.[Bouwjaar]) <> max(bbl.[Bouwjaar]))
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + afw.[Bouwblok] + '; Naam = ' + clu.[Naam] + '; Min bouwjaar = ' + convert(varchar(10), afw.[min Bouwjaar]) + '; Max bouwjaar = ' + convert(varchar(10), afw.[max Bouwjaar]) [Omschrijving],
					'6) Verschillende bouwjaren in bouwblok.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from afw inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				on afw.[Bouwblok] = clu.[Nr_]

			set @AantalRecords = @@ROWCOUNT

			-- Alle eenheden in een FT-cluster verschillen qua bouwjaar maximaal 3 jaar van elkaar
			; with fcl ([FT CLuster], [Bouwjaar])
			as (select cok.[Clusternr_] [FT CLuster], oge.[Construction Year] [Bouwjaar]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-Kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] and cok.[Clustersoort] = 'FTCLUSTER'
				where oge.[Begin exploitatie] <= getdate() and
				(oge.[Einde Exploitatie] = '1753-01-01' or oge.[Einde Exploitatie] >= convert(date, getdate())) and
				oge.[Common Area] = 0 and
				oge.[Construction Year] > 0),
			afw ([FT CLuster], [min Bouwjaar], [max Bouwjaar])
			as (select fcl.[FT CLuster], min(fcl.[Bouwjaar]), max(fcl.[Bouwjaar])
				from fcl
				group by fcl.[FT CLuster]
				having abs(min(fcl.[Bouwjaar]) - max(fcl.[Bouwjaar])) > 3)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'FT Cluster = ' + afw.[FT CLuster] + '; Naam = ' + clu.[Naam] + '; Min bouwjaar = ' + convert(varchar(10), afw.[min Bouwjaar]) + '; Max bouwjaar = ' + convert(varchar(10), afw.[max Bouwjaar]) [Omschrijving],
					'7) Bouwjaren in FT cluster liggen meer dan 3 jaar uiteen.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from afw inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				on afw.[FT CLuster] = clu.[Nr_]

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

		end

	if @fk_indicatordimensie_id = 20 -- consistentie
		begin

			-- Bouwjaar uit WWD is ongelijk aan bouwjaar bij OGE
			; with sel ([Eenheidnr_], [Ingangsdatum], [Volgnummer])
			as (select pva.[Eenheidnr_], pva.[Ingangsdatum], max(pva.[Volgnummer])
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Property Valuation] pva
				where pva.[Ingangsdatum] <= getdate() and
				pva.[Einddatum] >= convert(date, getdate())
				group by pva.[Eenheidnr_], pva.[Ingangsdatum]),
			wwd ([Eenheidnr_], [Bouwjaar])
			as (select pva.[Eenheidnr_], pva.[Bouwjaar]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Property Valuation] pva inner join sel
				on pva.[Eenheidnr_] = sel.[Eenheidnr_] and pva.[Ingangsdatum] = sel.[Ingangsdatum] and pva.[Volgnummer] = sel.[Volgnummer]
				where pva.[Ingangsdatum] <= getdate() and
				pva.[Einddatum] >= convert(date, getdate()))
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'OGEHnr = ' + oge.[Nr_] + '; Adres = ' + oge.[Straatnaam] + iif(oge.[Huisnr_] > '', ' ' + oge.[Huisnr_], '') + iif(oge.[Toevoegsel] > '', ' ' + oge.[Toevoegsel], '') +
						'; Bouwjaar OGE = ' + convert(varchar(10), oge.[Construction Year])	+ '; Bouwjaar WWD = ' + convert(varchar(10), wwd.[Bouwjaar]) [Omschrijving],
					'2) Bouwjaar in WWD wijkt af van bouwjaar bij OGE.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					oge.[Nr_] [Eenheidnr]
				from wwd inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on wwd.[Eenheidnr_] = oge.[Nr_]
				where oge.[Begin exploitatie] <= getdate() and
				(oge.[Einde Exploitatie] = '1753-01-01' or oge.[Einde Exploitatie] >= convert(date, getdate())) and
				oge.[Construction Year] > 0 and
				oge.[Construction Year] <> wwd.[Bouwjaar]

			set @AantalRecords = @@ROWCOUNT

			-- afwijking bouwjaar oge en WBS
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'OGEHnr = ' + oge.[Nr_] + '; Adres = ' + oge.[Straatnaam] + iif(oge.[Huisnr_] > '', ' ' + oge.[Huisnr_], '') + iif(oge.[Toevoegsel] > '', ' ' + oge.[Toevoegsel], '') +
						'; Bouwjaar OGE = ' + convert(varchar(10), oge.[Construction Year])	+ '; Bouwjaar WRB = ' + convert(varchar(10), wpe.[Value]) [Omschrijving],
					'3) Bouwjaar in WRB wijkt af van bouwjaar bij OGE.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					oge.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$WRB Property Entry] wpe
				on oge.[Nr_] = wpe.[Code] and wpe.[Table ID] = 11024008 and wpe.[Property Code] = 'OK154' and 
				wpe.[Start Date] <= getdate() and wpe.[End Date] >= convert(date, getdate())
				where oge.[Begin exploitatie] <= getdate() and
				(oge.[Einde Exploitatie] = '1753-01-01' or oge.[Einde Exploitatie] >= convert(date, getdate())) and
				oge.[Construction Year] <> convert(int, wpe.[Value])

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- Bouwjaar BAG max 5 jaar afwijking tov OGE
			; with bag ([Eenheidnr], [OGE bouwjaar], [Adres], [BAG_nr], [BAG bouwjaar], [Volgnr])
			as (select oge.[Nr_] eenheidnr, oge.[Construction Year],
					oge.[Straatnaam] + iif(oge.[Huisnr_] > '', ' ' + oge.[Huisnr_], '') + iif(oge.[Toevoegsel] > '', ' ' + oge.[Toevoegsel], ''),
					res_o.[Residence Code] as BAG_nr, 
					prm.[Year of construction] [BAG bouwjaar],
					volgnr = row_number() over (partition by res_o.[Realty Unit No_] order by res_o.[Residence Code] desc)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$BAG OGE - Residence] res_o inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on res_o.[Realty Unit No_] = oge.[Nr_]
				inner join [S-LOGSH-PROD].[Empire].[dbo].[BAG Residence] res
				on res.Code = res_o.[Residence Code]
				inner join [S-LOGSH-PROD].[Empire].[dbo].[BAG Premises - Residence] pre
				on pre.[Residence Code] = res.Code
				inner join [S-LOGSH-PROD].[Empire].[dbo].[BAG Premises] prm
				on pre.[Premises Code] = prm.Code
				where oge.[Begin exploitatie] <= getdate() and
				(oge.[Einde Exploitatie] = '1753-01-01' or oge.[Einde Exploitatie] >= convert(date, getdate())) and
				oge.[Common Area] = 0 and
				oge.[Construction Year] > 0 and
				res.[status] = 'Verblijfsobject in gebruik')
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'OGEHnr = ' + bag.[Eenheidnr] + '; Adres = ' + bag.[Adres] + '; BAG nr = ' + bag.[BAG_nr] +
						'; Bouwjaar OGE = ' + convert(varchar(10), bag.[OGE bouwjaar])	+ '; Bouwjaar BAG = ' + convert(varchar(10), bag.[BAG bouwjaar]) [Omschrijving],
					'8) Bouwjaar in BAG wijkt maar dan 5 jaar af van bouwjaar bij OGE.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					bag.[Eenheidnr]
				from bag
				where bag.[Volgnr] = 1 and
				abs(bag.[OGE bouwjaar] - bag.[BAG bouwjaar]) > 5

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
		end

	set @bericht = 'Attribuut ' + @Attribuut + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		+ coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !') + ' - RealisatieDetails toegevoegd: ' + format(@@ROWCOUNT, 'N0');
	exec empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-- verwijderen gegevens indien al aanwezig
	delete from [staedion_dm].[Datakwaliteit].[Realisatie] 
	where fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id and
	[Laaddatum] = @Laaddatum

	set @bericht = 'Attribuut ' + @Attribuut + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		+ coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !') + ' - Realisatie verwijderd: ' + format(@@ROWCOUNT, 'N0');
	exec empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	; with nmr ([Noemer])
	as (select count(*) [Noemer]
		from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
		where clu.[Clustersoort] = 'FTCLUSTER')
	insert into [staedion_dm].[Datakwaliteit].[Realisatie] ([Waarde], [Laaddatum], [fk_indicator_id], [Teller], [Noemer], [fk_indicatordimensie_id])
		select count(*) Waarde, @Laaddatum [Laaddatum], @fk_indicator_id [fk_indicator_id], count(*) [Teller], nmr.[Noemer], @fk_indicatordimensie_id [fk_indicatordimensie_id]
		from nmr left outer join [staedion_dm].[Datakwaliteit].[RealisatieDetails] det 
		on 1 = 1 and
		det.[Laaddatum] = @Laaddatum and
		det.[fk_indicator_id] = @fk_indicator_id and
		det.[fk_leefbaarheidsdossier_id] = @fk_indicatordimensie_id
		group by nmr.[Noemer]

	set @bericht = 'Entiteit ' + @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		+ coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !') + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
	exec empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

end try

begin catch
	set		@finish = current_timestamp

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject], TijdMelding, ErrorProcedure, ErrorNumber, ErrorLine, ErrorMessage)
		select	coalesce(ERROR_PROCEDURE(),'?' ) + ' - ' + coalesce(@Entiteit,'?' )
						,getdate()
						,ERROR_PROCEDURE() 
						,ERROR_NUMBER()
						,ERROR_LINE()
						,ERROR_MESSAGE() 
		
end catch
GO
