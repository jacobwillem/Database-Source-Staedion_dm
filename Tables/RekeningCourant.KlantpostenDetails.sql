CREATE TABLE [RekeningCourant].[KlantpostenDetails]
(
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Bedrijf] [varchar] (29) COLLATE Latin1_General_CI_AS NOT NULL,
[Volgnummer] [int] NOT NULL,
[Boekdatum] [datetime] NOT NULL,
[Broncode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Bedrag] [numeric] (38, 20) NOT NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Document] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheid] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Document Type] [varchar] (24) COLLATE Latin1_General_CI_AS NOT NULL,
[Vervaldatum] [datetime] NOT NULL,
[Boekingssoort] [varchar] (11) COLLATE Latin1_General_CI_AS NOT NULL,
[Soort storno code] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Storno code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
