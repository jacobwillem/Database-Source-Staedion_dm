CREATE TABLE [Onderhoud].[Kostencode]
(
[Kostencode_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Cost Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Kostencode] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Kostencodesoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Productboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[BTW-productboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Opslag S&V] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Doorbelasten leegstand] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Dagelijks onderhoud] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Cluster verdeelsleutelsoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Kostencode_02] ON [Onderhoud].[Kostencode] ([Bedrijf_id], [Cost Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Kostencode_01] ON [Onderhoud].[Kostencode] ([Kostencode_id]) ON [PRIMARY]
GO
