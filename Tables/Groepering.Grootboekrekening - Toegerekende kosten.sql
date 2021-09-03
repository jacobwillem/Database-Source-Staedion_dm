CREATE TABLE [Groepering].[Grootboekrekening - Toegerekende kosten]
(
[Hoofdgroep] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Subgroep] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Toelichting] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Rekening] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Hoofdgroep sortering] [int] NULL,
[Subgroep sortering] [int] NULL
) ON [PRIMARY]
GO
