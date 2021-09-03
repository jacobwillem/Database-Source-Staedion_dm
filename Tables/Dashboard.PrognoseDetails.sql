CREATE TABLE [Dashboard].[PrognoseDetails]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Datum] [datetime] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL,
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Huidig] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PrognoseDetails_i1] ON [Dashboard].[PrognoseDetails] ([fk_indicator_id], [Datum]) ON [PRIMARY]
GO
