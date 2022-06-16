CREATE TABLE [Leefbaarheid].[Leefbaarheidsdossier]
(
[Leefbaarheidsdossier_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Timestamp] [binary] (8) NULL,
[Dossiernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Datum] [date] NULL,
[Status] [varchar] (25) COLLATE Latin1_General_CI_AS NULL,
[Urgentie_id] [int] NULL,
[Afhandeling] [varchar] (15) COLLATE Latin1_General_CI_AS NULL,
[Meldernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Contactsoort] [varchar] (15) COLLATE Latin1_General_CI_AS NULL,
[Huurdernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Afgehandeld door] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Afgehandeld per] [date] NULL,
[Nummerreeks] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Uiterste datum] [date] NULL,
[Afwijzingsdatum] [date] NULL,
[Datum toestemming] [date] NULL,
[Clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Toegewezen aan] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Toegewezen aan Team] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Agressiesoort_id] [int] NULL,
[Veroorzaker] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Dossiertype_id] [int] NULL,
[Dossierstatus_id] [int] NULL,
[Controledatum] [date] NULL,
[Dossierafsluitreden_id] [int] NULL,
[Budget] [decimal] (12, 2) NULL,
[Juridische kosten] [varchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Deurwaarder] [varchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Open] [varchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Leefbaarheidsdossier_bedrijf_dossiernr] ON [Leefbaarheid].[Leefbaarheidsdossier] ([Bedrijf_id], [Dossiernr]) ON [PRIMARY]
GO
