CREATE TABLE [Projecten].[Realisatie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[project_id] [int] NULL,
[cluster] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Budget_id] [int] NULL,
[Budgetregelnr_] [int] NULL,
[Werksoort_id] [int] NULL,
[Job Ledger Entry No_] [int] NULL,
[Resource No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Item No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[G_L Account No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Vendor No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Document No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Boekdatum] [date] NULL,
[Realisatie incl_ BTW] [decimal] (12, 2) NULL,
[Realisatie excl_ BTW] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Realisatie] ADD CONSTRAINT [PK_Realisatie] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Realisatie] ADD CONSTRAINT [FK_Realisatie_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Algemeen].[Bedrijven] ([Bedrijf_id])
GO
ALTER TABLE [Projecten].[Realisatie] ADD CONSTRAINT [FK_Realisatie_Budget] FOREIGN KEY ([Budget_id]) REFERENCES [Projecten].[Budget] ([id])
GO
ALTER TABLE [Projecten].[Realisatie] ADD CONSTRAINT [FK_Realisatie_Project] FOREIGN KEY ([project_id]) REFERENCES [Projecten].[Project] ([id])
GO
ALTER TABLE [Projecten].[Realisatie] ADD CONSTRAINT [FK_Realisatie_Werksoort] FOREIGN KEY ([Werksoort_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
