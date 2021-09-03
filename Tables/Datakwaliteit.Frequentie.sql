CREATE TABLE [Datakwaliteit].[Frequentie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Frequentie] ADD CONSTRAINT [PK__Frequent__3213E83FDF0BC983] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
