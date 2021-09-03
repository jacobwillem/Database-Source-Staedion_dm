CREATE TABLE [Dashboard].[Normen]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 5) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Normen] ADD CONSTRAINT [PK__Normen__3213E83F27207B98] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Normen] WITH NOCHECK ADD CONSTRAINT [FK__norm__fk_indicat__12CA9000] FOREIGN KEY ([fk_indicator_id]) REFERENCES [Dashboard].[Indicator] ([id])
GO
