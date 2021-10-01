CREATE TABLE [dbo].[OLE DB Destination]
(
[InhoudstypeId] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Werkruimte] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ActivumIdVoorCompliance] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[NaamDataset] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[IDDataset] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[AangemaaktDoor] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[RefreshMonitoren] [bit] NULL,
[HyperlinkRapport] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Id] [int] NULL,
[Inhoudstype] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Gewijzigd] [datetime] NULL,
[Gemaakt] [datetime] NULL,
[GemaaktDoorId] [int] NULL,
[GewijzigdDoorId] [int] NULL,
[Owshiddenversion] [int] NULL,
[Versie] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Pad] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
