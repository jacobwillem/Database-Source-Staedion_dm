CREATE TABLE [Dashboard].[Margetype]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Margetype] ADD CONSTRAINT [PK__Margetyp__3213E83F162400DE] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
