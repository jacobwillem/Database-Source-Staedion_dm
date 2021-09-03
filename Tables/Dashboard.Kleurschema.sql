CREATE TABLE [Dashboard].[Kleurschema]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Kleur_1] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Kleur_2] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Kleur_3] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Kleur_4] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Kleur_5] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Kleurschema] ADD CONSTRAINT [PK__Kleursch__3213E83FBBD7D3F0] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
