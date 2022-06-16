CREATE TABLE [Leefbaarheid].[Dossiersoort]
(
[Dossiersoort_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Dossiersoort] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Agressie] [varchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
