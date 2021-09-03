CREATE TABLE [Projecten].[ProjectFase]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Projectfase] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Offerte] [tinyint] NULL,
[Order] [tinyint] NULL,
[Uren] [tinyint] NULL,
[Materiaal] [tinyint] NULL,
[Afgesloten] [tinyint] NULL,
[Vervallen] [tinyint] NULL,
[Subsidie] [tinyint] NULL,
[Werksoort_Renteverlies_id] [int] NULL,
[Tegenrekening renteverlies] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Active] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectFase] ADD CONSTRAINT [PK_ProjectFase] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectFase] ADD CONSTRAINT [FK_ProjectFase_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
ALTER TABLE [Projecten].[ProjectFase] ADD CONSTRAINT [FK_ProjectFase_Werksoort] FOREIGN KEY ([Werksoort_Renteverlies_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
