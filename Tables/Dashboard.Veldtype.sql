CREATE TABLE [Dashboard].[Veldtype]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Veldtype] ADD CONSTRAINT [PK__Veldtype__3213E83F9C6323D3] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
