CREATE TABLE [Grootboek].[Dimensiewaarden1]
(
[Dimensiewaarde 1_id] [int] NOT NULL IDENTITY(0, 1),
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
CREATE NONCLUSTERED INDEX [Dimensiewaarden1_01] ON [Grootboek].[Dimensiewaarden1] ([Dimensiewaarde 1_id]) ON [PRIMARY]
GO
