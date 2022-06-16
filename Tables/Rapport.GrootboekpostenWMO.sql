CREATE TABLE [Rapport].[GrootboekpostenWMO]
(
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Eenheid/collectief object + adres] [nvarchar] (113) COLLATE Latin1_General_CI_AS NULL,
[Referentie onderhoud] [nvarchar] (15) COLLATE Latin1_General_CI_AS NULL,
[Boekdatum] [datetime] NULL,
[Kosten A815160] [decimal] (38, 2) NULL,
[Opbrengst A850250] [decimal] (38, 2) NULL,
[Saldo A815160 + A850250] [decimal] (38, 2) NULL,
[Opslag A850260] [decimal] (38, 2) NULL,
[Factuurnr kosten A815160] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Factuurnr opbrengst A850250] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Teller Doorberekend] [int] NOT NULL,
[Teller WMO beschikking] [int] NOT NULL,
[HyperlinkFactuur] [nvarchar] (109) COLLATE Latin1_General_CI_AS NULL,
[HyperlinkEmpire] [nvarchar] (1030) COLLATE Latin1_General_CI_AS NULL,
[Documenten] [nvarchar] (49) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[gegenereerd] [datetime] NOT NULL
) ON [PRIMARY]
GO
