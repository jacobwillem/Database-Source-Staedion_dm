CREATE TABLE [Datakwaliteit].[Berekeningswijze]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Berekeningswijze] ADD CONSTRAINT [PK__Berekeni__3213E83FCD11F33F] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
