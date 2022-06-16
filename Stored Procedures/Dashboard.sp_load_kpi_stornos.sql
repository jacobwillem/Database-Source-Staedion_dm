SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Dashboard].[sp_load_kpi_stornos] 
			(	@Peildatum AS DATE = NULL,
				@IndicatorID AS INT = NULL
			) 
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
	exec [Dashboard].[sp_load_kpi_stornos] null, '2022-01-01'
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
	from [Dashboard].[Indicator] ind inner join (values (1570), (1571)) lst(indicator_id)
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
	drop table if exists #stn

	select cle.[Customer No_] Huurdernr, til.[Posting Date] [Datum Stornering], til.[Storno Reason Code] collate database_default [Code reden stornering],
		cle.[Description] [Omschrijving post], til.Amount [Bedrag stornering], cle.[Entry No_], 
		cle.Eenheidnr_, til.[IBAN No_] IBAN,
		isnull((select max(1) 
			from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Additioneel] adi 
			where adi.[Customer No_] = cle.[Customer No_] and
			adi.Ingangsdatum <= cle.[Posting Date] and
			(adi.Einddatum = '1753-01-01' or adi.Einddatum >= cle.[Posting Date])), 0) actief,
		iif(typ.[Analysis Group Code] = 'BOG', 'Ja', 'Nee') BOG
	into #stn
	from [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Telebank Import line] til inner join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Cust_ Ledger Entry] cle
	on til.[Cust_ Ledger Entry No_] = cle.[Entry No_]
	left outer join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$OGE] oge
	on cle.[Eenheidnr_] = oge.Nr_
	left outer join [S-LOGSH-PROD].[Empire].[dbo].[Staedion$Type] typ
	on oge.[Type] = typ.Code
	where til.[Storno Reason Code] <> '' and
	cle.[Description] like 'Storno%' and
	til.[Posting Date] between datefromparts(year(@peildatum), month(@peildatum), 1) and eomonth(@peildatum)

	insert into [staedion_dm].[Dashboard].[Realisatie] ([fk_indicator_id], [Datum], [Waarde], [Laaddatum])
		-- 1570 aantal storno''s
		select 1570 [fk_indicator_id], eomonth(@peildatum) [Datum], count(*), getdate() [Laaddatum]
		from #stn stn
		where (@IndicatorID = 1570 or @IndicatorID is null)
		union
		-- 1571 totaal bedrag storno''s
		select 1571 [fk_indicator_id], eomonth(@peildatum) [Datum], round(sum(stn.[Bedrag stornering]) / 1000.0, 2), getdate() [Laaddatum]
		from #stn stn
		where (@IndicatorID = 1571 or @IndicatorID is null)

	insert into [staedion_dm].[Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum], [Laaddatum], [Waarde], [Teller], [Noemer], [Omschrijving], 
		[Detail_01], [Detail_02], [Detail_03], [Detail_04], [Detail_05], [Detail_06], [Detail_07], [Detail_08], [eenheidnummer], [klantnummer])
		select 1570 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], 1 [Waarde], null [Teller], null [Noemer], stn.Huurdernr + '; ' + stn.[Code reden stornering] collate database_default [Omschrijving], 
			format(stn.[Bedrag stornering], '#,##0.00', 'NL-nl') [Detail_01],  
			format(stn.[Datum Stornering], 'dd-MM-yyyy') [Detail_02],
			stn.[Code reden stornering] [Detail_03],
			isnull(rst.[omschrijving], '<Onbekend>') [Detail_04],
			format(stn.[Entry No_], '#', 'NL-nl') [Detail_05],
			iif(stn.Actief = 0, 'Vertrokken', 'Zittend') [Detail_06],
			stn.[BOG] [Detail_07], 
			stn.[IBAN] [Detail_08], stn.[Eenheidnr_] [eenheidnummer], stn.[Huurdernr] [klantnummer]
		from #stn stn left outer join [empire_staedion_data].[dwh].dimRedenStornoEmpire rst
		on stn.[Code reden stornering] = rst.Id
		where (@IndicatorID = 1570 or @IndicatorID is null)
		union
		select 1571 [fk_indicator_id], eomonth(@peildatum) [Datum], getdate() [Laaddatum], (stn.[Bedrag stornering] / 1000.0) [Waarde], null [Teller], null [Noemer], stn.Huurdernr + '; ' + stn.[Code reden stornering] collate database_default [Omschrijving], 
			format(stn.[Bedrag stornering], '#,##0.00', 'NL-nl') [Detail_01],  
			format(stn.[Datum Stornering], 'dd-MM-yyyy') [Detail_02],
			stn.[Code reden stornering] [Detail_03],
			isnull(rst.[omschrijving], '<Onbekend>') [Detail_04],
			format(stn.[Entry No_], '#', 'NL-nl') [Detail_05],
			iif(stn.Actief = 0, 'Vertrokken', 'Zittend') [Detail_06],
			stn.[BOG] [Detail_07], 
			stn.[IBAN] [Detail_08], stn.[Eenheidnr_] [eenheidnummer], stn.[Huurdernr] [klantnummer]
		from #stn stn left outer join [empire_staedion_data].[dwh].dimRedenStornoEmpire rst
		on stn.[Code reden stornering] = rst.Id
		where (@IndicatorID = 1571 or @IndicatorID is null)

	set @AantalRecords = @@rowcount;

	drop table if exists #stn

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
