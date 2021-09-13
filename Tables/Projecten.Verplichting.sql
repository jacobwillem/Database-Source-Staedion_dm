CREATE TABLE [Projecten].[Verplichting]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
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
ALTER TABLE [Projecten].[Verplichting] ADD CONSTRAINT [PK_Verplichting] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Verplichting] ADD CONSTRAINT [FK_Verplichting_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
ALTER TABLE [Projecten].[Verplichting] ADD CONSTRAINT [FK_Verplichting_Project] FOREIGN KEY ([Project_id]) REFERENCES [Projecten].[Project] ([id])
GO
ALTER TABLE [Projecten].[Verplichting] ADD CONSTRAINT [FK_Verplichting_Werksoort] FOREIGN KEY ([Werksoort_id]) REFERENCES [Projecten].[Werksoort] ([id])
GO
