CREATE TABLE [RekeningCourant].[HistorieStandPerEenheid]
(
[Bedrijf] [varchar] (29) COLLATE Latin1_General_CI_AS NOT NULL,
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Rekensaldo] [decimal] (12, 2) NULL,
[Saldo] [decimal] (12, 2) NULL,
[Peildatum] [varchar] (8) COLLATE Latin1_General_CI_AS NOT NULL,
[Boekdatum openstaande post] [datetime] NOT NULL,
[Saldo nvt] [decimal] (12, 2) NULL,
[Saldo 0-1 maand] [decimal] (12, 2) NULL,
[Saldo 1-2 maanden] [decimal] (12, 2) NULL,
[Saldo 2-3 maanden] [decimal] (12, 2) NULL,
[Saldo 3-6 maanden] [decimal] (12, 2) NULL,
[Saldo 6-12 maanden] [decimal] (12, 2) NULL,
[Saldo >12 maanden] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
