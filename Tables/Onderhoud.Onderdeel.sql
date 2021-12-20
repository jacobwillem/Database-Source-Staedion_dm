CREATE TABLE [Onderhoud].[Onderdeel]
(
[Onderdeel_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Onderdeel] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Externe omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderdeel_02] ON [Onderhoud].[Onderdeel] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderdeel_01] ON [Onderhoud].[Onderdeel] ([Onderdeel_id]) ON [PRIMARY]
GO
