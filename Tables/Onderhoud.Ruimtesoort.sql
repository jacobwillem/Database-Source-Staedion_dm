CREATE TABLE [Onderhoud].[Ruimtesoort]
(
[Ruimtesoort_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Ruimtesoort] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Externe omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Ruimtesoort_02] ON [Onderhoud].[Ruimtesoort] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Ruimtesoort_01] ON [Onderhoud].[Ruimtesoort] ([Ruimtesoort_id]) ON [PRIMARY]
GO
