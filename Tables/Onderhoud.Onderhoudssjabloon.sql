CREATE TABLE [Onderhoud].[Onderhoudssjabloon]
(
[Onderhoudssjabloon_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Onderhoudssjabloon] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderhoudssjabloon_02] ON [Onderhoud].[Onderhoudssjabloon] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderhoudssjabloon_01] ON [Onderhoud].[Onderhoudssjabloon] ([Onderhoudssjabloon_id]) ON [PRIMARY]
GO
