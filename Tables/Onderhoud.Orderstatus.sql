CREATE TABLE [Onderhoud].[Orderstatus]
(
[Orderstatus_id] [int] NULL,
[Orderstatus] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Orderstatus_01] ON [Onderhoud].[Orderstatus] ([Orderstatus_id]) ON [PRIMARY]
GO
