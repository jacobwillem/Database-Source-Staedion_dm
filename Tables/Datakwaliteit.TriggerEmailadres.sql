CREATE TABLE [Datakwaliteit].[TriggerEmailadres]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_trigger_id] [int] NOT NULL,
[Emailadres] [varchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[TriggerEmailadres] ADD CONSTRAINT [PK_TriggerEmailadres] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fk_trigger_id1] ON [Datakwaliteit].[TriggerEmailadres] ([fk_trigger_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [Datakwaliteit].[TriggerEmailadres] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Datakwaliteit].[TriggerEmailadres] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Datakwaliteit].[TriggerEmailadres] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Datakwaliteit].[TriggerEmailadres] TO [STAEDION\svcPowerBI]
GO
