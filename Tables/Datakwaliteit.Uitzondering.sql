CREATE TABLE [Datakwaliteit].[Uitzondering]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[id_samengesteld] [int] NOT NULL,
[sleutel_entiteit] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[Aangemaakt] [datetime] NOT NULL,
[Aangemaakt_door] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[Startdatum] [datetime] NOT NULL,
[Einddatum] [datetime] NULL,
[Opmerking] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Uitzondering] ADD CONSTRAINT [PK_Uitzondering] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Uitzondering_3] ON [Datakwaliteit].[Uitzondering] ([Einddatum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Uitzondering] ON [Datakwaliteit].[Uitzondering] ([id_samengesteld]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Uitzondering_1] ON [Datakwaliteit].[Uitzondering] ([sleutel_entiteit]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Uitzondering_2] ON [Datakwaliteit].[Uitzondering] ([Startdatum]) ON [PRIMARY]
GO
GRANT DELETE ON  [Datakwaliteit].[Uitzondering] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Datakwaliteit].[Uitzondering] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Datakwaliteit].[Uitzondering] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Datakwaliteit].[Uitzondering] TO [STAEDION\svcPowerBI]
GO
