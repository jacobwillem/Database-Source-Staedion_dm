CREATE TABLE [Dashboard].[Realisatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Datum] [datetime] NOT NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Realisatie] ADD CONSTRAINT [PK__waarde__3213E83F15A6FCAB] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Realisatie_Datum] ON [Dashboard].[Realisatie] ([Datum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Realisatie_fk_indicator_id] ON [Dashboard].[Realisatie] ([fk_indicator_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Realisatie_fk_indicator_id_Datum] ON [Dashboard].[Realisatie] ([fk_indicator_id], [Datum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Realisatie_Laaddatum] ON [Dashboard].[Realisatie] ([Laaddatum]) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Realisatie] WITH NOCHECK ADD CONSTRAINT [FK__waarde__fk_indic__178F451D] FOREIGN KEY ([fk_indicator_id]) REFERENCES [Dashboard].[Indicator] ([id])
GO
