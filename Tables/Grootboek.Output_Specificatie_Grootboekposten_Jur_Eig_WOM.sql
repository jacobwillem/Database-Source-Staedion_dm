CREATE TABLE [Grootboek].[Output_Specificatie_Grootboekposten_Jur_Eig_WOM]
(
[Rekeningnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Rekeningnaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Bedrag] [float] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Documentnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Boekdatum] [datetime] NULL,
[Kostenplaats] [nvarchar] (71) COLLATE Latin1_General_CI_AS NULL,
[Volgnummer] [int] NULL,
[Productboekingsgroep ] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Broncode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[BTW-poductboekingsgroep] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[BTW-bedrag] [float] NULL,
[Corpodata type] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Cluster] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Administratief eigenaar] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Juridisch eigenaar] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Gebruikers-id] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Bron] [varchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Periode] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Toegerekende post] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Toegerekende post bedrag] [decimal] (12, 2) NULL,
[Toegerekende post ok] [bit] NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Classificatie] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
