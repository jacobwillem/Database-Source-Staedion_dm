CREATE TABLE [Rapport].[Memoriaal_Jur_Eig]
(
[Boekdatum] [date] NULL,
[Documentnr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Rekeningsoort] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Reken__276FAA0A] DEFAULT ('Grootboekrekening'),
[Rekeningnr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Kostencode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Koste__2863CE43] DEFAULT (''),
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Omsch__2957F27C] DEFAULT ('Afrekening'),
[Bedrag] [decimal] (12, 2) NULL,
[Kostenplaats code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Koste__2A4C16B5] DEFAULT (''),
[Clusternr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Clust__2B403AEE] DEFAULT (''),
[Eenheidnr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
