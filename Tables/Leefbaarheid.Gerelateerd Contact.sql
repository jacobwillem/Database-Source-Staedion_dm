CREATE TABLE [Leefbaarheid].[Gerelateerd Contact]
(
[Gerelateerd contact_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Leefbaarheidsdossier_id] [int] NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Regelnr] [int] NULL,
[Contactnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Tonen op dossier] [varchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
