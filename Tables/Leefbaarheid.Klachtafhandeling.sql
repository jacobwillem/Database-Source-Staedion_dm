CREATE TABLE [Leefbaarheid].[Klachtafhandeling]
(
[Klachtafhandeling_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Klachtafhandeling] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (85) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
