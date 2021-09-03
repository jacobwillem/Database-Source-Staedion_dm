CREATE TABLE [RekeningCourant].[HistorieStand]
(
[mg_bedrijf] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[klantnr] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[klantboekingsgroep] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Name] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[eenheid_adres] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[eenheid_postcode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[eenheid_plaats] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[complex] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[complex_naam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[technisch_type] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[wijk_naam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[buurt_naam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[staedion_verhuurteam] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[staedion_thuisteam] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[da_heeft_lopend_contract] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[heeft_minnelijkeschikking] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[heeft_wsnp] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[heeft_wsnp_oud] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[ha_bij_deurwaarder] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[ha_heeft_betalingsregeling] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[prioriteit] [smallint] NULL,
[Regel] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[openstaand_saldo] [numeric] (12, 2) NULL,
[saldo] [numeric] (12, 2) NULL,
[vooruitbetaling] [numeric] (12, 2) NULL,
[gecorr_saldo] [numeric] (12, 2) NULL,
[percentage] [numeric] (8, 2) NULL,
[voorziening] [numeric] (12, 2) NULL,
[categorie] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[BOG] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Peildatum] [date] NULL,
[Gegenereerd] [datetime] NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'Auteur', N'Roelof van Goor', 'SCHEMA', N'RekeningCourant', 'TABLE', N'HistorieStand', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'RekeningCourant', 'TABLE', N'HistorieStand', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Historische tabel die op bepaalde tijdstippen gevuld wordt vanuit empire_dwh.dbo.[dsp_rs_voorziening_debiteuren]. Zie voor definities aldoor. Jaarplan wordt ook vanuit die procedure berekend overigens.', 'SCHEMA', N'RekeningCourant', 'TABLE', N'HistorieStand', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'staedion_dm.RekeningCourant.HistorieStand where Peildatum = ''20201231''', 'SCHEMA', N'RekeningCourant', 'TABLE', N'HistorieStand', NULL, NULL
GO
