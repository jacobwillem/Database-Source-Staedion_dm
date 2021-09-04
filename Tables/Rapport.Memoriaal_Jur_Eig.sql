CREATE TABLE [Rapport].[Memoriaal_Jur_Eig]
(
[Boekdatum] [date] NULL,
[Documentnr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_Memoriaal_Jur_Eig_Documentnr.] DEFAULT ('1'),
[Rekeningsoort] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Reken__5DCBBABB] DEFAULT ('Grootboekrekening'),
[Rekeningnr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Kostencode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Koste__5EBFDEF4] DEFAULT (''),
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Omsch__5FB4032D] DEFAULT ('Afrekening'),
[Bedrag] [decimal] (12, 2) NULL,
[Kostenplaats code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Koste__60A82766] DEFAULT (''),
[Clusternr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF__Memoriaal__Clust__619C4B9F] DEFAULT (''),
[Eenheidnr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
