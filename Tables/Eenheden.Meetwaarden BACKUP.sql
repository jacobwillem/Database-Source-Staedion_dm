CREATE TABLE [Eenheden].[Meetwaarden BACKUP]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Peildatum] [date] NULL,
[Bedrijf_id] [int] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Eigenschappen_id] [int] NULL,
[Woningaardering_id] [int] NULL,
[Exploitatiestatus_id] [int] NULL,
[Eenheidstatus_id] [int] NULL,
[Verhuurbare dagen] [int] NULL,
[Huurdernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Prolongatietermijn] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Kale huur] [decimal] (12, 2) NULL,
[Kale huur incl. btw] [decimal] (12, 2) NULL,
[Netto huur] [decimal] (12, 2) NULL,
[Netto huur incl. btw] [decimal] (12, 2) NULL,
[Btw op netto huur] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Huurkorting] [decimal] (12, 2) NULL,
[Huurkorting incl. btw] [decimal] (12, 2) NULL,
[Netto huur incl. korting en btw] [decimal] (12, 2) NULL,
[Btw compensatie] [decimal] (12, 2) NULL,
[Btw compensatie incl. btw] [decimal] (12, 2) NULL,
[Verbruikskosten] [decimal] (12, 2) NULL,
[Verbruikskosten incl. btw] [decimal] (12, 2) NULL,
[Servicekosten] [decimal] (12, 2) NULL,
[Servicekosten 2] [decimal] (12, 2) NULL,
[Servicekosten incl. btw] [decimal] (12, 2) NULL,
[Stookkosten] [decimal] (12, 2) NULL,
[Water] [decimal] (12, 2) NULL,
[Water incl. btw] [decimal] (12, 2) NULL,
[Bruto huur] [decimal] (12, 2) NULL,
[Bruto huur incl. btw] [decimal] (12, 2) NULL,
[Subsidiabel deel] [decimal] (12, 2) NULL,
[Subsidiabele huur] [decimal] (12, 2) NULL,
[Markthuur] [decimal] (12, 2) NULL,
[Type woningwaardering] [char] (15) COLLATE Latin1_General_CI_AS NULL,
[Ingangsdatum woningwaardering] [date] NULL,
[Totaal punten] [decimal] (12, 2) NULL,
[Totaal punten afgerond] [decimal] (12, 2) NULL,
[Maximaal toegestane huur] [decimal] (12, 2) NULL,
[Totaal oppervlakte] [decimal] (12, 2) NULL,
[Percentage max. redelijke huur] [decimal] (12, 2) NULL,
[Energiewaardering] [varchar] (30) COLLATE Latin1_General_CI_AS NULL,
[EPA label] [varchar] (5) COLLATE Latin1_General_CI_AS NULL,
[Energie index] [decimal] (12, 2) NULL,
[Bouwjaar] [int] NULL,
[Datum afgemeld] [date] NULL,
[Energie punten] [decimal] (12, 2) NULL,
[Doelgroep] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Aftopgrens] [decimal] (12, 2) NULL,
[Streefhuur] [decimal] (12, 2) NULL,
[Streefhuur (oud)] [decimal] (12, 2) NULL,
[Administratief eigenaar] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Juridisch eigenaar] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Beheerder] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
