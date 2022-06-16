CREATE TABLE [Projecten].[Projecteenheden]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Project_id] [int] NULL,
[Budget_id] [int] NULL,
[Volgnummer] [int] NULL,
[Budgetregelnr_] [int] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Collectiefnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Relatienr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bedrag excl. btw] [decimal] (12, 2) NULL,
[Gearchiveerd en verwijderd] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Teller] [decimal] (12, 6) NULL,
[Teller bepalen] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Werksoort_id] [int] NULL,
[Vervaldatum] [date] NULL
) ON [PRIMARY]
GO
