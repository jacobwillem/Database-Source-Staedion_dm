CREATE TABLE [Grootboek].[Documentsoort]
(
[Documentsoort_id] [int] NULL,
[Documentsoort] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Documentsoort_01] ON [Grootboek].[Documentsoort] ([Documentsoort_id]) ON [PRIMARY]
GO
