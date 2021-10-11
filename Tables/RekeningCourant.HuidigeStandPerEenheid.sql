CREATE TABLE [RekeningCourant].[HuidigeStandPerEenheid]
(
[Bedrijf] [varchar] (29) COLLATE Latin1_General_CI_AS NOT NULL,
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Rekensaldo] [decimal] (12, 2) NULL,
[Saldo] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
