CREATE TABLE [Grootboek].[Btwproductboekingsgroep]
(
[Btwproductboekingsgroep_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Btwproductboekingsgroep] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Integratieheffing] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Btwproductboekingsgroep doorbelasten] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Btwproductboekingsgroep_02] ON [Grootboek].[Btwproductboekingsgroep] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Btwproductboekingsgroep_01] ON [Grootboek].[Btwproductboekingsgroep] ([Btwproductboekingsgroep_id]) ON [PRIMARY]
GO
