CREATE TABLE [Leefbaarheid].[DossierActieRegel]
(
[DossierActieRegel_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Timestamp] [binary] (8) NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Leefbaarheidsdossier_id] [int] NULL,
[Regelnr] [int] NULL,
[Datum] [date] NULL,
[Actie_id] [int] NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Gebruiker] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Betrokkene] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klachtafhandeling_id] [int] NULL,
[Urgentie_id] [int] NULL,
[Doorbelasten aan veroorzaker] [varchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Percentage doorbelasting] [decimal] (6, 2) NULL,
[Status] [varchar] (25) COLLATE Latin1_General_CI_AS NULL,
[Offertenr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Ordernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Afgehandeld door] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Afgehandeld per] [date] NULL,
[ActieregelDossierstatus_id] [int] NULL,
[Huurdernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Onderhoudsverzoeknr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Onderhoudstaaknr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
