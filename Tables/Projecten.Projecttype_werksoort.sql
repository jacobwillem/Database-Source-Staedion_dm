CREATE TABLE [Projecten].[Projecttype_werksoort]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[projecttype_id] [int] NULL,
[werksoort_id] [int] NULL,
[werksoortboekingsgroep] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Projecttype_werksoort] ADD CONSTRAINT [PK_Projecttype_werksoort] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Projecttype_werksoort] ADD CONSTRAINT [FK_Projecttype_werksoort_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
ALTER TABLE [Projecten].[Projecttype_werksoort] ADD CONSTRAINT [FK_Projecttype_werksoort_ProjectType] FOREIGN KEY ([projecttype_id]) REFERENCES [Projecten].[ProjectType] ([id])
GO
ALTER TABLE [Projecten].[Projecttype_werksoort] ADD CONSTRAINT [FK_Projecttype_werksoort_Werksoort] FOREIGN KEY ([werksoort_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
