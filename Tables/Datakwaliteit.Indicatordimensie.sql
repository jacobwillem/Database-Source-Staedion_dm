CREATE TABLE [Datakwaliteit].[Indicatordimensie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Vertaling] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Indicatordimensie] ADD CONSTRAINT [PK__Indicato__3213E83FF00D2954] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
