CREATE TABLE [Dashboard].[Proces]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[Link] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Proces] ADD CONSTRAINT [PK_Proces] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
