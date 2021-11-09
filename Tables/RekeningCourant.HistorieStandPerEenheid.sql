CREATE TABLE [RekeningCourant].[HistorieStandPerEenheid]
(
[Bedrijf] [varchar] (29) COLLATE Latin1_General_CI_AS NOT NULL,
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Saldo] [decimal] (12, 2) NULL,
[Rekensaldo] [decimal] (12, 2) NULL,
[Peildatum] [date] NOT NULL,
[Boekdatum openstaande post] [datetime] NOT NULL,
[Volgnr] [bigint] NULL,
[Vooruitbetaling] [numeric] (38, 20) NULL,
[Saldo nvt] [decimal] (12, 2) NULL,
[Saldo 0-1 maand] [decimal] (12, 2) NULL,
[Saldo 1 maand] [decimal] (12, 2) NULL,
[Saldo 3 maanden] [decimal] (12, 2) NULL,
[Saldo 4-6 maanden] [decimal] (12, 2) NULL,
[Saldo 7-11 maanden] [decimal] (12, 2) NULL,
[Saldo >=12 maanden] [decimal] (12, 2) NULL,
[Saldo 2 maanden] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
