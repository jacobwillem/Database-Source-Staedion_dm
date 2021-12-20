CREATE TABLE [Onderhoud].[Afrondcode]
(
[Afrondcode_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Afrondcode] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Afrondcode_01] ON [Onderhoud].[Afrondcode] ([Afrondcode_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Afrondcode_02] ON [Onderhoud].[Afrondcode] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
