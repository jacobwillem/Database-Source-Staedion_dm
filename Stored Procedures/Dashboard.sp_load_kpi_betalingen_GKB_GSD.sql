SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Dashboard].[sp_load_kpi_betalingen_GKB_GSD] 
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


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
	exec [Dashboard].[sp_load_kpi_betalingen_GKB_GSD] '2022-01-01', null
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
begin try
	set nocount on
	--declare @peildatum date = '2022-03-15', @IndicatorID int

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
	from [Dashboard].[Indicator] ind inner join (values (1585), (1586), (1587), (1588)) lst(indicator_id)
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
	-- declare @peildatum date = '2022-04-30'
	drop table if exists #tel

	select iif(til.[IBAN No_] in ('NL26BNGH0285140310'), 'GSD', 'GKB') bron, til.[IBAN No_] collate database_default [Rekeningnr], 
		til.[Name] collate database_default [Rekeninghouder], til.[Unstructured Remittance Info] collate database_default [Afschrift info], 
		cle.[Description] collate database_default [Omschrijving], convert(decimal(12, 2), til.Amount) [Bedrag],
		cle.[Customer No_] collate database_default [Klantnr], cle.[Posting Date] [Boekdatum], cle.[Eenheidnr_] collate database_default [Eenheidnummer], 
		cle.[Entry No_] [Klantpostvolgnr]
	into #tel
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Telebank Import line] til inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cust_ Ledger Entry] cle 
	on til.[Cust_ Ledger Entry No_] = cle.[Entry No_]
	where til.[IBAN No_] in ('NL30INGB0000003748', 'NL48BNGH0285017403', 'NL48BNGH0285140302', 'NL29BNGH0285140353', 'NL26BNGH0285140310') and
	til.Amount > 0 and
	cle.[Posting Date] between dateadd(d, 1 - day(@peildatum), @peildatum) and eomonth(@peildatum)

	insert into [staedion_dm].[Dashboard].[Realisatie] ([fk_indicator_id], [Datum], [Waarde], [Laaddatum])
		-- 1585 aantal ontvangsten GKB
		select 1585 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #tel tel
		where tel.Bron = 'GKB' and
		(@IndicatorID = 1585 or @IndicatorID is null)
		union
		-- 1586 Bedrag ontvangen GKB x € 1000
		select 1586 [fk_indicator_id], eomonth(@peildatum) [Datum], round(sum(tel.[Bedrag]) / 1000.0, 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Bron = 'GKB' and
		(@IndicatorID = 1586 or @IndicatorID is null)
		union
		-- 1587 aantal ontvangsten GSD
		select 1587 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #tel tel
		where tel.Bron = 'GSD' and
		(@IndicatorID = 1587 or @IndicatorID is null)
		union
		-- 1588 Bedrag ontvangen GSD x € 1000
		select 1588 [fk_indicator_id], eomonth(@peildatum) [Datum], round(sum(tel.[Bedrag]) / 1000.0, 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Bron = 'GSD' and
		(@IndicatorID = 1588 or @IndicatorID is null)

	insert into [staedion_dm].[Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum], [Laaddatum], [Waarde], [Teller], [Noemer], [Omschrijving], 
		[Detail_01], [Detail_02], [Detail_03], [Detail_04], [Detail_05], [Detail_06], [Detail_07], [Detail_08], [eenheidnummer], [klantnummer])
		select 1585 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1.0 [Waarde], null [Teller], null [Noemer], tel.[bron] + '; ' + tel.[Klantnr] [Omschrijving], 
			tel.bron [Detail_01],
			tel.Rekeningnr [Detail_02],
			tel.Rekeninghouder [Detail_03],
			tel.[Afschrift info] [Detail_04],
			format(tel.[Boekdatum], 'dd-MM-yyyy') [Detail_05],
			format(tel.[Klantpostvolgnr], '#') [Detail_06],
			tel.Omschrijving [Detail_07],
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_08],
			tel.[Eenheidnummer], tel.[Klantnr] [klantnummer]
		from #tel tel
		where tel.Bron = 'GKB' and
		(@IndicatorID = 1585 or @IndicatorID is null)
		union
		select 1586 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], tel.[bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], tel.[bron] + '; ' + tel.[Klantnr] [Omschrijving], 
			tel.bron [Detail_01],
			tel.Rekeningnr [Detail_02],
			tel.Rekeninghouder [Detail_03],
			tel.[Afschrift info] [Detail_04],
			format(tel.[Boekdatum], 'dd-MM-yyyy') [Detail_05],
			format(tel.[Klantpostvolgnr], '#') [Detail_06],
			tel.Omschrijving [Detail_07],
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_08],
			tel.[Eenheidnummer], tel.[Klantnr] [klantnummer]
		from #tel tel
		where tel.Bron = 'GKB' and
		(@IndicatorID = 1586 or @IndicatorID is null)
		union
		select 1587 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], tel.[bron] + '; ' + tel.[Klantnr] [Omschrijving], 
			tel.bron [Detail_01],
			tel.Rekeningnr [Detail_02],
			tel.Rekeninghouder [Detail_03],
			tel.[Afschrift info] [Detail_04],
			format(tel.[Boekdatum], 'dd-MM-yyyy') [Detail_05],
			format(tel.[Klantpostvolgnr], '#') [Detail_06],
			tel.Omschrijving [Detail_07],
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_08],
			tel.[Eenheidnummer], tel.[Klantnr] [klantnummer]
		from #tel tel
		where tel.Bron = 'GSD' and
		(@IndicatorID = 1587 or @IndicatorID is null)
		union
		select 1588 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], tel.[bedrag] / 1000.0 [Waarde], null [Teller], null [Noemer], tel.[bron] + '; ' + tel.[Klantnr] [Omschrijving], 
			tel.bron [Detail_01],
			tel.Rekeningnr [Detail_02],
			tel.Rekeninghouder [Detail_03],
			tel.[Afschrift info] [Detail_04],
			format(tel.[Boekdatum], 'dd-MM-yyyy') [Detail_05],
			format(tel.[Klantpostvolgnr], '#') [Detail_06],
			tel.Omschrijving [Detail_07],
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_08],
			tel.[Eenheidnummer], tel.[Klantnr] [klantnummer]
		from #tel tel
		where tel.Bron = 'GSD' and
		(@IndicatorID = 1588 or @IndicatorID is null)

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
