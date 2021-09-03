CREATE TABLE [Grootboek].[Bedrijfsboekingsgroep]
(
[Bedrijfsboekingsgroep_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Bedrijfsboekingsgroep] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bedrijfsboekingsgroep_02] ON [Grootboek].[Bedrijfsboekingsgroep] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bedrijfsboekingsgroep_01] ON [Grootboek].[Bedrijfsboekingsgroep] ([Bedrijfsboekingsgroep_id]) ON [PRIMARY]
GO
