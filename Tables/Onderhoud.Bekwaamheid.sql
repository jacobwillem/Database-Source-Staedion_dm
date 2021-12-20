CREATE TABLE [Onderhoud].[Bekwaamheid]
(
[Bekwaamheid_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bekwaamheid] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bekwaamheid_02] ON [Onderhoud].[Bekwaamheid] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bekwaamheid_01] ON [Onderhoud].[Bekwaamheid] ([Bekwaamheid_id]) ON [PRIMARY]
GO
