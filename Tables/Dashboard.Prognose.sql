CREATE TABLE [Dashboard].[Prognose]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Jaarmaand] AS (CONVERT([int],left(CONVERT([varchar],[Datum],(112)),(6)),(0))) PERSISTED,
[Datum] [datetime] NOT NULL,
[Waarde] [numeric] (13, 5) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Huidig] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Prognose] ADD CONSTRAINT [PK_Prognose_1] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Prognose] ON [Dashboard].[Prognose] ([fk_indicator_id], [Jaarmaand]) ON [PRIMARY]
GO
GRANT DELETE ON  [Dashboard].[Prognose] TO [STAEDION\PowerBi]
GO
GRANT INSERT ON  [Dashboard].[Prognose] TO [STAEDION\PowerBi]
GO
GRANT UPDATE ON  [Dashboard].[Prognose] TO [STAEDION\PowerBi]
GO
GRANT DELETE ON  [Dashboard].[Prognose] TO [STAEDION\svcPowerBI]
GO
GRANT INSERT ON  [Dashboard].[Prognose] TO [STAEDION\svcPowerBI]
GO
GRANT SELECT ON  [Dashboard].[Prognose] TO [STAEDION\svcPowerBI]
GO
GRANT UPDATE ON  [Dashboard].[Prognose] TO [STAEDION\svcPowerBI]
GO
