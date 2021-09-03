CREATE TABLE [Grootboek].[Productboekingsgroep]
(
[Productboekingsgroep_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Productboekingsgroep] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Productboekingsgroep_02] ON [Grootboek].[Productboekingsgroep] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Productboekingsgroep_01] ON [Grootboek].[Productboekingsgroep] ([Productboekingsgroep_id]) ON [PRIMARY]
GO
