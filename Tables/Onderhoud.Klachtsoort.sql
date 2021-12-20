CREATE TABLE [Onderhoud].[Klachtsoort]
(
[Klachtsoort_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klachtsoort] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Improductiviteit] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Agressie] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Technisch] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Service] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Verzekering] [char] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Klachtsoort_02] ON [Onderhoud].[Klachtsoort] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Klachtsoort_01] ON [Onderhoud].[Klachtsoort] ([Klachtsoort_id]) ON [PRIMARY]
GO
