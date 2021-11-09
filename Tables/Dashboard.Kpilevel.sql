CREATE TABLE [Dashboard].[Kpilevel]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Kpilevel] ADD CONSTRAINT [PK_Kpilevel] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
