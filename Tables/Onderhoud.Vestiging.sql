CREATE TABLE [Onderhoud].[Vestiging]
(
[Vestiging_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Vestiging] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Als in-transit gebruiken] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Vestiging_02] ON [Onderhoud].[Vestiging] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Vestiging_01] ON [Onderhoud].[Vestiging] ([Vestiging_id]) ON [PRIMARY]
GO
