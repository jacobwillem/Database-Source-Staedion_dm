CREATE TABLE [Datakwaliteit].[RealisatieDetails]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_indicator_id] [int] NULL,
[fk_eenheid_id] [int] NULL,
[fk_contract_id] [int] NULL,
[fk_klant_id] [int] NULL,
[Teller] [numeric] (16, 4) NULL,
[Noemer] [numeric] (16, 4) NULL,
[fk_indicatordimensie_id] [int] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[datEinde] [date] NULL,
[datIngang] [date] NULL,
[Hyperlink] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Bevinding] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Gebruiker] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_leefbaarheidsdossier_id] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[fk_medewerker_id] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[id_samengesteld] AS ([fk_indicator_id]*(100)+[fk_indicatordimensie_id]),
[Relatienr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[RealisatieDetails] ADD CONSTRAINT [PK_RealisatieDetails] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fk_indicator_id] ON [Datakwaliteit].[RealisatieDetails] ([fk_indicator_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [i1_RealisatieDetails] ON [Datakwaliteit].[RealisatieDetails] ([fk_indicator_id]) INCLUDE ([Laaddatum], [fk_indicatordimensie_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210331-124148] ON [Datakwaliteit].[RealisatieDetails] ([fk_indicator_id], [fk_indicatordimensie_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_id_samengesteld] ON [Datakwaliteit].[RealisatieDetails] ([id_samengesteld]) ON [PRIMARY]
GO
