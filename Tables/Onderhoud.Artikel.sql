CREATE TABLE [Onderhoud].[Artikel]
(
[Artikel_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving 2] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Basis meeteenheid] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Schapnummer] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Eenheidsprijs] [decimal] (12, 2) NULL,
[Waarderingsmethode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Kostprijs] [decimal] (12, 2) NULL,
[Vaste verrekenprijs] [decimal] (12, 2) NULL,
[Laatste inkoopprijs] [decimal] (12, 2) NULL,
[Prijs is aangepast] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Leveranciernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Artikelnr bij leverancier] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bestelpunt] [decimal] (12, 2) NULL,
[Maximale voorraad] [decimal] (12, 2) NULL,
[Bestel aantal] [decimal] (12, 2) NULL,
[Geblokkeerd] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Productboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Btw productboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Reserveren] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Maximale bestelhoeveelheid] [decimal] (12, 2) NULL,
[Veiligheidsvoorraad] [decimal] (12, 2) NULL,
[Vaste bestelgrootte] [decimal] (12, 2) NULL,
[Verkoop meeteenheid] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Inkoop meeteenheid] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Bestelbeleid] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[In inventaris] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Artikel categorie] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Productgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Kritiek] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Artikel_01] ON [Onderhoud].[Artikel] ([Artikel_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Artikel_02] ON [Onderhoud].[Artikel] ([Bedrijf_id], [No_]) ON [PRIMARY]
GO
