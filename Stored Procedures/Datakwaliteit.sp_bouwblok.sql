SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Datakwaliteit].[sp_bouwblok] (@fk_indicator_id int, @fk_indicatordimensie_id int)
as
begin try
	-- declare @Laaddatum date = getdate(), @fk_indicator_id int = 7210, @fk_indicatordimensie_id int = 19
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
	DECLARE @Entiteit as nvarchar(50) = 'Bouwblok'
	
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
		from (values (7210, 15),
					 (7210, 19)) lst(indicator_id, indicatordimensie_id)
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

			-- Bouwkblok is aan matchend FT cluster gekoppeld
			; with bbl (clusternr, naam, ftcluster, numeriekdeel)
			as (select clu.[Nr_], clu.[Naam], clu.[Component of Cluster],
					left(substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100), 
							patindex('%[^0-9]%', substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100) + 'r') -1)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'BOUWBLOK')
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + bbl.[clusternr] + '; Naam = ' + bbl.[Naam] + '; Gekoppeld cluster: ' + bbl.ftcluster [Omschrijving],
					'1) Geen (juist) gekoppeld FT cluster.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					bbl.[clusternr] [Eenheidnr]
				from bbl
				where bbl.ftcluster <> 'FT-' + bbl.numeriekdeel

			set @AantalRecords = @@ROWCOUNT

			-- Bouwblok heeft tenminste 1 OGEH
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'3) Geen gekoppelde OGEH.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'BOUWBLOK' and
				not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] cok
					where cok.[Common Area] = 0 and
					cok.[Clusternr_] = clu.[Nr_])

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

		end

	if @fk_indicatordimensie_id = 19 -- volledigheid
		begin

			-- gekoppeld FT cluster bestaat niet (meer)
			; with bbl (clusternr, naam, ftcluster, numeriekdeel)
			as (select clu.[Nr_], clu.[Naam], clu.[Component of Cluster],
					left(substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100), 
							patindex('%[^0-9]%', substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100) + 'r') -1)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'BOUWBLOK')
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + bbl.[clusternr] + '; Naam = ' + bbl.[Naam] + '; Gekoppeld cluster: ' + bbl.ftcluster [Omschrijving],
					'1) Gekoppeld FT cluster bestaat niet (meer).' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					bbl.[clusternr] [Eenheidnr]
				from bbl
				where bbl.ftcluster = 'FT-' + bbl.numeriekdeel and
				not exists (select 1
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
					where clu.[Clustersoort] = 'FTCLUSTER' and
					clu.[Nr_] = bbl.ftcluster)

			set @AantalRecords = @@ROWCOUNT

			-- bouwbloknummer matched niet met kostenplaatsnummer
			; with bbl (clusternr, naam, kostenplaats, numeriekdeel)
			as (select clu.[Nr_], clu.[Naam], clu.[Global Dimension 1 Code] [kostenplaats],
					left(substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100), 
							patindex('%[^0-9]%', substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100) + 'r') -1)
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'BOUWBLOK')
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + bbl.[clusternr] + '; Naam = ' + bbl.[Naam] +
						'; Kostenplaats = ' + bbl.[kostenplaats] [Omschrijving],
					'7) Numeriek deel bouwbloknummer is niet gelijk aan kostenplaatscode.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					bbl.clusternr [Eenheidnr]
				from bbl
				where bbl.[kostenplaats] <> bbl.[numeriekdeel]				

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- Bouwblok is deels aan VvE gekoppeld of aan meer dan 1 VvE gekoppeld
			; with bbl ([Bouwblok], [Eenheidnr_])
			as (select bbl.[Clusternr_], bbl.[Eenheidnr_]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] bbl 
				where bbl.clustersoort = 'BOUWBLOK' and bbl.[Common Area] = 0),
			vve ([VvE], [Eenheidnr_])
			as (select vve.[Clusternr_], vve.[Eenheidnr_]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] vve
				where vve.clustersoort = 'VVE' and vve.[Common Area] = 0),
			cmb ([Bouwblok], [Eenheidnr_], [VvE])
			as (select bbl.[Bouwblok], bbl.[Eenheidnr_], max(vve.[VvE]) [VvE]
				from bbl left outer join vve
				on bbl.[Eenheidnr_] = vve.[Eenheidnr_]
				group by bbl.[Bouwblok], bbl.[Eenheidnr_]),
			res ([Bouwblok], [Eenheden], [In VvE])
			as (select cmb.[Bouwblok], count(*) [Eenheden], sum(iif(cmb.[VvE] is null, 0, 1)) [In VvE]
				from cmb
				group by cmb.[Bouwblok]
				having count(*) <> sum(iif(cmb.[VvE] is null, 0, 1)) and sum(iif(cmb.[VvE] is null, 0, 1)) > 0),
			mlt ([Bouwblok], [VvE's])
			as (select unk.[Bouwblok], string_agg(unk.[VvE], ', ') [VvE's]
				from (select cmb.[Bouwblok], cmb.[VvE]
					from cmb
					where cmb.[VvE] is not null
					group by cmb.[Bouwblok], cmb.[VvE]) as unk
				group by unk.[Bouwblok])
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] + '; Aantal OGEH''s = ' + format(res.[Eenheden], '#') +
					'; In VvE = ' + format(res.[In VvE], '#') [Omschrijving],
					'4) Niet alle OGEH''s in bouwblok zitten in VvE.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from res inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				on res.[Bouwblok] = clu.[Nr_]
				union
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] + 
					'; VvE''s = ' + mlt.[VvE's] [Omschrijving],
					'5) Bouwblok is aan OGEH''s uit verschillende VvE''s gekoppeld.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from mlt inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				on mlt.[Bouwblok] = clu.[Nr_] and charindex(',', mlt.[VvE's]) > 0
				

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
			/*

			-- bouwblok is aan meer dan 1000 OGEH gekoppeld
			-- uitgeschakeld bleek geen logische voorwaarde te zijn
			; with tel ([Nr_], [Naam], [Aantal])
			as (select clu.[Nr_], clu.[Naam], count(*) [Aantal]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				on cok.[Clusternr_] = clu.[Nr_] and clu.[Clustersoort] = 'BOUWBLOK'
				inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] and oge.[Common Area] = 0
				group by clu.[Nr_], clu.[Naam]
				having count(*) > 1000)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + tel.[Nr_] + '; Naam = ' + tel.[Naam] [Omschrijving],
					'Is aan ' + format(tel.[Aantal], '#') + ' OGEH''s gekoppeld.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					tel.[Nr_] [Eenheidnr]
				from tel

			set @AantalRecords = @AantalRecords + @@ROWCOUNT
			*/

			-- bouwblok begint met formaat nummering
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok  = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'6) Heeft niet formaat BB-<4 cijfers><1 hoofdletter>.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr] 
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] = 'BOUWBLOK' and				
				patindex('BB-[0-9][0-9][0-9][0-9][A-Z]', clu.[Nr_]) = 0

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- Deelbouwblokken moeten doorlopend vanaf A worden gelabeld

			; with bbl (clusternr, naam, numeriekdeel, volgnr)
				as (select clu.[Nr_], clu.[Naam], 
						left(substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100), 
								patindex('%[^0-9]%', substring(clu.[Nr_], patindex('%[0-9]%', clu.[Nr_]), 100) + 'r') -1), 
						ascii(right(clu.[Nr_], 1)) -64
					from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
					where clu.[Clustersoort] = 'BOUWBLOK' and
					right(clu.[Nr_], 1) >= 'A'),
				tel (numeriekdeel, aantal, eerste, laatste)
				as (select bbl.numeriekdeel, count(*), min(volgnr), max(volgnr)
					from bbl 
					group by bbl.numeriekdeel
					having min(volgnr) > 1 or count(*) <> max(volgnr)),
				det (clusternr, naam, numeriekdeel, aantal, eerste, laatste, volgnr)
				as (select bbl.clusternr, bbl.naam, bbl.numeriekdeel, tel.aantal, tel.eerste, tel.laatste, 
						row_number() over (partition by bbl.numeriekdeel order by bbl.clusternr) volgnr
					from tel inner join bbl
					on tel.numeriekdeel = bbl.numeriekdeel)
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + det.[clusternr] + '; Naam = ' + det.[Naam] [Omschrijving],
					'8) Deelbouwblok niet doorlopend van A tot ' + char(64 + det.laatste) + '.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					det.clusternr [Eenheidnr]
			from det
			where det.volgnr = 1

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- bouwblok heeft clustersoort BOUWBLOK
			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'10) Heeft clustersoort ' + clu.[Clustersoort] + '.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu 
				where clu.[Clustersoort] <> 'BOUWBLOK' and
				clu.[Nr_] like 'BB-%'

			set @AantalRecords = @AantalRecords + @@ROWCOUNT

			-- als alle gekoppelde eenheden uit exploitatie dan geen gekoppeld collectief object
						; with tel ([Bouwblok], [Collectieve objecten], [In exploitatie])
			as (select clu.[Nr_] [Bouwblok], sum(oge.[Common Area]) [Collectieve objecten], 
					sum(iif(oge.[Einde exploitatie] > convert(date, getdate()) or oge.[Einde exploitatie] = '1753-01-01', 1 - oge.[Common Area], 0)) [In exploitatie]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster-OGE-kruistabel] cok inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu
				on cok.[Clusternr_] = clu.[Nr_] and clu.[Clustersoort] = 'BOUWBLOK'
				inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
				on cok.[Eenheidnr_] = oge.[Nr_] 
				group by clu.[Nr_] 
				having sum(iif(oge.[Einde exploitatie] > convert(date, getdate()) or oge.[Einde exploitatie] = '1753-01-01', 1 - oge.[Common Area], 0)) = 0)
--			insert into [staedion_dm].[Datakwaliteit].[RealisatieDetails] ([Laaddatum], [Omschrijving], [Bevinding], [fk_indicator_id], [fk_indicatordimensie_id], [Eenheidnr])
				select @Laaddatum [Laaddatum], 
					'Bouwblok = ' + clu.[Nr_] + '; Naam = ' + clu.[Naam] [Omschrijving],
					'11) Bouwblok zonder actieve OGEH''s gekoppeld aan ' + convert(varchar(10), tel.[Collectieve objecten]) + ' collectieve objecten.' [Bevinding],
					@fk_indicator_id [fk_indicator_id],
					@fk_indicatordimensie_id [fk_indicatordimensie_id],
					clu.[Nr_] [Eenheidnr]
				from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cluster] clu inner join tel
				on clu.[Nr_] = tel.[Bouwblok]
				where tel.[Collectieve objecten] > 0

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
