CREATE TABLE [Eenheden].[Collectieve objecten]
(
[Collectief object_id] [int] NOT NULL IDENTITY(1, 1),
[Technisch type_id] [int] NULL,
[Corpodatatype_id] [int] NULL,
[Ingangsdatum] [date] NULL,
[Einddatum] [date] NULL,
[Bedrijf_id] [int] NULL,
[Collectief object] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Verwijderd] [bit] NULL,
[Omschrijving] [nvarchar] (70) COLLATE Latin1_General_CI_AS NULL,
[Straatnaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Huisnummer] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Huisnummer toevoeging] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Postcode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Plaats] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Gemeente] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Wijk] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Buurt] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Betreft] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[FT clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[FT clusternaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Financieel clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Financieel clusternaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Bouwbloknr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bouwbloknaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Vve clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[VvE clusternaam] [nvarchar] (110) COLLATE Latin1_General_CI_AS NULL,
[Collectief object clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Collectief object clusternaam] [nvarchar] (110) COLLATE Latin1_General_CI_AS NULL,
[Beheerder] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Juridisch eigenaar] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Adres] AS (replace(((([Straatnaam]+' ')+[Huisnummer])+' ')+[Huisnummer toevoeging],'  ',' ')),
[Eenheid + adres] AS (replace(((((([Collectief object]+' ')+[Straatnaam])+' ')+[Huisnummer])+' ')+[Huisnummer toevoeging],'  ',' '))
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [cidx_Collectieve_Objecten_Collectief_object_id_bedrijf_id] ON [Eenheden].[Collectieve objecten] ([Bedrijf_id], [Collectief object_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Collectieve_Objecten_Collectief_object_id_einddatum] ON [Eenheden].[Collectieve objecten] ([Bedrijf_id], [Collectief object_id]) INCLUDE ([Einddatum]) ON [PRIMARY]
GO
