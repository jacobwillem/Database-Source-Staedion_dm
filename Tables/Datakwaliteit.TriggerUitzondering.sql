CREATE TABLE [Datakwaliteit].[TriggerUitzondering]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_trigger_id] [int] NOT NULL,
[Uitzondering] [varchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[TriggerUitzondering] ADD CONSTRAINT [PK_TriggerUitzondering] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fk_trigger_id3] ON [Datakwaliteit].[TriggerUitzondering] ([fk_trigger_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [Datakwaliteit].[TriggerUitzondering] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Datakwaliteit].[TriggerUitzondering] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Datakwaliteit].[TriggerUitzondering] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Datakwaliteit].[TriggerUitzondering] TO [STAEDION\svcPowerBI]
GO
