CREATE TABLE [bak].[prognose_20211110_nieuwbouw_renovatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Jaarmaand] [int] NULL,
[Datum] [datetime] NOT NULL,
[Waarde] [numeric] (13, 5) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Huidig] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
