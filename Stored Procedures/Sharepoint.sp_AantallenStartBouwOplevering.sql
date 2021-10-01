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
----------------------------------------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Sharepoint].[sp_AantallenStartBouwOplevering] 
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

	IF @Peildatum IS NULL 
		SET @Peildatum = GETDATE()

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
