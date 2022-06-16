SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_collectief_object] (@fk_indicator_id int, @fk_indicatordimensie_id int)
/*


declare @Laaddatum date = getdate(), @fk_indicator_id int = 0, @fk_indicatordimensie_id int = 0

	exec [Datakwaliteit].[sp_collectief_object] @fk_indicator_id = 7010, @fk_indicatordimensie_id = 15
	exec [Datakwaliteit].[sp_collectief_object] @fk_indicator_id = 7010, @fk_indicatordimensie_id = 19
*/
as
begin try
	-- declare @fk_indicator_id int = 7010, @fk_indicatordimensie_id int = 19
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
	DECLARE @Entiteit as nvarchar(50) = 'Collectief object'
	
	select @parent_id = parent_id 
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
		from (values (7010, 15),
					(7010, 19)) lst(indicator_id, indicatordimensie_id)
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
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'1) Niet gekoppeld aan collectief object cluster' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				cob.[Collectief object clusternr] = ''

			set @AantalRecords = @@ROWCOUNT
			
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'2) Niet gekoppeld aan FT cluster' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], -- Volledigheid 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				cob.[Collectief object clusternr] = ''

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'Niet gekoppeld aan bouwblok' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				tty.[Code] not in ('ACHTERPAD', 'BESTRATING', 'GROENSPEEL') and
				cob.[Bouwbloknr] = ''

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
/*
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'Geen beheerder aanwezig' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				cob.[Beheerder] = ''

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

*/
			-- Als bouwblok gekoppeld aan VvE dan juridisch eigenaar collectief object begint met VvE
			; with bbl ([Bouwblok], [Eenheidnr], [Common Area])
			as (select bbl.[Clusternr_], bbl.[Eenheidnr_], bbl.[Common Area]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] bbl 
				where bbl.clustersoort = 'BOUWBLOK'),
			vve ([VvE], [Eenheidnr])
			as (select vve.[Clusternr_], vve.[Eenheidnr_]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] vve
				where vve.clustersoort = 'VVE' and vve.[Common Area] = 0),
			cmb ([Bouwblok])
			as (select bbl.[Bouwblok]
				from bbl
				where exists (select 1
					from vve
					where vve.[Eenheidnr] = bbl.[Eenheidnr])
				group by bbl.[Bouwblok])
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] + ' heeft geen juridisch eigenaar die begint met VvE' [Omschrijving],
					'Geen juridisch eigenaar die begint met VvE' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], -- Volledigheid 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				inner join cmb
				on cob.[Bouwbloknr] = cmb.[Bouwblok] collate database_default
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				cob.[Juridisch eigenaar] not like 'VvE%'

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

		end
	
	if @fk_indicatordimensie_id = 19 -- accuratesse
		begin
			; with tel ([Eenheidnr_], [Clustersoort], [Aantal])
			as (select cok.[Eenheidnr_] collate database_default, cok.[Clustersoort], count(*) [Aantal]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-Kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] and oge.[Common Area] = 1
				where cok.[Clustersoort] in ('COLLOBJ')
				group by cok.[Eenheidnr_], cok.[Clustersoort]
				having count(*) > 1)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
						'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
							'1) Gekoppeld aan ' + convert(varchar(10), tel.[Aantal]) + ' collectief object clusters' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join tel
				on cob.[Collectief object] = tel.[Eenheidnr_] 
				inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum)

			set @AantalRecords = @@ROWCOUNT

			; with tel ([Eenheidnr_], [Clustersoort], [Aantal])
			as (select cok.[Eenheidnr_] collate database_default, cok.[Clustersoort], count(*) [Aantal]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-Kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] and oge.[Common Area] = 1
				where cok.[Clustersoort] in ('FTCLUSTER')
				group by cok.[Eenheidnr_], cok.[Clustersoort]
				having count(*) > 1)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
						'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
							'2) Gekoppeld aan ' + convert(varchar(10), tel.[Aantal]) + ' FT clusters' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join tel
				on cob.[Collectief object] = tel.[Eenheidnr_] 
				inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) 

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'3) Omschrijving niet gelijk aan omschrijving COC + <Type>.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] coc 
				on cob.[Collectief object clusternr] = coc.[Nr_] collate database_default
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				coc.[Naam] + ' ' + tty.[Code] <> cob.[Omschrijving] collate database_default
				
			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			; with tel ([Eenheidnr_], [Aantal])
			as (select cok.[Eenheidnr_] collate database_default, count(*) [Aantal]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-Kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] and oge.[Common Area] = 1
				where cok.[Clustersoort] in ('BOUWBLOK')
				group by cok.[Eenheidnr_]
				having count(*) > 1)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'Gekoppeld aan ' + convert(varchar(10), tel.[Aantal]) + ' bouwblokken' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join tel
				on cob.[Collectief object] = tel.[Eenheidnr_]
				inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) 

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'10) Gekoppeld collectief object cluster matcht niet met FT cluster ' + cob.[FT clusternr],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				tty.[Code] in ('PARKEERGA', 'PARKEERTER') and
				cob.[Collectief object clusternr] <> '' and
				cob.[FT clusternr] <> '' and				
				left(substring(cob.[Collectief object clusternr], patindex('%[0-9]%', cob.[Collectief object clusternr]), 100), 
					patindex('%[^0-9]%', substring(cob.[Collectief object clusternr], patindex('%[0-9]%', cob.[Collectief object clusternr]), 100) + 'r') -1) <>
				left(substring(cob.[FT clusternr], patindex('%[0-9]%', cob.[FT clusternr]), 100), 
					patindex('%[^0-9]%', substring(cob.[FT clusternr], patindex('%[0-9]%', cob.[FT clusternr]), 100) + 'r') -1)

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Collectief object = ' + cob.[Collectief object] + '; Omschrijving = ' + cob.[Omschrijving] + '; Type = ' + tty.[Technisch type] [Omschrijving],
					'5) Nummer collectief object anders dan ''CO-''<8 cijfers>.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id], 
					cob.[Collectief object] [Eenheidnr]
				from [staedion_dm].[Eenheden].[Collectieve objecten] cob inner join [staedion_dm].[Eenheden].[Technisch type] tty
				on cob.[Technisch type_id] = tty.[Technisch type_id]
				where cob.Ingangsdatum <= @Laaddatum and
				(cob.Einddatum is null or cob.Einddatum >= @Laaddatum) and
				patindex('CO-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', cob.[Collectief object]) = 0

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

		end

	set @bericht = 'Entiteit ' + @Entiteit + ' @fk_indicator = '+ coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') + 
		+ coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !') + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
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
		from [staedion_dm].[Eenheden].[Collectieve objecten] cob
		where cob.Ingangsdatum <= @Laaddatum and
		(cob.Einddatum is null or cob.Einddatum >= @Laaddatum))
	insert into [staedion_dm].[Datakwaliteit].[Realisatie] ([Waarde], [Laaddatum], [fk_indicator_id], [Teller], [Noemer], [fk_indicatordimensie_id])
		select count(*) Waarde, @Laaddatum [Laaddatum], @fk_indicator_id [fk_indicator_id], count(*) [Teller], nmr.[Noemer], @fk_indicatordimensie_id [fk_indicatordimensie_id]
		from nmr left outer join [staedion_dm].[Datakwaliteit].[RealisatieDetails] det 
		on 1 = 1 and
		det.[Laaddatum] = @Laaddatum and
		det.[fk_indicator_id] = @fk_indicator_id and
		det.[fk_indicatordimensie_id] = @fk_indicatordimensie_id
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
