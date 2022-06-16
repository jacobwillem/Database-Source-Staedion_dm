SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Dashboard].[sp_load_kpi_ideal] 
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
	exec [Dashboard].[sp_load_kpi_ideal] null, '2022-05-01'
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
begin try
	set nocount on
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
	from [Dashboard].[Indicator] ind inner join (values (1595), (1596)) lst(indicator_id)
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
	-- declare @peildatum date = '2022-01-30'
	drop table if exists #dig

	select cle.[Entry No_] [Volgnummer], cle.[Description] [Omschrijving], cle.[Document No_] [Documentnr], cle.[Document Date] [Boekdatum], 
		cle.[Customer No_] [Klantnr], cle.[Eenheidnr_] [Eenheidnr], -dcl.[Amount (LCY)] [Bedrag], row_number() over (partition by cle.[Description] order by dcl.[Amount (LCY)]) [Volgnr]
	into #dig
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cust_ Ledger Entry] cle inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Detailed Cust_ Ledg_ Entry] dcl
	on cle.[Entry No_] = dcl.[Cust_ Ledger Entry No_] and dcl.[Entry Type] = 1
	where cle.[Document Type] = 1 and -- betalingen
	cle.[Posting Date] between datefromparts(year(@peildatum), month(@peildatum), 1) and eomonth(@peildatum) and
	cle.[Description] like 'Ideal%'

	insert into [staedion_dm].[Dashboard].[Realisatie] ([fk_indicator_id], [Datum], [Waarde], [Laaddatum])
		-- 1595 Aantal ontvangen iDeal
		select 1595 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #dig dig
		where dig.[Volgnr] = 1 and
		(@IndicatorID = 1595 or @IndicatorID is null)
		union
		-- 1596 Bedrag ontvangen iDeal
		select 1596 [fk_indicator_id], eomonth(@peildatum) [Datum], sum(dig.[Bedrag]),  getdate() [Laaddatum]
		from #dig dig
		where (@IndicatorID = 1596 or @IndicatorID is null)

	insert into [staedion_dm].[Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum], [Laaddatum], [Waarde], [Teller], [Noemer], [Omschrijving], 
		[Detail_01], [Detail_02], [Detail_03], [Detail_04], [Detail_05], [eenheidnummer], [klantnummer])
		select 1595 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], iif(dig.[Volgnr] = 1, 1, 0) [Waarde], null [Teller], null [Noemer], dig.[Klantnr] + '; ' + dig.[Eenheidnr] [Omschrijving], 
			format(dig.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(dig.[Boekdatum], 'dd-MM-yyyy') [Detail_02], 
			dig.[Documentnr] [Detail_03], 
			dig.[Volgnummer] [Detail_04], 
			dig.[Omschrijving] [Detail_05], 
			dig.[Eenheidnr] [eenheidnummer], dig.[Klantnr] [klantnummer]
		from #dig dig
		where (@IndicatorID = 1595 or @IndicatorID is null)
		union
		select 1596 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], dig.[Bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], dig.[Klantnr] + '; ' + dig.[Eenheidnr] [Omschrijving], 
			format(dig.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(dig.[Boekdatum], 'dd-MM-yyyy') [Detail_02], 
			dig.[Documentnr] [Detail_03], 
			dig.[Volgnummer] [Detail_04], 
			dig.[Omschrijving] [Detail_05], 
			dig.[Eenheidnr] [eenheidnummer], dig.[Klantnr] [klantnummer]
		from #dig dig
		where (@IndicatorID = 1596 or @IndicatorID is null)

	set @AantalRecords = @@rowcount;

	drop table if exists #dig

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
