CREATE TABLE [bak].[Prognose_20210526PP]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Jaarmaand] [int] NULL,
[Datum] [datetime] NOT NULL,
[Waarde] [numeric] (12, 5) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Huidig] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
