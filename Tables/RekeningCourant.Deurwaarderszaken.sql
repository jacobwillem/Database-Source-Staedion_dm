CREATE TABLE [RekeningCourant].[Deurwaarderszaken]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Peildatum] [date] NULL,
[Bedrijf_id] [int] NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Regelnummer] [int] NULL,
[Dossiernr deurwaarder] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Ingangsdatum] [date] NULL,
[Ontruimingsdatum] [date] NULL,
[Afgesloten] [date] NULL,
[Status] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Rapportagestatus_id] [int] NULL,
[Deurwaardernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Deurwaarder] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Klantnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Aantal] [int] NULL,
[Klant naam] [nvarchar] (105) COLLATE Latin1_General_CI_AS NULL,
[Klant adres] [nvarchar] (70) COLLATE Latin1_General_CI_AS NULL,
[Klant postcode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Klant plaats] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Saldo] [decimal] (12, 2) NULL,
[Klant status] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Contracten] [int] NULL,
[Bruto maandhuur] [decimal] (12, 2) NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Datum stap] [date] NULL,
[Dossierstap] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Soort regel] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klantpost volgnummer] [int] NULL,
[Klantpost omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Boekdatum] [date] NULL,
[Oorspronkelijk bedrag] [decimal] (12, 2) NULL,
[Initieel overgedragen] [decimal] (12, 2) NULL,
[Rest bedrag] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
