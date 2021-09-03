CREATE TABLE [Dashboard].[RealisatiePrognose]
(
[id] [numeric] (14, 0) NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_indicator_id] [int] NULL,
[fk_eenheid_id] [int] NULL,
[fk_contract_id] [int] NULL,
[fk_klant_id] [int] NULL,
[Teller] [numeric] (16, 4) NULL,
[Noemer] [numeric] (16, 4) NULL,
[Clusternummer] [varchar] (7) COLLATE Latin1_General_CI_AS NULL,
[Prognose] [int] NOT NULL,
[Detail.01] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.02] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.03] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.04] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.05] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.06] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.07] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.08] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.09] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Detail.10] [varchar] (128) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
