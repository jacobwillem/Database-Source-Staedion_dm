CREATE TABLE [Huren].[f_huursom_uitzondering]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Datum] [date] NULL,
[Huursom_periode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Huursom_reden_uitzondering] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
