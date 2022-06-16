SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Dashboard].[sp_load_kpi_deurwaarderszaken] 
			( @Peildatum AS DATE = NULL
			, @IndicatorID AS INT = NULL) 
as
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon kan gebruikt worden voor nieuwe procedures of het omzetten van oude procedures. 
Tbv uniformiteit + logging + kans op fouten verminderen.>
Logging van de procedure vindt plaats door de aanroep van staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten].
Dit schrijft de stappen weg naar tabel staedion_dm.[DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten] met parameters
@Bron => Databaseobject
@Variabelen => eventuele parameters bijv peildatum
@Categorie => schemanaam dashboard bijv of kpi of ETL maatwerk, ETL datamart, Power Automate, ETL oud maatwerk, Dataset rapport laden, DatabaseBeheer
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Dashboard'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_sjabloon';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220525 JVDW parameters omgedraaid - vanwege foutmelding bij standaardaanroep met alleen Peildatum als argument


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
exec staedion_dm.[Dashboard].[sp_load_kpi_deurwaarderszaken] @IndicatorID = NULL, @Peildatum = '2022-05-01'
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
begin try
	set nocount on
	-- declare @Peildatum date = '2022-01-01', @IndicatorID AS INT = NULL
	declare @Onderwerp nvarchar(100);

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Variabelen definieren';
	----------------------------------------------------------------------------------- 
	declare @Bron nvarchar(255) = object_name(@@procid),
		@Variabelen nvarchar(255),
		@Categorie nvarchar(255) = coalesce(object_schema_name(@@procid),'Overig'),	
		@AantalRecords decimal(12, 0),		
		@Bericht nvarchar(255),
		@Start datetime,
		@Finish datetime

	if @Peildatum is null
		set @Peildatum = dateadd(d, -day(getdate()), getdate())

	set @Variabelen = '@IndicatorID = ' + coalesce(cast(@IndicatorID as nvarchar(10)), 'null') + ' ; ' 
								+ '@Peildatum = ' + coalesce(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 

	set	@Start = current_timestamp

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'BEGIN';
	----------------------------------------------------------------------------------- 
	exec staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
		@Categorie = @Categorie
		,@DatabaseObject = @Bron
		,@Variabelen = @Variabelen
		,@Bericht = @Onderwerp

	set @bericht = 'Ongeldige parameters voor ' + object_name(@@procid) + ' @fk_indicator = '+ coalesce(format(@IndicatorID, 'N0' ),'GEEN !') 

	drop table if exists #lst

	-- lijst toegestane indicatoren die door deze procedure mogen worden gevuld
	select ind.id fk_indicator_id, ind.Omschrijving
	into #lst
	from [Dashboard].[Indicator] ind inner join (values (1540), (1541), (1550), (1551), (1552), (1553), (1554), (1555), (1556), (1557)) lst(indicator_id)
	on ind.id = lst.indicator_id
	where ind.id = @IndicatorID or @IndicatorID is null
	
	-- procedure alleen uitvoeren als er geldige parameters zijn meegegeven om te voorkomen dat er 
	-- verkeerde gegevens worden verwijderd
	if (select count(*) from #lst) = 0
		-- genereer custom error
		raiserror (@bericht, 11, 1)

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Welke datumreeks te wissen en te vullen ?';
	----------------------------------------------------------------------------------- 

	drop table if exists #dat
	/*
	; with frq (fk_indicator_id, frequentie)
	as (select ind.id, isnull(fre.[Omschrijving], 'Maandelijks')
		from [Dashboard].[Indicator] ind inner join #lst lst
		on ind.id = lst.fk_indicator_id
		left outer join [Dashboard].[Frequentie] fre
		on ind.fk_frequentie_id = fre.id)
	select frq.fk_indicator_id, case frq.frequentie when 'Dagelijks' then @Peildatum
		when 'Wekelijks' then dateadd(d, -(datepart(weekday, @Peildatum) + 5 + @@datefirst) % 7, @Peildatum)
		when '4 Maandelijks' then datefromparts(year(@Peildatum), case when month(@Peildatum) > 8 then 9 when month(@Peildatum) > 4 then 5 else 1 end, 1)
		-- default waarde is maandelijks
		else datefromparts(year(@Peildatum), month(@Peildatum), 1) end van,
		case frq.frequentie when 'Dagelijks' then @Peildatum
		when 'Wekelijks' then dateadd(d, 6 - (datepart(weekday, @Peildatum) + 5 + @@datefirst) % 7, @Peildatum)
		when '4 Maandelijks' then eomonth(datefromparts(year(@Peildatum), case when month(@Peildatum) > 8 then 12 when month(@Peildatum) > 4 then 8 else 4 end, 1))
		-- default waarde is maandelijks
		else eomonth(@Peildatum) end tm, isnull(frq.frequentie, 'leeg dus maandelijks') frequentie
	into #dat
	from frq
	*/
	-- standaard oplossing uitgeschakeld altijd hele maand van de peildatum wissen voor de geselecteerde indicator(en)
	; with frq (fk_indicator_id, frequentie)
	as (select ind.id, isnull(fre.[Omschrijving], 'Maandelijks')
		from [Dashboard].[Indicator] ind inner join #lst lst
		on ind.id = lst.fk_indicator_id
		left outer join [Dashboard].[Frequentie] fre
		on ind.fk_frequentie_id = fre.id)
	select frq.fk_indicator_id, datefromparts(year(@Peildatum), month(@Peildatum), 1) van,
		eomonth(@Peildatum) tm, isnull(frq.frequentie, 'leeg dus maandelijks') frequentie
	into #dat
	from frq

	select @Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
						+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
						+ 'Frequentie: ' + dat.frequentie + ' ; ' 
						+ 'Datumreeks ' + FORMAT(dat.van, 'dd-MM-yyyy','nl-NL') + ' - '  + FORMAT(dat.tm, 'dd-MM-yyyy','nl-NL')
	from #dat dat

	exec staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
		@Categorie = @Categorie
		,@DatabaseObject = @Bron
		,@Variabelen = @Variabelen
		,@Bericht = @Onderwerp

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Wissen regels';
	----------------------------------------------------------------------------------- 
	-- wissen summary regels voor fk_indicator_id's in #lst
	delete from [staedion_dm].[Dashboard].[Realisatie]
	where [Realisatie].fk_indicator_id in (select lst.fk_indicator_id from #lst lst) and
	[Realisatie].[Datum] between (select dat.van from #dat dat where dat.fk_indicator_id = Realisatie.fk_indicator_id) and (select dat.tm from #dat dat where dat.fk_indicator_id = Realisatie.fk_indicator_id)
	
	-- wissen detailregels voor fk_indicator_id's in #lst
	delete from staedion_dm.dashboard.RealisatieDetails 
	where fk_indicator_id in (select lst.fk_indicator_id from #lst lst) and
	Datum between (select dat.van from #dat dat where dat.fk_indicator_id = realisatiedetails.fk_indicator_id) and (select dat.tm from #dat dat where dat.fk_indicator_id = realisatiedetails.fk_indicator_id)

	set @AantalRecords = @@rowcount;
	set @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
	set @Bericht = @Bericht + format(@AantalRecords, 'N0');
	exec staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]
				@Categorie = @Categorie
				,@DatabaseObject = @Bron
				,@Bericht = @Bericht

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Toevoegen regels';
	----------------------------------------------------------------------------------- 

	-- details voor nieuwe deurwaarderszaken
	drop table if exists #tel

	select dwr.[Dossiernr_] collate database_default [Dossiernr_], dwr.[Customer No_] collate database_default [Customer No_], 
		dwr.[Deurwaardernr_] collate database_default [Deurwaardernr_], dwr.[Dossiernr_ deurwaarder] collate database_default [Dossiernr_ deurwaarder], 
		dwr.[Ingangsdatum], dwr.[Afgesloten], dwr.[Reden afsluiting] collate database_default [Reden afsluiting], dwr.[Eenheidnr_] collate database_default [Eenheidnr_],
		dwr.[Saldo aangemelde stookkosten] + dwr.[Saldo aangemelde servicekosten] + dwr.[Saldo aang_ herstelkostennota] + dwr.[Saldo aang_ ov_ vorderingen] + dwr.[Saldo aangemelde huurschuld] [Overgedragen]
	into #tel
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Deurwaarderdossier] dwr
	where dwr.[Reden afsluiting] not in ('FOUT INV') and
	dwr.[Dossiernr_ deurwaarder] not like '%B%' and
	dwr.[Ingangsdatum] between datefromparts(year(@Peildatum), month(@Peildatum), 1) and eomonth(@Peildatum)
	
	-- details voor afdrachten
	drop table if exists #afd
--	declare @peildatum date = '2022-04-01'
	select bal.[Posting Date] [Boekingsdatum], 
		case when bal.[Description] like '%Bazuin%' then 'Bazuin'
			when bal.[Description] like '%Flanderijn%' then 'Flanderijn'
			when bal.[Description] like '%GGN%' then 'GGN'
			when bal.[Description] like '%LAVG%' then 'LAVG' end collate database_default Deurwaarder,
		case when bal.[Description] like '%Bazuin%' then 'LEVE-02059'
			when bal.[Description] like '%Flanderijn%' then 'LEVE-04599'
			when bal.[Description] like '%GGN%' then 'LEVE-00419'
			when bal.[Description] like '%LAVG%' then 'LEVE-02647' end collate database_default [Deurwaardernr_],
		case bal.[Document Type] when 0 then ''
			when 1 then 'Betaling'
			when 2 then 'Factuur'
			when 3 then 'Creditnota'
			when 4 then 'Rentefactuur'
			when 5 then 'Aanmaning'
			when 6 then 'Terugbetaling'
			when 9 then 'Storno'
			else 'Onbekend' end collate database_default [Documenttype],
		bal.[Document No_] collate database_default [Documentnr.],
		bal.[Description] collate database_default [Omschrijving],
		convert(decimal(20, 4), bal.[Amount]) [Bedrag],
		bal.[Entry No_] [Volgnummer], 
		bal.[Bal_ Account No_] collate database_default [Customer No_], 
		isnull((select max(1) 
			from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Additioneel] adi 
			where adi.[Customer No_] = bal.[Bal_ Account No_] and
			adi.Ingangsdatum <= bal.[Posting Date] and
			(adi.Einddatum = '1753-01-01' or adi.Einddatum >= bal.[Posting Date])), 0) actief
	into #afd
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Bank Account Ledger Entry] bal
	where bal.[Bal_ Account Type] = 1 and
	bal.[Posting Date] between datefromparts(year(@peildatum), month(@peildatum), 1) and eomonth(@peildatum) and
	(bal.[Description] like '%Bazuin%' or bal.[Description] like '%Flanderijn%' or bal.[Description] like '%GGN%' or bal.[Description] like '%LAVG%')

	insert into [staedion_dm].[Dashboard].[Realisatie] ([fk_indicator_id], [Datum], [Waarde], [Laaddatum])
		-- 1540 aantal nieuw aangemaakte deurwaarderszaken exclusief foutief aangemaakt
		select 1540 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #tel tel
		where @IndicatorID = 1540 or @IndicatorID is null
		union
		-- 1541 aangemeld initieel bedrag nieuw aangemaakte deurwaarderszaken exclusief foutief aangemaakt
		select 1541 [fk_indicator_id], eomonth(@peildatum) [Datum], round(sum(tel.[Overgedragen]) / 1000.0, 2), getdate() [Laaddatum]
		from #tel tel
		where @IndicatorID = 1541 or @IndicatorID is null
		union
		-- 1550 afdracht LAVG
		select 1550 [fk_indicator_id], eomonth(@peildatum) [Datum], sum(afd.[Bedrag]) / 1000.0, getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02647' and -- LAVG
		(@IndicatorID = 1550 or @IndicatorID is null)
		union
		-- 1551 Aantal afdrachten LAVG
		select 1551 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02647' and -- LAVG
		(@IndicatorID = 1551 or @IndicatorID is null)
		union
		-- 1552 afdracht Flanderijn
		select 1552 [fk_indicator_id], eomonth(@peildatum) [Datum], sum(afd.[Bedrag]) / 1000.0, getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-04599' and -- Flanderijn
		(@IndicatorID = 1552 or @IndicatorID is null)
		union
		-- 1553 Aantal afdrachten Flanderijn
		select 1553 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-04599' and -- Flanderijn
		(@IndicatorID = 1553 or @IndicatorID is null)
		union
		-- 1554 afdracht GGN
		select 1554 [fk_indicator_id], eomonth(@peildatum) [Datum], sum(afd.[Bedrag]) / 1000.0, getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-00419' and -- GGN
		(@IndicatorID = 1554 or @IndicatorID is null)
		union
		-- 1555 Aantal afdrachten LAVG
		select 1555 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-00419' and -- GGN
		(@IndicatorID = 1555 or @IndicatorID is null)
		union
		-- 1556 afdracht Bazuin
		select 1556 [fk_indicator_id], eomonth(@peildatum) [Datum], sum(afd.[Bedrag]) / 1000.0, getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02059' and -- GGN
		(@IndicatorID = 1556 or @IndicatorID is null)
		union
		-- 1557 Aantal afdrachten Bazuin
		select 1557 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02059' and -- GGN
		(@IndicatorID = 1557 or @IndicatorID is null)

	insert into [staedion_dm].[Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum], [Laaddatum], [Waarde], [Teller], [Noemer], [Omschrijving], 
		[Detail_01], [Detail_02], [Detail_03], [Detail_04], [Detail_05], [Detail_06], [Detail_07], [Detail_08], [eenheidnummer], [klantnummer], [dossiernummer])
		select 1540 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], 
			tel.[Dossiernr_] + '; ' + tel.[Customer No_] [Omschrijving], 
			tel.[Deurwaardernr_] [Detail_01], 
			format(tel.[Overgedragen], '#,##0.00', 'NL-nl') [Detail_02],  
			tel.[Dossiernr_ deurwaarder] [Detail_03], 
			format(tel.[Ingangsdatum], 'dd-MM-yyyy') [Detail_04], 
			null [Detail_05],
			null [Detail_06],
			null [Detail_07],
			null [Detail_08],
			tel.[Eenheidnr_] [eenheidnummer], tel.[Customer No_] [klantnummer], tel.[Dossiernr_] [dossiernummer]
		from #tel tel
		where @IndicatorID = 1540 or @IndicatorID is null
		union
		-- declare @Peildatum date = '2022-01-01', @IndicatorID AS INT = NULL
		select 1541 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], tel.[Overgedragen] / 1000.0 [Waarde], null [Teller], null [Noemer], 
			tel.[Dossiernr_] + '; ' + tel.[Customer No_] [Omschrijving], 
			tel.[Deurwaardernr_] [Detail_01], 
			format(tel.[Overgedragen], '#,##0.00', 'NL-nl') [Detail_02],  
			tel.[Dossiernr_ deurwaarder] [Detail_03], 
			format(tel.[Ingangsdatum], 'dd-MM-yyyy') [Detail_04], 
			null [Detail_05],
			null [Detail_06],
			null [Detail_07],
			null [Detail_08],
			tel.[Eenheidnr_] [eenheidnummer], tel.[Customer No_] [klantnummer], tel.[Dossiernr_] [dossiernummer]
		from #tel tel
		where @IndicatorID = 1541 or @IndicatorID is null
		union
		-- 1550 afdracht LAVG
		select 1550 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], afd.[Bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02647' and -- LAVG
		(@IndicatorID = 1550 or @IndicatorID is null)
		union
		-- declare @peildatum date = getdate(), @IndicatorID int = null
		-- 1551 Aantal afdrachten LAVG
		select 1551 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]		
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02647' and -- LAVG
		(@IndicatorID = 1551 or @IndicatorID is null)
		union
		-- 1552 afdracht Flanderijn
		select 1552 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], afd.[Bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-04599' and -- Flanderijn
		(@IndicatorID = 1552 or @IndicatorID is null)
		union
		-- 1553 Aantal afdrachten Flanderijn
		select 1553 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_]  = 'LEVE-04599' and -- Flanderijn
		(@IndicatorID = 1553 or @IndicatorID is null)
		union
		-- 1554 afdracht GGN
		select 1554 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], afd.[Bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-00419' and -- GGN
		(@IndicatorID = 1552 or @IndicatorID is null)
		union
		-- 1555 Aantal afdrachten GGN
		select 1555 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_]  = 'LEVE-00419' and -- GGN
		(@IndicatorID = 1555 or @IndicatorID is null)
		union
		-- 1556 afdracht Bazuin
		select 1556 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], afd.[Bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_] = 'LEVE-02059' and -- Bazuin
		(@IndicatorID = 1556 or @IndicatorID is null)
		union
		-- 1557 Aantal afdrachten Bazuin
		select 1557 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], 
			afd.[Deurwaarder] + '; ' + afd.[Customer No_] [Omschrijving], 
			afd.[Deurwaardernr_] [Detail_01], 
			afd.[Deurwaarder] [Detail_02],
			format(afd.[Bedrag], '#,##0.00', 'NL-nl') [Detail_03],  
			format(afd.[Boekingsdatum], 'dd-MM-yyyy') [Detail_04], 
			afd.[Documentnr.] [Detail_05],
			iif(afd.actief = 1, 'Zittend', 'Vertrokken') [Detail_06],
			afd.[Volgnummer] [Detail_07],
			afd.[Omschrijving] [Detail_08],
			null [eenheidnummer], afd.[Customer No_] [klantnummer], null [dossiernummer]
		from #afd afd
		where afd.[Deurwaardernr_]  = 'LEVE-02059' and -- Bazuin
		(@IndicatorID = 1557 or @IndicatorID is null)

	set @AantalRecords = @@rowcount;

	drop table if exists #tel

	set @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
	set @Bericht = @Bericht + format(@AantalRecords, 'N0');
	exec staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
				@Categorie = @Categorie
				,@DatabaseObject = @Bron
				,@Bericht = @Bericht

	set	@Finish = CURRENT_TIMESTAMP
	
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'EINDE';
	----------------------------------------------------------------------------------- 
	exec staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
				@Categorie = @Categorie
				,@Begintijd = @Start
				,@Eindtijd = @Finish
				,@DatabaseObject = @Bron
				,@Variabelen = @Variabelen
				,@Bericht = @Onderwerp
					
end try

begin catch

	set @Finish = current_timestamp

	declare @ErrorProcedure nvarchar(255) = error_procedure()
	declare @ErrorLine int = error_line()
	declare @ErrorNumber int = error_number()
	declare @ErrorMessage nvarchar(255) = left(error_message(), 255)

	exec staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					, @DatabaseObject = @Bron
					, @Variabelen = @Variabelen
					, @Begintijd = @start
					, @Eindtijd = @finish
					, @ErrorProcedure =  @ErrorProcedure
					, @ErrorLine = @ErrorLine
					, @ErrorNumber = @ErrorNumber
					, @ErrorMessage = @ErrorMessage

end catch
GO
