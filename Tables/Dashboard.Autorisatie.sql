CREATE TABLE [Dashboard].[Autorisatie]
(
[Account] [varchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[Rol] [varchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[Toegang] [bit] NOT NULL CONSTRAINT [DF_Autorisatie_Toegang] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Autorisatie] ADD CONSTRAINT [PK_Autorisatie] PRIMARY KEY CLUSTERED ([Account], [Rol]) ON [PRIMARY]
GO
