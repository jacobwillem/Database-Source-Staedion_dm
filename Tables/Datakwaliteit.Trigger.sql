CREATE TABLE [Datakwaliteit].[Trigger]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Naam] [nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
[Norm] [numeric] (12, 4) NULL,
[Laatste] [datetime] NULL,
[maxOuderdom] [int] NOT NULL,
[Melding] [ntext] COLLATE Latin1_General_CI_AS NULL,
[fk_indicatordimensie_id] [int] NOT NULL CONSTRAINT [DF__Trigger__fk_indi__6F556E19] DEFAULT ((15)),
[id_samengesteld] AS ([fk_indicator_id]*(100)+[fk_indicatordimensie_id])
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Trigger] ADD CONSTRAINT [PK_Trigger] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Trigger] ON [Datakwaliteit].[Trigger] ([id_samengesteld]) ON [PRIMARY]
GO
GRANT DELETE ON  [Datakwaliteit].[Trigger] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Datakwaliteit].[Trigger] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Datakwaliteit].[Trigger] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Datakwaliteit].[Trigger] TO [STAEDION\svcPowerBI]
GO
