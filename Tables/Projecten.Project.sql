CREATE TABLE [Projecten].[Project]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Nr_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Naam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Projecttype_id] [int] NULL,
[Status_id] [int] NULL,
[Projectfase_id] [int] NULL,
[Geblokkeerd] [tinyint] NULL,
[Startdatum] [date] NULL,
[Jaar] [int] NULL,
[Nr_ Hoofdproject] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Aangemaakt op] [date] NULL,
[Opleverdatum] [date] NULL,
[Soort] [int] NULL,
[Datum gereed] [date] NULL,
[Finish Year] [int] NULL,
[Date Closed] [date] NULL,
[Actief] [tinyint] NULL,
[Functie1_id] [int] NULL,
[Contact No_1] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Functie2_id] [int] NULL,
[Contact No_2] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Functie3_id] [int] NULL,
[Contact No_3] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Projectleider_id] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Projectleider] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_Functie_1] FOREIGN KEY ([Functie1_id]) REFERENCES [Projecten].[Functie] ([id])
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_Functie_2] FOREIGN KEY ([Functie2_id]) REFERENCES [Projecten].[Functie] ([id])
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_Functie_3] FOREIGN KEY ([Functie3_id]) REFERENCES [Projecten].[Functie] ([id])
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_projectFase] FOREIGN KEY ([Projectfase_id]) REFERENCES [Projecten].[ProjectFase] ([id])
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_projectStatus] FOREIGN KEY ([Status_id]) REFERENCES [Projecten].[ProjectStatus] ([id])
GO
ALTER TABLE [Projecten].[Project] ADD CONSTRAINT [FK_project_projectType] FOREIGN KEY ([Projecttype_id]) REFERENCES [Projecten].[ProjectType] ([id])
GO
