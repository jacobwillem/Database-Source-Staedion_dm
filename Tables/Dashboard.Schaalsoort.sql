CREATE TABLE [Dashboard].[Schaalsoort]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Schaalsoort] ADD CONSTRAINT [PK__Schaalso__3213E83FD61216B4] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
