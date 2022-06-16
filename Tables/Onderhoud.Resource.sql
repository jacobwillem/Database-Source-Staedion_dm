CREATE TABLE [Onderhoud].[Resource]
(
[Resource_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Naam] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Adres] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Plaats] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Functie] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Datum in dienst] [date] NULL,
[Soort resource] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Resource groep_id] [int] NULL,
[Meeteenheid] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Directe kostprijs] [decimal] (12, 2) NULL,
[Percentage indirecte kosten] [decimal] (6, 2) NULL,
[Kostprijs] [decimal] (12, 2) NULL,
[Winst percentage] [decimal] (6, 2) NULL,
[Prijs/winst berekeningswijze] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Eenheidsprijs] [decimal] (12, 2) NULL,
[Leveranciernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Geblokkeerd] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Productboekingsgroep] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Btw productboekingsgroep] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Resource_02] ON [Onderhoud].[Resource] ([Bedrijf_id], [No_]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Resource_01] ON [Onderhoud].[Resource] ([Resource_id]) ON [PRIMARY]
GO
