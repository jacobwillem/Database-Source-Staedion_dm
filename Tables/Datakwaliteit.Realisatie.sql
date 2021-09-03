CREATE TABLE [Datakwaliteit].[Realisatie]
(
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_indicator_id] [int] NULL,
[Teller] [numeric] (16, 4) NULL,
[Noemer] [numeric] (16, 4) NULL,
[fk_indicatordimensie_id] [int] NULL,
[id_samengesteld] AS ([fk_indicator_id]*(100)+[fk_indicatordimensie_id])
) ON [PRIMARY]
GO
