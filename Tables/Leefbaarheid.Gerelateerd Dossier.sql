CREATE TABLE [Leefbaarheid].[Gerelateerd Dossier]
(
[Gerelateerd dossier_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Leefbaarheidsdossier_id] [int] NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Gerelateerd  leefbaarheidsdossier_id] [int] NULL,
[Gerelateerd dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
