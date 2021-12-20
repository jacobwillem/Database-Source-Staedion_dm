CREATE TABLE [DatabaseBeheer].[LoggingUitvoeringDatabaseObjecten]
(
[Databaseobject] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Begintijd] [datetime] NULL,
[Eindtijd] [datetime] NULL,
[TijdMelding] [datetime] NULL,
[ErrorProcedure] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[ErrorLine] [int] NULL,
[ErrorNumber] [int] NULL,
[ErrorMessage] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Categorie] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Stap] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Variabelen] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
