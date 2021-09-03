CREATE TABLE [Dashboard].[Aanspreekpunt]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Aanspreekpunt] ADD CONSTRAINT [PK__Aanspree__3213E83F536042F9] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
