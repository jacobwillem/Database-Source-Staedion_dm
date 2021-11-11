SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum date  = null)
-- grant exec on sharepoint.sp_AantallenStartBouwOplevering to public

/* ##############################################################################################################################
BETREFT: Is bedoeld om in een Power Automate Flow data van Microsoft List over te halen naar SQL server 
=> referentiedata haal je zo binnen om te kunnen gebruiken in opbouwen van kpi's bijvoorbeeld

20211001 JvdW aangemaakt
20211109 JvdW na overleg met Youness
				-- voor maandagavond 2de week van de maand: dan peildatum vorige maand
					select datename(weekday, getdate()), datepart(day, datediff(day, 0, getdate())/7 * 7)/7 + 1, format(getdate(),'ddd', 'nl-NL')
				-- na maandagavond 2de week van de maand: dan peildatum huidige maand

----------------------------------------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211109'
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211108'
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211101'
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] '20211130'

select * from staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten
----------------------------------------------------------------------------------------------------------------------------------
AANTEKENINGEN
----------------------------------------------------------------------------------------------------------------------------------
Opzet in Power Automate Flow
=> vorige data weg te schrijven in bak file
=> wissen huidige maand 
=> volledig vullen sharepoint list

Alternatief is alle wijzigingen loggen en wegschrijven maar volgens mij is het risico groter dat je uit de pas gaat lopen

############################################################################################################################## */


AS 

BEGIN
	DECLARE @Bericht NVARCHAR(50)

	-- oude code
	-- IF @Peildatum IS NULL 
	--	SET @Peildatum = GETDATE()
	Declare @Vandaag as date
	Declare @WeeknrBinnenHuidigeMaand as smallint
	Declare @HuidigeDag as nvarchar(10)

	Set @Vandaag = coalesce(@Peildatum,getdate())
	Set @WeeknrBinnenHuidigeMaand = datepart(day, datediff(day, 0, @Vandaag)/7 * 7)/7 + 1    -- https://stackoverflow.com/questions/13116222/how-to-get-week-number-of-the-month-from-the-date-in-sql-server-2008
	Set @HuidigeDag = format(@Vandaag,'ddd', 'nl-NL')
	
	If @WeeknrBinnenHuidigeMaand = 1 or (@WeeknrBinnenHuidigeMaand = 2 and @HuidigeDag in ( 'zo','ma'))
				set @Peildatum = eomonth(dateadd(m,-1,@Vandaag))
	If @WeeknrBinnenHuidigeMaand > 2 or (@WeeknrBinnenHuidigeMaand = 2 and @HuidigeDag not in ( 'zo','ma'))
			set @Peildatum = eomonth(@Vandaag)

	DROP TABLE IF EXISTS bak.AantallenStartBouwOplevering
	;

	SELECT * INTO bak.AantallenStartBouwOplevering
	FROM sharepoint.AantallenStartBouwOplevering
	;

	DELETE 
	FROM sharepoint.AantallenStartBouwOplevering
	WHERE YEAR(@Peildatum) = YEAR(Peildatum) 
	AND MONTH(@Peildatum) = MONTH(Peildatum) 

	-- loggen van deze stap
	SET @Bericht =  'Peildatum = ' + FORMAT(@Peildatum,'dd-MM-yyyy')
	EXEC staedion_dm.DatabaseBeheer.sp_LoggenUitvoeringDatabaseObjecten  null,'sp_LoggenUitvoeringDatabaseObjecten', @Bericht

END


GO
GRANT EXECUTE ON  [Sharepoint].[sp_AantallenStartBouwOplevering] TO [public]
GO
