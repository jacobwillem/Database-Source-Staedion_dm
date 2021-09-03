CREATE TABLE [Datakwaliteit].[Veldtype]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Veldtype] ADD CONSTRAINT [PK__Veldtype__3213E83F0F13100A] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
