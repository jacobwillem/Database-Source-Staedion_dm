CREATE TABLE [Dashboard].[Indicator]
(
[id] [int] NOT NULL,
[Omschrijving] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_aanspreekpunt_id] [int] NULL,
[fk_wijzevullen_id] [int] NULL,
[fk_schaalsoort_id] [int] NULL,
[fk_veldtype_id] [int] NULL,
[fk_subsysteem_id] [int] NULL,
[fk_proces_id] [int] NULL,
[fk_berekeningswijze_id] [int] NULL,
[fk_frequentie_id] [int] NULL,
[Cumulatief] [bit] NULL,
[Gemiddelde] [int] NULL,
[Observatie] [bit] NULL CONSTRAINT [DF_Indicator_Observatie] DEFAULT ((0)),
[Weergaveformat] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Detailrapport] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Definitie] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Gecontroleerd] [bit] NULL CONSTRAINT [DF_Indicator_Gecontroleerd] DEFAULT ((0)),
[Jaarnorm] [numeric] (12, 4) NULL,
[procedure_actief] [bit] NULL,
[procedure_naam] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[procedure_argument] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[procedure_opmerking] [ntext] COLLATE Latin1_General_CI_AS NULL,
[controle_brontabel] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Details] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Indicator] ADD CONSTRAINT [PK_Indicator] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Aanspreekpunt] ON [Dashboard].[Indicator] ([fk_aanspreekpunt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Berekeningswijze] ON [Dashboard].[Indicator] ([fk_berekeningswijze_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Frequentie] ON [Dashboard].[Indicator] ([fk_frequentie_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Proces] ON [Dashboard].[Indicator] ([fk_proces_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Schaalsoort] ON [Dashboard].[Indicator] ([fk_schaalsoort_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Subsysteem] ON [Dashboard].[Indicator] ([fk_subsysteem_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Veldtype] ON [Dashboard].[Indicator] ([fk_veldtype_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Wijzevullen] ON [Dashboard].[Indicator] ([fk_wijzevullen_id]) ON [PRIMARY]
GO
