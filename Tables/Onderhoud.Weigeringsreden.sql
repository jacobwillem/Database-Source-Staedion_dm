CREATE TABLE [Onderhoud].[Weigeringsreden]
(
[Weigeringsreden_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Weigeringsreden] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Weigeringsreden_02] ON [Onderhoud].[Weigeringsreden] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Weigeringsreden_01] ON [Onderhoud].[Weigeringsreden] ([Weigeringsreden_id]) ON [PRIMARY]
GO
