CREATE TABLE [bak].[Dashboard_RapportDetails_20211026MV]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_rapport_id] [int] NULL,
[fk_indicator_id] [int] NOT NULL,
[parent_id] [int] NULL,
[fk_indicatorgroep_id] [int] NULL,
[fk_kpilevel_id] [int] NULL,
[Aanduiding] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[Volgorde] [int] NULL,
[Zichtbaar] [bit] NULL,
[fk_bedrijfsonderdeel_id] [int] NULL
) ON [PRIMARY]
GO
