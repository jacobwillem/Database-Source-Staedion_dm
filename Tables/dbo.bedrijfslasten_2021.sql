CREATE TABLE [dbo].[bedrijfslasten_2021]
(
[categorienummer] [int] NULL,
[categorie] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[rekeningnummer] [nvarchar] (12) COLLATE Latin1_General_CI_AS NULL,
[rekening] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Kostenplaatscode] [nvarchar] (12) COLLATE Latin1_General_CI_AS NULL,
[Kostenplaats] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Datum] [date] NULL,
[Bedrag] [decimal] (16, 14) NULL
) ON [PRIMARY]
GO
