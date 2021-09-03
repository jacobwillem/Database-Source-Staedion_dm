CREATE TABLE [Dashboard].[Gemiddelde]
(
[id] [int] NOT NULL IDENTITY(0, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Gemiddelde] ADD CONSTRAINT [PK_Gemiddelde] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Gemiddelde] ON [Dashboard].[Gemiddelde] ([id]) ON [PRIMARY]
GO
