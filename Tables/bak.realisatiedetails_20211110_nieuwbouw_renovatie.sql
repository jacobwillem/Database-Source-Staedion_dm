CREATE TABLE [bak].[realisatiedetails_20211110_nieuwbouw_renovatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Datum] [date] NOT NULL,
[Laaddatum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Teller] [numeric] (16, 4) NULL,
[Noemer] [numeric] (16, 4) NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_01] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_02] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_03] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_04] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_05] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_06] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_07] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_08] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_09] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Detail_10] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[bk_eenheidnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_bouwbloknummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_clusternummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_klantnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_contactnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_dossiernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_betalingsregelingnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_rekeningnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_documentnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_leveranciernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_werknemernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_projectnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_verzoeknummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_ordernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_taaknummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bk_overig] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[Clusternummer] [varchar] (7) COLLATE Latin1_General_CI_AS NULL,
[fk_eenheid_id] [int] NULL,
[fk_contract_id] [int] NULL,
[fk_klant_id] [int] NULL
) ON [PRIMARY]
GO