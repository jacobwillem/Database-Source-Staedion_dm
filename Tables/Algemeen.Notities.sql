CREATE TABLE [Algemeen].[Notities]
(
[Link Id] [int] NULL,
[Timestamp] [binary] (8) NULL,
[Bedrijf_id] [int] NULL,
[NavisionId] [int] NULL,
[Key01] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Key02] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Key03] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Key04] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Key05] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Aangemaakt] [datetime] NULL,
[Gebruiker] [nvarchar] (132) COLLATE Latin1_General_CI_AS NULL,
[Aan gebruiker] [nvarchar] (132) COLLATE Latin1_General_CI_AS NULL,
[Notitie] [nvarchar] (4000) COLLATE Latin1_General_CI_AS NULL,
[Verwijderd] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [Notities_pk] ON [Algemeen].[Notities] ([Link Id]) ON [PRIMARY]
GO
