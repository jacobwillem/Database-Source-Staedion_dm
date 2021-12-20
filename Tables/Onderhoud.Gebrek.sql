CREATE TABLE [Onderhoud].[Gebrek]
(
[Gebrek_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Gebrek] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Externe omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Gebrek_02] ON [Onderhoud].[Gebrek] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Gebrek_01] ON [Onderhoud].[Gebrek] ([Gebrek_id]) ON [PRIMARY]
GO
