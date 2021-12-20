CREATE TABLE [Onderhoud].[Overschrijdingsreden]
(
[Overschrijdingsreden_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Overschrijdingsreden] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Overschrijdingsreden_02] ON [Onderhoud].[Overschrijdingsreden] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Overschrijdingsreden_01] ON [Onderhoud].[Overschrijdingsreden] ([Overschrijdingsreden_id]) ON [PRIMARY]
GO
