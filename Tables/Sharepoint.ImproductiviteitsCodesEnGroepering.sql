CREATE TABLE [Sharepoint].[ImproductiviteitsCodesEnGroepering]
(
[Improductiviteitscode_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Klachtsoort_id] [int] NULL,
[Kostencode_id] [int] NULL,
[Omschrijving improductiviteitscode rapportage] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Groepering improductiviteit] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
