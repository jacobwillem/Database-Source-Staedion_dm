CREATE TABLE [Grootboek].[Dimensiewaarden2]
(
[Dimensiewaarde 2_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Dimensie Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Dimensiewaarde] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Geblokkeerd] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Consolidatie Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Globale Dimensie nr] [int] NULL,
[Dimension Value ID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Dimensiewaarden2_01] ON [Grootboek].[Dimensiewaarden2] ([Dimensiewaarde 2_id]) ON [PRIMARY]
GO
