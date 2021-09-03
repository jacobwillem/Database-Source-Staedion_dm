CREATE TABLE [Dashboard].[Subsysteem]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Subsysteem] ADD CONSTRAINT [PK__Subsyste__3213E83F77FA30AB] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
