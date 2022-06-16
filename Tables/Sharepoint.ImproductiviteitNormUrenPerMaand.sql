CREATE TABLE [Sharepoint].[ImproductiviteitNormUrenPerMaand]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_improductiviteitstype_id] [int] NULL,
[Datum] [date] NULL,
[NormUren] [int] NULL,
[Toelichting] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Bron] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
