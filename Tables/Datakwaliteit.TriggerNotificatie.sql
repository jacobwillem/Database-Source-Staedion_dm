CREATE TABLE [Datakwaliteit].[TriggerNotificatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_trigger_id] [int] NOT NULL,
[Emailadres] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Datum] [datetime] NULL,
[Waarde] [varchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[TriggerNotificatie] ADD CONSTRAINT [PK_TriggerNotificatie] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fk_trigger_id2] ON [Datakwaliteit].[TriggerNotificatie] ([fk_trigger_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [Datakwaliteit].[TriggerNotificatie] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Datakwaliteit].[TriggerNotificatie] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Datakwaliteit].[TriggerNotificatie] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Datakwaliteit].[TriggerNotificatie] TO [STAEDION\svcPowerBI]
GO
