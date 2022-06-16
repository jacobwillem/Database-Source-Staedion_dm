CREATE TABLE [DatabaseBeheer].[StatusJobsDiversen]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Categorie] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Toelichting] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Tijdsduur in minuten] [int] NULL,
[Meest recente tijdstip] [datetime] NULL,
[Laaddatum] [date] NULL
) ON [PRIMARY]
GO
