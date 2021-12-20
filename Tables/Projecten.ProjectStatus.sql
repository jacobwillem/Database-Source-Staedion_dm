CREATE TABLE [Projecten].[ProjectStatus]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Status] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Actie] [int] NULL,
[Initieel] [tinyint] NULL,
[Offerte] [tinyint] NULL,
[Order] [tinyint] NULL,
[In uitvoering] [tinyint] NULL,
[Technisch gereed] [tinyint] NULL,
[Afgehandeld] [tinyint] NULL,
[Vervallen] [tinyint] NULL,
[Active] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectStatus] ADD CONSTRAINT [PK_ProjectStatus] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[ProjectStatus] ADD CONSTRAINT [FK_ProjectStatus_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Algemeen].[Bedrijven] ([Bedrijf_id])
GO
