CREATE TABLE [Onderhoud].[Resource groep]
(
[Resource groep_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Resource groep] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Resource groep_02] ON [Onderhoud].[Resource groep] ([Bedrijf_id], [No_]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Resource groep_01] ON [Onderhoud].[Resource groep] ([Resource groep_id]) ON [PRIMARY]
GO
