CREATE TABLE [Dashboard].[Bedrijfsonderdeel]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Bedrijfsonderdeel] ADD CONSTRAINT [PK__Bedrijfs__3213E83F8A242CCA] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
