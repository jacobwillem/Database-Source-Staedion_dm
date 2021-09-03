CREATE TABLE [Datakwaliteit].[Bron]
(
[bk_code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Bron] ADD CONSTRAINT [PK__Bron__1074E0A0D8CA15C5] PRIMARY KEY CLUSTERED ([bk_code]) ON [PRIMARY]
GO
