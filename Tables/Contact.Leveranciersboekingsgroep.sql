CREATE TABLE [Contact].[Leveranciersboekingsgroep]
(
[Leveranciersboekingsgroep_id] [int] NOT NULL IDENTITY(0, 1),
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Schuldenrekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Verplichtingenrekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
