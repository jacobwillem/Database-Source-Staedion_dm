CREATE TABLE [Algemeen].[Communicatiewijze]
(
[Communicatiewijze_id] [int] NOT NULL IDENTITY(0, 1),
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Communicatiewijze] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Communicatiewijze_02] ON [Algemeen].[Communicatiewijze] ([Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Communicatiewijze_01] ON [Algemeen].[Communicatiewijze] ([Communicatiewijze_id]) ON [PRIMARY]
GO
