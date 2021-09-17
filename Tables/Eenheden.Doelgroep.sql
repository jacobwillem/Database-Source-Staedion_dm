CREATE TABLE [Eenheden].[Doelgroep]
(
[Doelgroep_id] [int] NOT NULL IDENTITY(1, 1),
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Streefhuursegmentatie] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Streefhuursegmentatie sortering] [smallint] NULL
) ON [PRIMARY]
GO
