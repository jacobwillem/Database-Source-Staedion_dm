SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_FT_cluster] (@fk_indicator_id int, @fk_indicatordimensie_id int)
as
begin try

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
	DECLARE @Entiteit as nvarchar(50) = 'FT cluster'
	
	select @parent_id = id 
	from staedion_Dm.Datakwaliteit.Indicator 
	where id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id

	PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @Entiteit = '+@Entiteit ;
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
		from (values (7310, 15),
					(7310, 19)) lst(indicator_id, indicatordimensie_id)
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
			-- FT cluster is aan tenminste 1 bouwblok gekoppeld
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'FT cluster  = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Niet aan tenminste 1 bouwblok gekoppeld.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				where clu.[Clustersoort] = 'FTCLUSTER' and
				clu.[Nr_] not in ('FT-1998') and 
				not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] bbl
					where bbl.[Clustersoort] = 'BOUWBLOK' and
					bbl.[Component of Cluster] = clu.[Nr_])

			set @AantalRecords = @@ROWCOUNT

			-- Als tenminste 1 OGEH verhuurd of leegstand dan gekoppeld aan blauw, groen of rood
			; with dat (Peildatum)
			as (select max(mwd.[Peildatum])
				from staedion_dm.[Eenheden].[Meetwaarden] mwd),
			clu ([FT clusternr], [FT clusternaam])
			as (select eig.[FT clusternr], eig.[FT clusternaam]
				from [staedion_dm].[Eenheden].[Meetwaarden] mwd inner join dat
				on mwd.[Peildatum] = dat.[Peildatum]
				inner join [staedion_dm].[Eenheden].[EenheidStatus] est
				on mwd.[Eenheidstatus_id] = est.[Eenheidstatus_id]
				inner join [staedion_dm].[Eenheden].[Eigenschappen] eig
				on mwd.[Eigenschappen_id] = eig.[Eigenschappen_id]
				where est.EenheidStatus in ('Leegstand', 'Verhuurd') and
				eig.[FT clusternr] is not null
				group by eig.[FT clusternr], eig.[FT clusternaam])
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'FT cluster  = ' + clu.[FT clusternr] + '; Naam = ' + clu.[FT clusternaam] [Omschrijving],
					'Niet gekoppeld aan een werkgebied Rood, Groen of Blauw.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[FT clusternr] [Eenheidnr]
				from clu 
				where not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$DM - Work Area - Cluster] wac
					where wac.[Cluster No_] = clu.[FT clusternr] collate database_default and
					wac.[Work Area Code] in ('WERKGEBIED ROOD', 'WERKGEBIED GROEN', 'WERKGEBIED BLAUW'))
				union
				-- Als tenminste 1 OGEH verhuurd of leegstand dan gekoppeld aan WMO
				select @Laaddatum [Laaddatum], 
					'FT cluster  = ' + clu.[FT clusternr] + '; Naam = ' + clu.[FT clusternaam] [Omschrijving],
					'Niet gekoppeld aan een werkgebied WMO.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[FT clusternr] [Eenheidnr]
				from clu 
				where not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$DM - Work Area - Cluster] wac
					where wac.[Cluster No_] = clu.[FT clusternr] collate database_default and
					wac.[Work Area Code] in ('WMO'))

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
		end

	if @fk_indicatordimensie_id = 19 -- accuratesse
		begin

			-- Alle eenheden in een FT cluster hebben dezelfde juridisch eigenaar
			; with dat (Peildatum)
			as (select max(mwd.[Peildatum])
				from staedion_dm.[Eenheden].[Meetwaarden] mwd),
			clu ([FT clusternr], [FT clusternaam], [Juridisch eigenaar])
			as (select eig.[FT clusternr], eig.[FT clusternaam], mwd.[Juridisch eigenaar]
				from [staedion_dm].[Eenheden].[Meetwaarden] mwd inner join dat
				on mwd.[Peildatum] = dat.[Peildatum]
				inner join [staedion_dm].[Eenheden].[Eigenschappen] eig
				on mwd.[Eigenschappen_id] = eig.Eigenschappen_id
				where mwd.[Juridisch eigenaar] <> ''
				group by eig.[FT clusternr], eig.[FT clusternaam], mwd.[Juridisch eigenaar])
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'FT cluster  = ' + brn.[FT clusternr] + '; Naam = ' + brn.[FT clusternaam] + ';' + string_agg('[' + brn.[Juridisch eigenaar] + ']', ',') [Omschrijving],
					'Heeft onderliggende eenheden van meer dan 1 juridisch eigenaar.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					brn.[FT clusternr] [Eenheidnr]
				from clu brn
				where brn.[FT clusternr] in (
					select clu.[FT clusternr]
					from clu
					group by clu.[FT clusternr]
					having count(*) > 1)
				group by brn.[FT clusternr], brn.[FT clusternaam]

			set @AantalRecords = @@ROWCOUNT

		end

	set @bericht = 'Entiteit ' + @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		+ coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !') + ' - RealisatieDetails toegevoegd: ' + format(@@ROWCOUNT, 'N0');
	exec empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-- verwijderen gegevens indien al aanwezig
	delete from [staedion_dm].[Datakwaliteit].[Realisatie] 
	where fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id and
	[Laaddatum] = @Laaddatum

	set @bericht = 'Entiteit ' + @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
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
