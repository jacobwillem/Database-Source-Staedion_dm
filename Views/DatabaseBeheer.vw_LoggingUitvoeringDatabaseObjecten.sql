SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [DatabaseBeheer].[vw_LoggingUitvoeringDatabaseObjecten] AS 
SELECT Tijdsduur = DATEDIFF(MINUTE, INFO.Begintijd, INFO.Eindtijd),
       INFO.[Databaseobject],
       INFO.[Begintijd],
       INFO.[Eindtijd],
       INFO.[TijdMelding],
       INFO.[ErrorProcedure],
       INFO.[ErrorLine],
       INFO.[ErrorNumber],
       INFO.[ErrorMessage],
       INFO.[Categorie],
       INFO.[Stap],
       INFO.[Variabelen],
	   -- Workaround om laaddatum te bepalen, moet charmanter kunnen
       CASE
                   WHEN DATEPART(HOUR, INFO.Begintijd) IN ( 17, 18, 19, 20, 21, 22, 23 ) THEN
                       CAST(INFO.Begintijd AS DATE)
                   ELSE
                       CAST(DATEADD(DAY, -1, INFO.Begintijd) AS DATE)
       END AS Laaddatum,
	   CASE WHEN INFO.[ErrorMessage] IS NOT NULL THEN 1 ELSE 0 END AS [Teller foutmelding]
	   -- select *
FROM staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten AS INFO
WHERE INFO.Begintijd > '20211223' -- begonnen met uitgebreid loggen in deze tabel
      AND
      (
          INFO.ErrorProcedure IS NOT NULL
          OR INFO.Eindtijd IS NOT NULL
		  OR INFO.Categorie = 'Power Automate'
      )
GO
