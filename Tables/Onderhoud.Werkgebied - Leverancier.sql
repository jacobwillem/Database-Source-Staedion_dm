CREATE TABLE [Onderhoud].[Werkgebied - Leverancier]
(
[Werkgebied_leverancier_id] [int] NOT NULL IDENTITY(1, 1),
[Werkgebied_id] [int] NULL,
[Leveranciernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Reparatieonderhoud] [nchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Overig onderhoud] [nchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
