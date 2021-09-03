CREATE TABLE [Dashboard].[WijzeVullen]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[WijzeVullen] ADD CONSTRAINT [PK__WijzeVul__3213E83FF01CB07E] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
