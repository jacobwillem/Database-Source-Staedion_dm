CREATE TABLE [bak].[Normen_2600_20220513MV]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 5) NULL
) ON [PRIMARY]
GO
