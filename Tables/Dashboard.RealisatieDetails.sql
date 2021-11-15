CREATE TABLE [Dashboard].[RealisatieDetails]
(
[id] [bigint] NOT NULL IDENTITY(1, 1),
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
[eenheidnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[bouwbloknummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[clusternummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[klantnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[volgnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[relatienummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[dossiernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[betalingsregelingnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[rekeningnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[documentnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[leveranciernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[werknemernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[projectnummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[verzoeknummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[ordernummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[taaknummer] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[overig] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[fk_eenheid_id] [int] NULL,
[fk_contract_id] [int] NULL,
[fk_klant_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[RealisatieDetails] ADD CONSTRAINT [PK_RealisatieDetails] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RealisatieDetails_Datum] ON [Dashboard].[RealisatieDetails] ([Datum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RealisatieDetails_fk_indicator_id] ON [Dashboard].[RealisatieDetails] ([fk_indicator_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RealisatieDetails_fk_indicator_id_Datum] ON [Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RealisatieDetails_Laaddatum] ON [Dashboard].[RealisatieDetails] ([Laaddatum]) ON [PRIMARY]
GO
