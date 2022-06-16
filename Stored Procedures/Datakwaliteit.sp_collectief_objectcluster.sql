SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_collectief_objectcluster] (@fk_indicator_id int, @fk_indicatordimensie_id int)
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
	DECLARE @Entiteit as nvarchar(50) = 'Collectief object cluster'
	
	select @parent_id = id 
	from staedion_Dm.Datakwaliteit.Indicator 
	where id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id

	PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @Entiteit = '+@Entiteit ;
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @parent_id = '+coalesce(format(@parent_id,'N0' ),'GEEN !');
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicator = '+coalesce(format(@fk_indicator_id,'N0' ),'GEEN !');
	PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicatordimensie_id = '+coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !');

	set	@start =current_timestamp;
	
	select @Laaddatum = getdate()

	PRINT convert(VARCHAR(20), getdate(), 121) + + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );

	set @bericht = 'Ongeldige parameters voor entiteit ' + @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		', @fk_indicatordimensie_id = ' + coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !')

	-- procedure alleen uitvoeren als er geldige parameters zijn meegegeven om te voorkomen dat er 
	-- verkeerde gegevens worden verwijderd
	if (select count(*)
		from (values (7110, 15),
					(7110, 19)) lst(indicator_id, indicatordimensie_id)
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
			-- Collectief objectcluster heeft tenminste 1 OGEH
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster  = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Geen gekoppelde OGEH.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'COLLOBJ' and
				not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] cok
					where cok.[Common Area] = 0 and
					cok.[Clusternr_] = clu.[Nr_])

			set @AantalRecords = @@ROWCOUNT

			-- Collectief objectcluster heeft tenminste 1 collectief object
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster  = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Geen gekoppeld collectief object.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'COLLOBJ' and
				not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] cok
					where cok.[Common Area] = 1 and
					cok.[Clusternr_] = clu.[Nr_])

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
		end

	if @fk_indicatordimensie_id = 19 -- accuratesse
		begin
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster  = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Begint niet met COC-.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'COLLOBJ' and
				clu.[Nr_] not like 'COC-%'

			set @AantalRecords = @@ROWCOUNT

			-- Collectief objectcluster is niet van clustersoort COLLOBJ
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster  = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Heeft clustersoort ' + clu.[Clustersoort] + '.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] <> 'COLLOBJ' and
				clu.[Nr_] like 'COC-%'

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- Collectief objectcluster naam moet gelijk zijn aan naam van gekoppeld FT cluster
			; with coc (clusternr, naam, numeriekdeel)
			as (select clu.[Nr_], clu.[Naam], 
					left(substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100), 
							patindex('%[^0-9]%', substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100) + 'r') -1)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'COLLOBJ')
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster = ' + coc.[clusternr] + '; Naam = ' + coc.[Naam] +
						'; FT cluster = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Naam niet gelijk aan bijbehorend FT cluster.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					coc.clusternr [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu inner join coc
				on clu.[Nr_] = 'FT-' + coc.numeriekdeel
				where clu.[Clustersoort] = 'FTCLUSTER' and
				coc.[clusternr] like '%' + coc.numeriekdeel and
				clu.[Naam] <> coc.[naam]
			
			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- Collectief objectcluster naam moet gelijk zijn aan naam van gekoppeld bouwblok
			; with coc (clusternr, naam, alfanumeriekdeel)
			as (select clu.[Nr_], clu.[Naam], 
					substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'COLLOBJ')
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster = ' + coc.[clusternr] + '; Naam = ' + coc.[Naam] +
						'; Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Naam niet gelijk aan bijbehorend bouwblok.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					coc.clusternr [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu inner join coc
				on clu.[Nr_] = 'BB-' + coc.alfanumeriekdeel
				where clu.[Clustersoort] = 'BOUWBLOK' and
				clu.[Naam] <> coc.[naam]
		
			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- Collectief objectcluster naam moet afwijkend zijn indien deel van gekoppeld bouwblok
			; with coc (clusternr, naam, alfanumeriekdeel)
			as (select clu.[Nr_], clu.[Naam], 
					left(substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100), 
						charindex('.', substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100) + '.') -1)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'COLLOBJ' and
				charindex('.', clu.[Nr_]) > 0)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief objectcluster = ' + coc.[clusternr] + '; Naam = ' + coc.[Naam] +
						'; Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'Naam deelcluster gelijk aan bijbehorend bouwblok.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					coc.clusternr [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu inner join coc
				on clu.[Nr_] = 'BB-' + coc.alfanumeriekdeel
				where clu.[Clustersoort] = 'BOUWBLOK' and
				clu.[Naam] = coc.[naam]

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
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
		where clu.[Clustersoort] = 'COLLOBJ')
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
