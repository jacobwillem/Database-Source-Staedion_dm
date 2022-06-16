CREATE TABLE [Onderhoud].[Reparatiesjabloon]
(
[Reparatiesjabloon_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Is Reparatiesjabloon] [bit] NULL,
[Sjabloonsoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Reparatiesjabloon] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Externe omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Verkoopwijze] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Afspraak noodzakelijk] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Urgentie_id] [int] NULL,
[Inspectie sjabloon] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Inspectieduur] [bigint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Reparatiesjabloon_02] ON [Onderhoud].[Reparatiesjabloon] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Reparatiesjabloon_01] ON [Onderhoud].[Reparatiesjabloon] ([Reparatiesjabloon_id]) ON [PRIMARY]
GO
