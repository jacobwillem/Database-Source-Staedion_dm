CREATE TABLE [Dashboard].[Bron]
(
[bk_code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[Bron] ADD CONSTRAINT [PK__Bron__1074E0A0B9E7A02D] PRIMARY KEY CLUSTERED ([bk_code]) ON [PRIMARY]
GO
