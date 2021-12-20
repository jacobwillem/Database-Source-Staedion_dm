CREATE TABLE [Onderhoud].[Afwijsreden]
(
[Afwijsreden_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Afwijsreden] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL,
[Soort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Extern te gebruiken] [varchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Afwijsreden_01] ON [Onderhoud].[Afwijsreden] ([Afwijsreden_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Afwijsreden_02] ON [Onderhoud].[Afwijsreden] ([Bedrijf_id], [Code]) ON [PRIMARY]
GO
