CREATE TABLE [Projecten].[Budget_historie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Project_id] [int] NULL,
[Projectfase_id] [int] NULL,
[Budgetregelnr_] [int] NULL,
[Cluster] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Werksoort_id] [int] NULL,
[Startdatum] [date] NULL,
[Opleverdatum] [date] NULL,
[Werksoortboekingsgroep] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Vrije code Budgetregel] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Kostenrekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Budget_incl_btw] [decimal] (12, 2) NULL,
[Budget_excl_btw] [decimal] (12, 2) NULL,
[Budgetstatus_id] [int] NULL,
[Prognose_incl_btw] [decimal] (12, 2) NULL,
[Prognose_excl_btw] [decimal] (12, 2) NULL,
[Peildatum] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Budget_historie] ADD CONSTRAINT [PK_Budget_historie] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Budget_historie_01] ON [Projecten].[Budget_historie] ([bedrijf_id], [Project_id], [Projectfase_id], [Budgetregelnr_], [Cluster], [Peildatum]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Budget_historie] ADD CONSTRAINT [FK_Budget_historie_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Algemeen].[Bedrijven] ([Bedrijf_id])
GO
ALTER TABLE [Projecten].[Budget_historie] ADD CONSTRAINT [FK_Budget_historie_BudgetRegelStatus] FOREIGN KEY ([Budgetstatus_id]) REFERENCES [Projecten].[BudgetRegelStatus] ([id])
GO
ALTER TABLE [Projecten].[Budget_historie] ADD CONSTRAINT [FK_Budget_historie_Project] FOREIGN KEY ([Project_id]) REFERENCES [Projecten].[Project] ([id])
GO
ALTER TABLE [Projecten].[Budget_historie] ADD CONSTRAINT [FK_Budget_historie_ProjectFase] FOREIGN KEY ([Projectfase_id]) REFERENCES [Projecten].[ProjectFase] ([id])
GO
ALTER TABLE [Projecten].[Budget_historie] ADD CONSTRAINT [FK_Budget_historie_Werksoort] FOREIGN KEY ([Werksoort_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
