CREATE TABLE [Leefbaarheid].[Agressiesoort]
(
[Agressiesoort_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Agressiesoort] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
