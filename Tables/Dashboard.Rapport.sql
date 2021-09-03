CREATE TABLE [Dashboard].[Rapport]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Rapport] [nvarchar] (64) COLLATE Latin1_General_CI_AS NOT NULL,
[Doelgroep] [nvarchar] (64) COLLATE Latin1_General_CI_AS NULL,
[Rol] AS (case  when [Doelgroep] IS NULL then [Rapport] else concat([Rapport],' - ',[Doelgroep]) end),
[Startdatum] [date] NULL,
[Einddatum] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Rapport] ADD CONSTRAINT [PK_Rapport] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Rapport_Rol] ON [Dashboard].[Rapport] ([Rol]) ON [PRIMARY]
GO
