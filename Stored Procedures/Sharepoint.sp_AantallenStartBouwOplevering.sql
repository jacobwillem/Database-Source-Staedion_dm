SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum DATE  = null)
/* ##############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
BRON: Microsoft list (https://staedionict.sharepoint.com/sites/onderhoud-vastgoed/afdelingprojecten/Lists/Aantallen Start Bouw%20 Oplevering)
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv eerdere functie het kpi-framework 
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Sharepoint'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_AantallenStartBouwOplevering';
GO
----------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------------------------
20211001 JvdW aangemaakt
20211109 JvdW na overleg met Youness
				-- voor maandagavond 2de week van de maand: dan peildatum vorige maand
					select datename(weekday, getdate()), datepart(day, datediff(day, 0, getdate())/7 * 7)/7 + 1, format(getdate(),'ddd', 'nl-NL')
				-- na maandagavond 2de week van de maand: dan peildatum huidige maand
20220207 JvdW
-- Voorgaande werkt toch niet goed
select datename(weekday, '20220205'), datepart(day, datediff(day, 0, '20220205')/7 * 7)/7 + 1, format('20220205','ddd', 'nl-NL')
select datename(weekday, '20220205'), datepart(day, datediff(day, '20220201', '20220205')/7 * 7)/7 + 1, format(cast('20220205' as date),'ddd', 'nl-NL')
select datename(weekday, '20220206'), datepart(day, datediff(day, '20220201', '20220206')/7 * 7)/7 + 1, format(cast('20220206' as date),'ddd', 'nl-NL')
select datename(weekday, '20220207'), datepart(day, datediff(day, '20220201', '20220206')/7 * 7)/7 + 1, format(cast('20220207' as date),'ddd', 'nl-NL')
select datename(weekday, '20220208'), datepart(day, datediff(day, '20220201', '20220208')/7 * 7)/7 + 1, format(cast('20220208' as date),'ddd', 'nl-NL')

----------------------------------------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------------------------------------
grant exec on sharepoint.sp_AantallenStartBouwOplevering to public

exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211109'
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211108'
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211101'
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211130'

select * from staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten order by 2 desc
----------------------------------------------------------------------------------------------------------------------------------
AANTEKENINGEN
----------------------------------------------------------------------------------------------------------------------------------
Opzet in Power Automate Flow
=> vorige data weg te schrijven in bak file
=> wissen huidige maand 
=> volledig vullen sharepoint list


############################################################################################################################## */


AS 

BEGIN
	SET NOCOUNT ON

	DECLARE @Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID),		
				@Variabelen NVARCHAR(255) ,						
				@Categorie AS NVARCHAR(255) = 'Power Automate',	
				@AantalRecords DECIMAL(12, 0),														-- om in uitvoerscherm te kunnen zien hoeveel regels er gewist/toegevoegd zijn
				@Bericht NVARCHAR(255),																-- om tussenstappen te loggen
				@start AS DATETIME,																	-- om duur procedure te kunnen loggen
				@finish AS DATETIME,																	-- om duur procedure te kunnen loggen
				@LoggingWegschrijvenOfNiet AS BIT = 1,
				@Onderwerp AS NVARCHAR(200),
				@BerichtInclVariabelen AS NVARCHAR(200)

	SET	@start = CURRENT_TIMESTAMP;

	-- oude code
	-- IF @Peildatum IS NULL 
	--	SET @Peildatum = GETDATE()
	Declare @Vandaag as date
	Declare @WeeknrBinnenHuidigeMaand as smallint
	Declare @HuidigeDag as nvarchar(10)


	Set @Vandaag = coalesce(@Peildatum,GETDATE())
	--Set @WeeknrBinnenHuidigeMaand = datepart(day, datediff(day, 0, @Vandaag)/7 * 7)/7 + 1    -- https://stackoverflow.com/questions/13116222/how-to-get-week-number-of-the-month-from-the-date-in-sql-server-2008
	Set @WeeknrBinnenHuidigeMaand = datepart(day, datediff(day, DATEFROMPARTS(YEAR(@Vandaag),MONTH(@Vandaag),1), @Vandaag)/7 * 7)/7 + 1    -- https://stackoverflow.com/questions/13116222/how-to-get-week-number-of-the-month-from-the-date-in-sql-server-2008
	Set @HuidigeDag = format(@Vandaag,'ddd', 'nl-NL')
	
	If @WeeknrBinnenHuidigeMaand = 1 or (@WeeknrBinnenHuidigeMaand = 2 and @HuidigeDag in ( 'zo','ma'))
				set @Peildatum = eomonth(dateadd(m,-1,@Vandaag))
	If @WeeknrBinnenHuidigeMaand > 2 or (@WeeknrBinnenHuidigeMaand = 2 and @HuidigeDag not in ( 'zo','ma'))
				SET @Peildatum = eomonth(@Vandaag)

	DROP TABLE IF EXISTS bak.AantallenStartBouwOplevering
	;
-----------------------------------------------------------------------------------
SET @onderwerp = 'Vullen bak.AantallenStartBouwOplevering';
----------------------------------------------------------------------------------- 
	SELECT * INTO bak.AantallenStartBouwOplevering
	FROM sharepoint.AantallenStartBouwOplevering
	;
		SET @AantalRecords = @@rowcount;
		SET @Variabelen =  CONCAT('@WeeknrBinnenHuidigeMaand:', @WeeknrBinnenHuidigeMaand,' - @HuidigeDag:', @HuidigeDag, ' - @Peildatum:',@Peildatum);
		SET @Bericht = CONCAT('Stap: ', @Onderwerp, ' - records: ',format(@AantalRecords, 'N0'))
		SET @BerichtInclVariabelen = @Bericht + ' ' + @Variabelen
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@Variabelen = @Variabelen
					,@DatabaseObject = @Bron
					,@Bericht = @BerichtInclVariabelen
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

-----------------------------------------------------------------------------------
SET @onderwerp = 'Wissen maand sharepoint.AantallenStartBouwOplevering';
----------------------------------------------------------------------------------- 

	DELETE 
	FROM sharepoint.AantallenStartBouwOplevering
	WHERE YEAR(@Peildatum) = YEAR(Peildatum) 
	AND MONTH(@Peildatum) = MONTH(Peildatum) 

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@Variabelen = @Variabelen
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet


	SELECT @Peildatum AS Peildatum

	-- loggen van deze stap
	SET @Variabelen =  'Peildatum = ' + FORMAT(@Peildatum,'dd-MM-yyyy')
	SET	@finish = CURRENT_TIMESTAMP;
	EXEC staedion_dm.DatabaseBeheer.sp_loggen_uitvoering_database_objecten  null,'sp_LoggenUitvoeringDatabaseObjecten', @Bericht
			EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@Variabelen = @Variabelen
					,@DatabaseObject = @Bron
					,@Begintijd = @start
					,@Eindtijd = @finish
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

END


GO
EXEC sp_addextendedproperty N'MS_Description', N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
BRON: Microsoft list (https://staedionict.sharepoint.com/sites/onderhoud-vastgoed/afdelingprojecten/Lists/Aantallen Start Bouw%20 Oplevering)
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv eerdere functie het kpi-framework 
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen', 'SCHEMA', N'Sharepoint', 'PROCEDURE', N'sp_AantallenStartBouwOplevering', NULL, NULL
GO
GRANT EXECUTE ON  [Sharepoint].[sp_AantallenStartBouwOplevering] TO [public]
GO
