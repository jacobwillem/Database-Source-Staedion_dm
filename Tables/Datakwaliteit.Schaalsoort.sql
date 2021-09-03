CREATE TABLE [Datakwaliteit].[Schaalsoort]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Schaalsoort] ADD CONSTRAINT [PK__Schaalso__3213E83F7A5285DD] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
