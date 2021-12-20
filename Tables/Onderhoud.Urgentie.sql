CREATE TABLE [Onderhoud].[Urgentie]
(
[Urgentie_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Urgentiecode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Periode] [varchar] (32) COLLATE Latin1_General_CI_AS NULL,
[Standaard] [char] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Urgentie_02] ON [Onderhoud].[Urgentie] ([Bedrijf_id], [Urgentiecode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Urgentie_01] ON [Onderhoud].[Urgentie] ([Urgentie_id]) ON [PRIMARY]
GO
