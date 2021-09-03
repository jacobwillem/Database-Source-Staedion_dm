CREATE TABLE [Datakwaliteit].[UitzonderingAutorisatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Gebruiker] [nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
[isadmin] [bit] NOT NULL CONSTRAINT [DF_UitzonderingAutorisatie_Admin] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[UitzonderingAutorisatie] ADD CONSTRAINT [PK_UitzonderingAutorisatie] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UitzonderingAutorisatie] ON [Datakwaliteit].[UitzonderingAutorisatie] ([fk_indicator_id], [Gebruiker]) ON [PRIMARY]
GO
GRANT DELETE ON  [Datakwaliteit].[UitzonderingAutorisatie] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Datakwaliteit].[UitzonderingAutorisatie] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Datakwaliteit].[UitzonderingAutorisatie] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Datakwaliteit].[UitzonderingAutorisatie] TO [STAEDION\svcPowerBI]
GO
