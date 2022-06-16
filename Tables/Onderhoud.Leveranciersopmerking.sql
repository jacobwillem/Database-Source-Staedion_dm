CREATE TABLE [Onderhoud].[Leveranciersopmerking]
(
[Leveranciersopmerking_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Timestamp] [binary] (8) NULL,
[Document Type] [int] NULL,
[No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Onderhoudsorder_id] [int] NULL,
[Line No_] [int] NULL,
[Verwijderd] [bit] NULL,
[Datum] [date] NULL,
[Gebruiker] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
