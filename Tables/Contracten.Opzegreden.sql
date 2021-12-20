CREATE TABLE [Contracten].[Opzegreden]
(
[Opzegreden_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Opzegreden] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Opzegreden_02] ON [Contracten].[Opzegreden] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Opzegreden_01] ON [Contracten].[Opzegreden] ([Opzegreden_id]) ON [PRIMARY]
GO
