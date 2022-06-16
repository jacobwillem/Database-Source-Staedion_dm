CREATE TABLE [Leefbaarheid].[Dossier Melder]
(
[Dossier Melder_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Leefbaarheidsdossier_id] [int] NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Regelnr] [int] NULL,
[Meldernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Melddatum] [date] NULL,
[Contactpersoon] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Prioriteit] [int] NULL,
[Communicatiewijze] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Tonen op dossier] [varchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Dossier Melder_Bedrijf_idDossiernrRegelnr] ON [Leefbaarheid].[Dossier Melder] ([Bedrijf_id], [Dossiernr], [Regelnr]) ON [PRIMARY]
GO
