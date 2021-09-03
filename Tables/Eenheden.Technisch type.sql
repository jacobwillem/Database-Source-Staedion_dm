CREATE TABLE [Eenheden].[Technisch type]
(
[Technisch type_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Technisch type] [nvarchar] (70) COLLATE Latin1_General_CI_AS NULL,
[Alternatieve omschrijving 1] [nvarchar] (70) COLLATE Latin1_General_CI_AS NULL,
[Alternatieve omschrijving 2] [nvarchar] (70) COLLATE Latin1_General_CI_AS NULL,
[Corpodatatype_id] [int] NULL,
[Beslisboomtype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
