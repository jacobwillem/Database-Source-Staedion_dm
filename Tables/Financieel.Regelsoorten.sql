CREATE TABLE [Financieel].[Regelsoorten]
(
[Regelsoort_id] [int] NULL,
[Regelsoort] [varchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Regelsoorten_01] ON [Financieel].[Regelsoorten] ([Regelsoort_id]) ON [PRIMARY]
GO
