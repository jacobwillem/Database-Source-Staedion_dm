CREATE TABLE [Projecten].[ProjectType]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Projecttype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Menu] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectType] ADD CONSTRAINT [PK_ProjectType] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectType] ADD CONSTRAINT [FK_ProjectType_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
