CREATE TABLE [Dashboard].[Indicatorgroep]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Indicatorgroep] ADD CONSTRAINT [PK__Indicato__3213E83FB9855838] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
