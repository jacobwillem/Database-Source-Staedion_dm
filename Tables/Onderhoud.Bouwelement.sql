CREATE TABLE [Onderhoud].[Bouwelement]
(
[Bouwelement_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bouwelement] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Externe omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bouwelement_02] ON [Onderhoud].[Bouwelement] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Bouwelement_01] ON [Onderhoud].[Bouwelement] ([Bouwelement_id]) ON [PRIMARY]
GO
