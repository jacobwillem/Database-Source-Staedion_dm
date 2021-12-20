CREATE TABLE [Onderhoud].[Onderhoudssoort]
(
[Onderhoudssoort_id] [int] NULL,
[Onderhoudssoort] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderhoudssoort_01] ON [Onderhoud].[Onderhoudssoort] ([Onderhoudssoort_id]) ON [PRIMARY]
GO
