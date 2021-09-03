CREATE TABLE [Projecten].[ProjectCombinaties]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Projecttype_id] [int] NULL,
[Jaar] [int] NULL,
[werksoort_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectCombinaties] ADD CONSTRAINT [PK_ProjectCombinaties] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectCombinaties] ADD CONSTRAINT [FK_ProjectCombinaties_ProjectType] FOREIGN KEY ([Projecttype_id]) REFERENCES [Projecten].[ProjectType] ([id])
GO
ALTER TABLE [Projecten].[ProjectCombinaties] ADD CONSTRAINT [FK_ProjectCombinaties_Werksoort] FOREIGN KEY ([werksoort_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
