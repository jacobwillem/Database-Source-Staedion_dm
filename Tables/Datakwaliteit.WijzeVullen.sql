CREATE TABLE [Datakwaliteit].[WijzeVullen]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[WijzeVullen] ADD CONSTRAINT [PK__WijzeVul__3213E83F7AFA768F] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
