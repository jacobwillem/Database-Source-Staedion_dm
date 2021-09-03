CREATE TABLE [Dashboard].[Realisatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Realisatie] ADD CONSTRAINT [PK__waarde__3213E83F15A6FCAB] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Realisatie] WITH NOCHECK ADD CONSTRAINT [FK__waarde__fk_indic__178F451D] FOREIGN KEY ([fk_indicator_id]) REFERENCES [Dashboard].[Indicator] ([id])
GO
