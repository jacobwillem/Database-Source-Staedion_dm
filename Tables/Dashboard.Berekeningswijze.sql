CREATE TABLE [Dashboard].[Berekeningswijze]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Berekeningswijze] ADD CONSTRAINT [PK__Berekeni__3213E83FD23AED33] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
