CREATE TABLE [Datakwaliteit].[Indicator]
(
[id] [int] NOT NULL,
[Omschrijving] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Volgorde] [int] NULL,
[Marge_percentage] [numeric] (12, 2) NULL,
[Weergaveformat] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[fk_bron_id] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Definitie] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Definitie_url] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Definitie_aanduiding] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Cumulatief] [bit] NULL,
[Gemiddelde] [bit] NULL,
[Dimension_completeness] [bit] NULL,
[Dimension_uniqueness] [bit] NULL,
[Dimension_timeliness] [bit] NULL,
[Dimension_validity] [bit] NULL,
[Dimension_accuracy] [bit] NULL,
[Dimension_consistency] [bit] NULL,
[Procedure_completeness OUD] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Procedure_uniqueness] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Procedure_timeliness] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Procedure_validity] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Procedure_consistency] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Procedure_opmerking] [ntext] COLLATE Latin1_General_CI_AS NULL,
[parent_id] [int] NULL,
[fk_subsysteem_id] [smallint] NULL,
[fk_berekeningswijze_id] [smallint] NULL,
[fk_frequentie_id] [smallint] NULL,
[fk_kleurschema_id] [smallint] NULL,
[fk_bedrijfsonderdeel_id] [smallint] NULL,
[fk_aanspreekpunt_id] [smallint] NULL,
[fk_wijzevullen_id] [smallint] NULL,
[fk_schaalsoort_id] [smallint] NULL,
[fk_veldtype_id] [smallint] NULL,
[Indicator_actief] [bit] NULL,
[Noemer] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Zichtbaar] [bit] NULL,
[FilterCorpodata] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Details_toevoegen] [bit] NULL,
[bron_database] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Procedure_Accuracy] AS (case  when [Dimension_accuracy]=(1) then (('EXEC [Datakwaliteit].[sp_accuratesse] @Attribuut = '+'''')+[bron_database])+'''' end),
[fk_indicatordimensie_id] [int] NOT NULL CONSTRAINT [DF__Indicator__fk_in__61FB72FB] DEFAULT ((15)),
[id_samengesteld] AS ([ID]*(100)+[fk_indicatordimensie_id]),
[Procedure_Completeness] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL,
[Procedure_Overig] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Indicator] ADD CONSTRAINT [PK_Indicator] PRIMARY KEY CLUSTERED ([id], [fk_indicatordimensie_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Indicator] ON [Datakwaliteit].[Indicator] ([id_samengesteld]) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Indicator] ADD CONSTRAINT [FK__Indicator__fk_in__63E3BB6D] FOREIGN KEY ([fk_indicatordimensie_id]) REFERENCES [Datakwaliteit].[Indicatordimensie] ([id])
GO
