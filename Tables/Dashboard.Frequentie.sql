CREATE TABLE [Dashboard].[Frequentie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Frequentie] ADD CONSTRAINT [PK__Ververs__3213E83F1ACC5108] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
