CREATE TABLE [bak].[Indicator]
(
[id] [int] NOT NULL,
[parent_id] [int] NULL,
[Omschrijving] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[fk_indicatorgroep_id] [int] NULL,
[Volgorde] [int] NULL,
[fk_kleurschema_id] [int] NULL,
[Grenswaarde_1] [numeric] (12, 2) NULL,
[Grenswaarde_2] [numeric] (12, 2) NULL,
[Grenswaarde_3] [numeric] (12, 2) NULL,
[fk_bedrijfsonderdeel_id] [int] NULL,
[fk_aanspreekpunt_id] [int] NULL,
[fk_wijzevullen_id] [int] NULL,
[Marge_percentage] [numeric] (12, 2) NULL,
[fk_schaalsoort_id] [int] NULL,
[fk_veldtype_id] [int] NULL,
[Url] [varchar] (1000) COLLATE Latin1_General_CI_AS NULL,
[Gecontroleerd] [smallint] NULL,
[Kpilevel] [smallint] NULL,
[fk_subsysteem_id] [int] NULL,
[Jaarnorm] [numeric] (12, 2) NULL,
[Weergaveformat] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[fk_bron_id] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Definitie] [nvarchar] (1024) COLLATE Latin1_General_CI_AS NULL,
[Cumulatief] [bit] NULL,
[Gemiddelde] [bit] NULL,
[Detail] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
