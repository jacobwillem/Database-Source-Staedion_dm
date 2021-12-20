CREATE TABLE [Projecten].[Verplichting_historie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[peildatum] [date] NULL,
[Project_id] [int] NULL,
[Budget_id] [int] NULL,
[Budgetregelnr_] [int] NULL,
[Werksoort_id] [int] NULL,
[Cluster] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Order status] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Document No_] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Inkoopregelnr_] [int] NULL,
[Orderbedrag] [decimal] (12, 2) NULL,
[Orderbedrag incl. btw] [decimal] (12, 2) NULL,
[verplicht_incl_btw] [decimal] (12, 2) NULL,
[verplicht_excl_btw] [decimal] (12, 2) NULL,
[Leveranciersnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving 2] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Verplichting_historie] ADD CONSTRAINT [PK_Verplichting_historie] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Verplichting_historie] ADD CONSTRAINT [FK_Verplichting_historie_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Algemeen].[Bedrijven] ([Bedrijf_id])
GO
ALTER TABLE [Projecten].[Verplichting_historie] ADD CONSTRAINT [FK_Verplichting_historie_Project] FOREIGN KEY ([Project_id]) REFERENCES [Projecten].[Project] ([id])
GO
ALTER TABLE [Projecten].[Verplichting_historie] ADD CONSTRAINT [FK_Verplichting_historie_Werksoort] FOREIGN KEY ([Werksoort_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
