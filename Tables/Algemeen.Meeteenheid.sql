CREATE TABLE [Algemeen].[Meeteenheid]
(
[Meeteenheid_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Meeteenheid] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Meeteenheid_02] ON [Algemeen].[Meeteenheid] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Meeteenheid_01] ON [Algemeen].[Meeteenheid] ([Meeteenheid_id]) ON [PRIMARY]
GO
