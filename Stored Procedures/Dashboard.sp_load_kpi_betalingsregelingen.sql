SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Dashboard].[sp_load_kpi_betalingsregelingen] 
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
	exec [Dashboard].[sp_load_kpi_betalingsregelingen] 1530, '2022-01-01'
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
	from [Dashboard].[Indicator] ind inner join (values (1520), (1521), (1522), (1523), (1525), (1530), (1531), (1532), (1533)) lst(indicator_id)
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

	select convert(varchar(10), 'Nieuw') Soort, btr.[Code] [Betalingsregeling], btr.[Customer No_] [Klantnr], btr.[Object No_] [Eenheidnr_], sum(rgl.[Te betalen (LV)]) [Bedrag], count(*) [Termijnen]
	into #tel
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme] btr inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme Line] rgl
	on btr.[Code] = rgl.[Code] and rgl.[Type] = 1 -- termijnen
	where btr.[Posting Date] between datefromparts(year(@peildatum), month(@peildatum), 1) and eomonth(@peildatum) and
	btr.[Termination Code] not in ('FB') and not exists (
		select 1
		from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme] wyz
		where wyz.[Last Date Modified] between datefromparts(year(dateadd(d, -day(@peildatum), @peildatum)), month(dateadd(d, -day(@peildatum), @peildatum)), 1) and eomonth(@peildatum) and
		wyz.[Termination Code] in ('NB') and
		wyz.[Customer No_] = btr.[Customer No_])
	group by btr.[Code], btr.[Customer No_], btr.[Object No_]

	insert into #tel
		select convert(varchar(10), 'Gewijzigd') Soort, btr.[Code] [Betalingsregeling], btr.[Customer No_] [Klantnr], btr.[Object No_] [Eenheidnr_], sum(rgl.[Te betalen (LV)]) [Bedrag], count(*) [Termijnen]
		from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme] btr inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme Line] rgl
		on btr.[Code] = rgl.[Code] and rgl.[Type] = 1 -- termijnen
		where btr.[Posting Date] between datefromparts(year(@peildatum), month(@peildatum), 1) and eomonth(@peildatum) and
		btr.[Termination Code] not in ('FB') and exists (
			select 1
			from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme] wyz
			where wyz.[Last Date Modified] between datefromparts(year(dateadd(d, -day(@peildatum), @peildatum)), month(dateadd(d, -day(@peildatum), @peildatum)), 1) and eomonth(@peildatum) and
			wyz.[Termination Code] in ('NB') and
			wyz.[Customer No_] = btr.[Customer No_])
		group by btr.[Code], btr.[Customer No_], btr.[Object No_]

	insert into [staedion_dm].[Dashboard].[Realisatie] ([fk_indicator_id], [Datum], [Waarde], [Laaddatum])
		-- 1520 aantal nieuw aangemaakte betalingsregelingen exclusief foutief aangemaakt en gewijzigde regelingen
		select 1520 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1520 or @IndicatorID is null)
		union
		-- 1521 totaal bedrag nieuw aangemaakte betalingsregelingen exclusief foutief aangemaakt en gewijzigde regelingen
		select 1521 [fk_indicator_id], eomonth(@peildatum) [Datum], round(sum(tel.[Bedrag]) / 1000.0, 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1521 or @IndicatorID is null)
		union
		-- 1522 gemiddeld termijnbedrag nieuw aangemaakte betalingsregelingen exclusief foutief aangemaakt en gewijzigde regelingen
		select 1522 [fk_indicator_id], eomonth(@peildatum) [Datum], round(avg(tel.[Bedrag] / (tel.[Termijnen] * 1.0)), 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1522 or @IndicatorID is null)
		union
		-- 1523 gemiddeld aantal termijnen nieuw aangemaakte betalingsregelingen exclusief foutief aangemaakt en gewijzigde regelingen
		select 1523 [fk_indicator_id], eomonth(@peildatum) [Datum], round(avg(tel.[Termijnen] * 1.0), 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1523 or @IndicatorID is null)
		union
		-- 1525 Aantal gewijzigde betalingsregelingen 
		select 1525 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1525 or @IndicatorID is null)
		union
		-- 1531 Totaal bedrag gewijzigde betalingsregelingen 
		select 1531 [fk_indicator_id], eomonth(@peildatum) [Datum], round(sum(tel.[Bedrag]) / 1000.0, 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1531 or @IndicatorID is null)
		union
		-- 1532 Gem. termijnbedrag gewijzigde betalingsregelingen 
		select 1532 [fk_indicator_id], eomonth(@peildatum) [Datum], round(avg(tel.[Bedrag] / (tel.[Termijnen] * 1.0)), 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1532 or @IndicatorID is null)
		union
		-- 1533 Gem. aantal termijnen gewijzigde betalingsregelingen 
		select 1533 [fk_indicator_id], eomonth(@peildatum) [Datum], round(avg(tel.[Termijnen] * 1.0), 2), getdate() [Laaddatum]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1533 or @IndicatorID is null)

	insert into [staedion_dm].[Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum], [Laaddatum], [Waarde], [Teller], [Noemer], [Omschrijving], 
		[Detail_01], [Detail_02], [Detail_03], [Detail_04], [eenheidnummer], [klantnummer], [betalingsregelingnummer])
		select 1520 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1520 or @IndicatorID is null)
		union
		select 1521 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], round(tel.[Bedrag] / 1000.0, 2) [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1521 or @IndicatorID is null)
		union
		select 1522 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], round(tel.[Bedrag] / (tel.[Termijnen] * 1.0), 2) [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1522 or @IndicatorID is null)
		union
		select 1523 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], tel.[Termijnen] * 1.0 [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Nieuw' and
		(@IndicatorID = 1523 or @IndicatorID is null)
		union
		select 1525 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1525 or @IndicatorID is null)
		union
		select 1531 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], round(tel.[Bedrag] / 1000.0, 2) [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1531 or @IndicatorID is null)
		union
		select 1532 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], round(tel.[Bedrag] / (tel.[Termijnen] * 1.0), 2) [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1532 or @IndicatorID is null)
		union
		select 1533 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], tel.[Termijnen] * 1.0 [Waarde], null [Teller], null [Noemer], tel.[Betalingsregeling] + '; ' + tel.[Klantnr] [Omschrijving], 
			format(tel.[bedrag], '#,##0.00', 'NL-nl') [Detail_01],  
			format(tel.termijnen, '#0') [Detail_02], 
			format(tel.[Bedrag] / tel.Termijnen, '#,##0.00', 'NL-nl') [Detail_03], 
			case when tel.[Termijnen] < 4 then '1-3 maanden'
				when tel.[Termijnen] < 7 then '3-6 maanden'
				when tel.[Termijnen] < 10 then '6-9 maanden'
				when tel.[Termijnen] < 13 then '10-12 maanden'
				when tel.[Termijnen] < 19 then '13-18 maanden'
				when tel.[Termijnen] < 25 then '19-24 termijnen'
				when tel.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_04], tel.[Eenheidnr_] [eenheidnummer], tel.[Klantnr] [klantnummer], tel.[Betalingsregeling] [betalingsregelingnummer]
		from #tel tel
		where tel.Soort = 'Gewijzigd' and
		(@IndicatorID = 1533 or @IndicatorID is null)

	set @AantalRecords = @@rowcount;

	drop table if exists #tel

	drop table if exists #res

	select btr.[Code] [Betalingsregeling], btr.[Customer No_] [Klantnr], btr.[Object No_] [Eenheidnr_], btr.[Termination Code] [Afsluitreden], btr.[Last Date Modified] [Afsluitdatum],
		sum(rgl.[Te betalen (LV)]) [Bedrag], count(*) [Termijnen]
	into #res
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme] btr inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Payment Scheme Line] rgl
	on btr.[Code] = rgl.[Code] and rgl.[Type] = 1 -- termijnen
	where btr.[Last Date Modified] between datefromparts(year(@peildatum), 1, 1) and eomonth(@peildatum) and
	btr.[Termination Code] not in ('FB', 'NB', '') 
	group by btr.[Code], btr.[Customer No_], btr.[Object No_], btr.[Termination Code], btr.[Last Date Modified]
	
	insert into [staedion_dm].[Dashboard].[Realisatie] ([fk_indicator_id], [Datum], [Waarde], [Laaddatum])
		-- 1530 percentage geslaagde betalingsregelingen
		select 1530 [fk_indicator_id], eomonth(@peildatum) [Datum], sum(iif(res.[Afsluitreden] = 'BV', 100.0, 0.0)) / count(*), getdate() [Laaddatum]
		from #res res

	insert into [staedion_dm].[Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum], [Laaddatum], [Waarde], [Teller], [Noemer], [Omschrijving], 
		[Detail_01], [Detail_02], [Detail_03], [Detail_04], [Detail_05], [Detail_06], [eenheidnummer], [klantnummer], [betalingsregelingnummer])
		select 1530 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], iif(res.[Afsluitreden] = 'BV', 1, 0) [Waarde], iif(res.[Afsluitreden] = 'BV', 1, 0) [Teller], 1 [Noemer], res.[Betalingsregeling] + '; ' + res.[Klantnr] [Omschrijving], 
			res.[Afsluitreden] [Detail_01],
			res.[Afsluitdatum] [Detail_02],
			format(res.[Bedrag], '#,##0.00') [Detail_03],
			format(res.[Termijnen], '#0') [Detail_04],
			format(res.[Bedrag] / res.Termijnen, '#,##0.00', 'NL-nl') [Detail_05], 
			case when res.[Termijnen] < 4 then '1-3 maanden'
				when res.[Termijnen] < 7 then '3-6 maanden'
				when res.[Termijnen] < 10 then '6-9 maanden'
				when res.[Termijnen] < 13 then '10-12 maanden'
				when res.[Termijnen] < 19 then '13-18 maanden'
				when res.[Termijnen] < 25 then '19-24 termijnen'
				when res.[Termijnen] < 37 then '25-36 termijnen'
				else '> 36 maanden' end [Detail_06], 
			res.[Eenheidnr_] [eenheidnummer], res.[Klantnr] [klantnummer], res.[Betalingsregeling] [betalingsregelingnummer]
		from #res res
		where eomonth(res.[Afsluitdatum]) = eomonth(@peildatum) and
		(@IndicatorID = 1530 or @IndicatorID is null)

	set @AantalRecords = @AantalRecords + @@rowcount

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
