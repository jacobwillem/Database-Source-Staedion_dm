CREATE TABLE [Datakwaliteit].[RealisatieBackup]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[RealisatieBackup] ADD CONSTRAINT [PK__waarde__3213E83F15A6FCAB] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
