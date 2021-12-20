CREATE TABLE [Onderhoud].[Onderhoudsverzoekstatus]
(
[Onderhoudsverzoekstatus_id] [int] NULL,
[Onderhoudsverzoekstatus] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderhoudsverzoekstatus_01] ON [Onderhoud].[Onderhoudsverzoekstatus] ([Onderhoudsverzoekstatus_id]) ON [PRIMARY]
GO
