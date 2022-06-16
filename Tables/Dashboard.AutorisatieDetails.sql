CREATE TABLE [Dashboard].[AutorisatieDetails]
(
[Account] [varchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[fk_indicator_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[AutorisatieDetails] ADD CONSTRAINT [PK_AutorisatieDetails] PRIMARY KEY CLUSTERED ([Account], [fk_indicator_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DetailToegang] ON [Dashboard].[AutorisatieDetails] ([fk_indicator_id]) ON [PRIMARY]
GO
