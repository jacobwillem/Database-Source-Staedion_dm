CREATE TABLE [Huuraanpassing].[Huurprijs_1_juli]
(
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Adres] [nvarchar] (92) COLLATE Latin1_General_CI_AS NOT NULL,
[Clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Clusternaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Assetmanager] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Peildatum] [datetime] NOT NULL,
[Huurbeleid] [varchar] (15) COLLATE Latin1_General_CI_AS NULL,
[Nettohuur] [float] NULL,
[Nettohuur incl btw] [float] NULL,
[Brutohuur] [float] NULL,
[Brutohuur incl btw] [float] NULL,
[prolongatietermijn] [varchar] (8000) COLLATE Latin1_General_CI_AS NULL,
[Corpodata type] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
