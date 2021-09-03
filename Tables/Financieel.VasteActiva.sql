CREATE TABLE [Financieel].[VasteActiva]
(
[Nr.] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Zoeknaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[VA-categorie] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Code globale dimensie 1] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Code globale dimensie 1 - TE CORRIGEREN] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Hoofdactivum/Onderdeel] [varchar] (12) COLLATE Latin1_General_CI_AS NULL,
[Onderdeel van] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Alleen budget] [varchar] (6) COLLATE Latin1_General_CI_AS NULL,
[Gewijzigd op] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Geblokkeerd] [varchar] (6) COLLATE Latin1_General_CI_AS NULL,
[In onderhoud] [varchar] (6) COLLATE Latin1_General_CI_AS NULL,
[Inactief] [varchar] (6) COLLATE Latin1_General_CI_AS NULL,
[VA-boekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr te corrigeren - TE CORRIGEREN] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Bevestiging] [varchar] (6) COLLATE Latin1_General_CI_AS NULL,
[administratief eigenaar] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[exploitatiestatus] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[datum in exploitatie] [datetime] NULL,
[reden in exploitatie] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[datum uit exploitatie] [datetime] NULL,
[reden uit exploitatie] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Aanschafkosten voorafgaand aan periode] [numeric] (12, 2) NULL,
[Toevoeging in periode] [numeric] (12, 2) NULL,
[Buitengebruikstelling in periode] [numeric] (12, 2) NULL,
[Aanschafkosten peildatum] [numeric] (12, 2) NULL,
[Afschrijving voorafgaand aan periode] [numeric] (12, 2) NULL,
[Afschrijving in periode] [numeric] (12, 2) NULL,
[Buitengebruikstelling afschrijving in periode] [numeric] (12, 2) NULL,
[Afschrijving peildatum] [numeric] (12, 2) NULL,
[Boekwaarde voorafgaand aan periode] [numeric] (12, 2) NULL,
[Boekwaarde peildatum] [numeric] (12, 2) NULL,
[Rente in periode] [numeric] (12, 2) NULL,
[fk_eenheid_id] [int] NULL,
[Buiten gebruik gesteld] [nvarchar] (47) COLLATE Latin1_General_CI_AS NULL,
[fk_vastactivum_id] [int] NULL,
[BGSdatum] [datetime] NULL,
[Afschrijvingsboek] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[VA-boekingsgroep (5612)] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Boekwaarde peildatum test] [numeric] (12, 2) NULL,
[gegenereerd] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[Boekjaar] [smallint] NULL
) ON [PRIMARY]
GO
