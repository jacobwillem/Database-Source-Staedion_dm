CREATE TABLE [Sharepoint].[AantallenStartBouwOplevering]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Title] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Pad] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Jaar] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[StartOplevering] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Norm] [int] NULL,
[Jan] [float] NULL,
[Feb] [float] NULL,
[Mrt] [float] NULL,
[Apr] [float] NULL,
[Mei] [float] NULL,
[Jun] [float] NULL,
[Jul] [float] NULL,
[Aug] [float] NULL,
[Sept] [float] NULL,
[Okt] [float] NULL,
[Nov] [float] NULL,
[Dec] [float] NULL,
[Totaal] [float] NULL,
[GemaaktDoor] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[GewijzigdDoor] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Projectmanager] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[TypeProject] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[TijdstipGenereren] [datetime] NULL,
[Peildatum] [date] NULL,
[Gemaakt] [datetimeoffset] NULL,
[Gewijzigd] [datetimeoffset] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Sharepoint].[AantallenStartBouwOplevering] ADD CONSTRAINT [PK_AantallenStartBouwOplevering] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
