CREATE TABLE [Eenheden].[Corpodatatype]
(
[Corpodatatype_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Corpodatatype omschrijving] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
