CREATE TABLE [Onderhoud].[Oorzaak]
(
[Oorzaak_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Oorzaak] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Externe omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Kostencode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Doorbelasten aan] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Standaard] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Oorzaak_02] ON [Onderhoud].[Oorzaak] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Oorzaak_01] ON [Onderhoud].[Oorzaak] ([Oorzaak_id]) ON [PRIMARY]
GO
