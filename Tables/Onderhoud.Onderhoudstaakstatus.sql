CREATE TABLE [Onderhoud].[Onderhoudstaakstatus]
(
[Onderhoudstaakstatus_id] [int] NULL,
[Onderhoudstaakstatus] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Onderhoudstaakstatus_01] ON [Onderhoud].[Onderhoudstaakstatus] ([Onderhoudstaakstatus_id]) ON [PRIMARY]
GO
