CREATE TABLE [Projecten].[Werksoort]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Werksoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Werksoort] ADD CONSTRAINT [PK_Werksoort] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Werksoort] ADD CONSTRAINT [FK_Werksoort_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
