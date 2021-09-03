CREATE TABLE [Datakwaliteit].[Bedrijfsonderdeel]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Bedrijfsonderdeel] ADD CONSTRAINT [PK__Bedrijfs__3213E83FD530E422] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
