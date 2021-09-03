CREATE TABLE [bak].[Dashboard_RealisatieDetails_20200511_1553]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Datum] [date] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_indicator_id] [int] NULL,
[fk_eenheid_id] [int] NULL,
[fk_contract_id] [int] NULL,
[fk_klant_id] [int] NULL,
[Teller] [numeric] (16, 4) NULL,
[Noemer] [numeric] (16, 4) NULL
) ON [PRIMARY]
GO
