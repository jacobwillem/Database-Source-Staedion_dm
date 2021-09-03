CREATE TABLE [Dashboard].[RealisatieDetails]
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
[Noemer] [numeric] (16, 4) NULL,
[Clusternummer] [varchar] (7) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[RealisatieDetails] ADD CONSTRAINT [PK_RealisatieDetails] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RealisatieDetails_i1] ON [Dashboard].[RealisatieDetails] ([fk_indicator_id], [Datum]) ON [PRIMARY]
GO
