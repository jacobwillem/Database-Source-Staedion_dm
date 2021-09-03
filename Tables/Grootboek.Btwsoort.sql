CREATE TABLE [Grootboek].[Btwsoort]
(
[Btwsoort_id] [int] NULL,
[Btwsoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Btwsoort_01] ON [Grootboek].[Btwsoort] ([Btwsoort_id]) ON [PRIMARY]
GO
