CREATE TABLE [Onderhoud].[Werkgebieden]
(
[Werkgebied_id] [int] NOT NULL IDENTITY(1, 1),
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Werkgebied] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
