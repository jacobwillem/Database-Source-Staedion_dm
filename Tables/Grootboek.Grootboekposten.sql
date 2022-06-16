CREATE TABLE [Grootboek].[Grootboekposten]
(
[Grootboekpost_id] [int] NOT NULL IDENTITY(1, 1),
[Timestamp] [binary] (8) NULL,
[Bedrijf_id] [int] NULL,
[Volgnummer] [int] NULL,
[Rekening_id] [int] NULL,
[Boekdatum] [datetime] NULL,
[Documentsoort_id] [int] NULL,
[Document nr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Dimensiewaarde 1_id] [int] NULL,
[Dimensiewaarde 2_id] [int] NULL,
[Btwsoort_id] [int] NULL,
[Bedrijfsboekingsgroep_id] [int] NULL,
[Productboekingsgroep_id] [int] NULL,
[Btwproductboekingsgroep_id] [int] NULL,
[Tegenrekeningsoort_id] [int] NULL,
[Tegenrekening Grootboek] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Tegenrekening Klant] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Tegenrekening Leverancier] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Tegenrekening Bankrekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Tegenrekening Vast activum] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bedrag incl. verplichting] [decimal] (12, 2) NULL,
[Bedrag excl. verplichting] [decimal] (12, 2) NULL,
[Bedrag verplichting] [decimal] (12, 2) NULL,
[Debet incl. verplichting] [decimal] (12, 2) NULL,
[Debet excl. verplichting] [decimal] (12, 2) NULL,
[Credit incl. verplichting] [decimal] (12, 2) NULL,
[Credit excl. verplichting] [decimal] (12, 2) NULL,
[Btw bedrag incl. verplichting] [decimal] (12, 2) NULL,
[Btw bedrag excl. verplichting] [decimal] (12, 2) NULL,
[Afgesloten door] [int] NULL,
[Open] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Gebruiker] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Registerpost] [int] NULL,
[Datum aanmaak] [date] NULL,
[Datum gewijzigd] [date] NULL,
[Gewijzigd] [bit] NULL,
[Bron_id] [int] NULL,
[Systeemgegenereerd] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Dagboek batch] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Reden_id] [int] NULL,
[Transactienr] [int] NULL,
[Extern documentnr] [nvarchar] (35) COLLATE Latin1_General_CI_AS NULL,
[Bronsoort_id] [int] NULL,
[Bron Klant] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bron Leverancier] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bron Bankrekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bron Vast activum] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Cluster] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Verplichting] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Dimensieset_id] [int] NULL,
[Empire projectnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Empire Projecttype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Empire Werksoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Gecorrigeerde post] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Referentie onderhoud] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Grootboekposten_bedrijf_boekdatum_document] ON [Grootboek].[Grootboekposten] ([Bedrijf_id], [Boekdatum], [Document nr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Grootboekposten_bedrijf_boekdatum_rekening_id] ON [Grootboek].[Grootboekposten] ([Bedrijf_id], [Boekdatum], [Rekening_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Grootboekposten_bedrijf_rekening_id_boekdatum] ON [Grootboek].[Grootboekposten] ([Bedrijf_id], [Rekening_id], [Boekdatum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Grootboek_01] ON [Grootboek].[Grootboekposten] ([Bedrijf_id], [Volgnummer]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [jvdw_Grootboekposten_Rekening] ON [Grootboek].[Grootboekposten] ([Rekening_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [jvdw_Grootboekposten_Rekening_extra] ON [Grootboek].[Grootboekposten] ([Rekening_id]) INCLUDE ([Bedrijf_id], [Volgnummer], [Boekdatum], [Document nr], [Omschrijving], [Productboekingsgroep_id], [Tegenrekening Leverancier], [Bedrag incl. verplichting], [Gebruiker], [Bron_id], [Bron Klant], [Eenheidnr]) ON [PRIMARY]
GO
