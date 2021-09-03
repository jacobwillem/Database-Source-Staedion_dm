CREATE TABLE [Grootboek].[Bronnen]
(
[Bron_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Bron] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bronnen_02] ON [Grootboek].[Bronnen] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bronnen_01] ON [Grootboek].[Bronnen] ([Bron_id]) ON [PRIMARY]
GO
