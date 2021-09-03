CREATE TABLE [Datakwaliteit].[Activiteiten]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Activiteit] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Datum planning] [date] NULL,
[Datum gerealiseerd] [date] NULL,
[Waarde] [numeric] (12, 4) NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Datakwaliteit].[Activiteiten] ADD CONSTRAINT [PK_activiteiten] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
