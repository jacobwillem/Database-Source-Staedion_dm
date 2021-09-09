CREATE TABLE [Grootboek].[Toegerekende grootboekposten]
(
[Regeltype] [varchar] (13) COLLATE Latin1_General_CI_AS NOT NULL,
[Toegerekend bedrag] [float] NULL,
[Bedrag] [float] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Rekeningnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Volgnummer grootboekpost] [int] NOT NULL,
[Boekdatum] [datetime] NOT NULL,
[Kostencode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Datum toerekening] [datetime] NOT NULL,
[Toegerekend] [tinyint] NOT NULL,
[Document Nr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Toegerekende postnr] [int] NOT NULL,
[Bedrijf_id] [int] NULL,
[Rekening_id] [int] NULL
) ON [PRIMARY]
GO
