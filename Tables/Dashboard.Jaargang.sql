CREATE TABLE [Dashboard].[Jaargang]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_rapport_id] [int] NULL,
[Jaargang] [int] NOT NULL,
[fk_indicator_id] [int] NOT NULL,
[parent_id] [int] NULL,
[fk_indicatorgroep_id] [int] NULL,
[fk_kpilevel_id] [int] NULL,
[Aanduiding] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[Volgorde] [int] NULL,
[Zichtbaar] [bit] NULL CONSTRAINT [DF_Jaargang_Zichtbaar] DEFAULT ((0)),
[fk_bedrijfsonderdeel_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Jaargang] ADD CONSTRAINT [PK_Jaargang] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Jaargang] ADD CONSTRAINT [IX_Jaargang] UNIQUE NONCLUSTERED ([Jaargang], [fk_indicator_id]) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Jaargang] ADD CONSTRAINT [FK__Jaargang__fk_ind__7D4E87B5] FOREIGN KEY ([fk_indicator_id]) REFERENCES [Dashboard].[Indicator] ([id])
GO
