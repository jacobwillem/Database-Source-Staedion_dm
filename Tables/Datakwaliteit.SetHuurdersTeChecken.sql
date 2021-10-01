CREATE TABLE [Datakwaliteit].[SetHuurdersTeChecken]
(
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Peildatum] [date] NULL,
[Huishoudnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Actief huurcontract] [int] NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
