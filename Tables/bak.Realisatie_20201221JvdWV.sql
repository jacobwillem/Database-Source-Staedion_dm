CREATE TABLE [bak].[Realisatie_20201221JvdWV]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
