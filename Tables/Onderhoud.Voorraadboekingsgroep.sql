CREATE TABLE [Onderhoud].[Voorraadboekingsgroep]
(
[Voorraadboekingsgroep_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Voorraadboekingsgroep] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Voorraadboekingsgroep_02] ON [Onderhoud].[Voorraadboekingsgroep] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Voorraadboekingsgroep_01] ON [Onderhoud].[Voorraadboekingsgroep] ([Voorraadboekingsgroep_id]) ON [PRIMARY]
GO
