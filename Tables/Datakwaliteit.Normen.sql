CREATE TABLE [Datakwaliteit].[Normen]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Normen] ADD CONSTRAINT [PK__Normen__3213E83F498DA435] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Normen] ON [Datakwaliteit].[Normen] ([fk_indicator_id]) ON [PRIMARY]
GO
