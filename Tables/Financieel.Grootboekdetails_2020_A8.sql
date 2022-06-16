CREATE TABLE [Financieel].[Grootboekdetails_2020_A8]
(
[Sleutel grootboekrekening] [int] NOT NULL,
[Sleutel eenheid] [int] NULL,
[Rekeningnummer] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Sleutel cluster] [int] NULL,
[Datum] [date] NULL,
[Bedrag toegewezen] [float] NULL,
[Is DAEB] [varchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Documentnummer] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Werksoort] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Projectnummer] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Projecttype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
