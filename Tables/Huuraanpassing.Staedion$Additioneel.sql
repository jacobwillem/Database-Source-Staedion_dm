CREATE TABLE [Huuraanpassing].[Staedion$Additioneel]
(
[timestamp] [timestamp] NOT NULL,
[Customer No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Soort] [int] NOT NULL,
[Contractnr_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Ingangsdatum] [datetime] NOT NULL,
[Einddatum] [datetime] NOT NULL,
[Herzieningsdatum] [datetime] NOT NULL,
[Looptijd] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Optie] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Opzegtermijn] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[Bestemming] [nvarchar] (120) COLLATE Latin1_General_CI_AS NOT NULL,
[Gewijzigd op] [datetime] NOT NULL,
[Garantienr_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Garantiebedrag] [numeric] (38, 20) NOT NULL,
[Naam begunstigde] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Banknaam] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Adres] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Bankrekeningnr_] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Ingangsdatum garantie] [datetime] NOT NULL,
[Ontvangstdatum origineel] [datetime] NOT NULL,
[Locatie origineel] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Uitbetalingsdatum] [datetime] NOT NULL,
[Einddatum garantie] [datetime] NOT NULL,
[Beëindigingstekst] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Rechtsopvolging] [tinyint] NOT NULL,
[gen] [tinyint] NOT NULL,
[Mutatiedatum] [datetime] NOT NULL,
[Exploitatieplicht] [tinyint] NOT NULL,
[VvE-lidnr_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Functie] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Lening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Verpanding] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Juridisch] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Verhuurd] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Beslag] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Aandeel] [numeric] (38, 20) NOT NULL,
[Provisieperc_ verhuur] [numeric] (38, 20) NOT NULL,
[Provisieperc_ leegstand] [numeric] (38, 20) NOT NULL,
[Provisiebedrag] [numeric] (38, 20) NOT NULL,
[Min_ bedrag provisie] [numeric] (38, 20) NOT NULL,
[Max_ bedrag provisie] [numeric] (38, 20) NOT NULL,
[BTW-bedrijfsboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Bedrijfsboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Waarborgsom] [numeric] (38, 20) NOT NULL,
[Rente berekend tot] [datetime] NOT NULL,
[Rentecode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Expiratiedatum] [datetime] NOT NULL,
[No_ Series] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Due Date Message] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[DELETED Field 76] [tinyint] NOT NULL,
[Startdate 1st Rentalperiod Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[1st Rental Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[1st Rental Period Expound] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Enddate 1st Rental Period] [datetime] NOT NULL,
[Enddate 1st Rental Period Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice 1st Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice 1st Period Exp] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Notice Date 1st Period] [datetime] NOT NULL,
[Notice Date 1st Period Expound] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[2nd Rental Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[2nd Rental Period Expound] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Startdate 2nd Rentalperiod] [datetime] NOT NULL,
[Startdate 2nd Rentalperiod Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Enddate 2nd Rental Period] [datetime] NOT NULL,
[Enddate 2nd Rental Period Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice 2nd Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice 2nd Period Exp] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Notice Date 2nd Period] [datetime] NOT NULL,
[Notice Date 2nd Period Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[3rd Rental Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[3rd Rental Period Expound] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Startdate 3rd Rentalperiod] [datetime] NOT NULL,
[Startdate 3rd Rentalperiod Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Enddate 3rd Rental Period] [datetime] NOT NULL,
[Enddate 3rd Rental Period Exp] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice 3rd Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice 3rd Period Exp] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Notice Date 3rd Period] [datetime] NOT NULL,
[Notice Date 3rd Period Expound] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Prolongation] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice Prolongation] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[Term of Notice Prolong Expound] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Stuknr_ verrekende waarborgsom] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Invalid Contract] [tinyint] NOT NULL,
[Prolongation Period] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[DAEB rental for non-DAEB unit] [tinyint] NOT NULL,
[RentalContractType] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
