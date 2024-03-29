CREATE TABLE [Datakwaliteit].[Test]
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
[Procedure_Accuracy] [nvarchar] (153) COLLATE Latin1_General_CI_AS NULL,
[fk_indicatordimensie_id] [int] NOT NULL,
[Procedure_Completeness] [nvarchar] (467) COLLATE Latin1_General_CI_AS NULL,
[id_samengesteld] [int] NULL,
[Procedure_Overig] [nvarchar] (324) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
