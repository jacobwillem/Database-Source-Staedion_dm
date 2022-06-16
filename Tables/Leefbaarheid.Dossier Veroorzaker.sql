CREATE TABLE [Leefbaarheid].[Dossier Veroorzaker]
(
[Dossier Veroorzaker_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Leefbaarheidsdossier_id] [int] NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Veroorzakernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Contactpersoon] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Tonen op dossier] [varchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Dossier Veroorzaker_Bedrijf_idVeroorzaker] ON [Leefbaarheid].[Dossier Veroorzaker] ([Bedrijf_id], [Dossiernr], [Veroorzakernr]) ON [PRIMARY]
GO
