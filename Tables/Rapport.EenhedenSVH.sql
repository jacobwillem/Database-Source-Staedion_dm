CREATE TABLE [Rapport].[EenhedenSVH]
(
[eenheidnr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[straat] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[huisnummer] [int] NOT NULL,
[toevoegsel] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Juridisch eigenaar] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[clusternummer] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[clusternaam] [varchar] (71) COLLATE Latin1_General_CI_AS NOT NULL,
[corpodata_type] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[datum_in_exploitatie] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[datum_uit_exploitatie] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[In Exploitatie] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Begindatum juridisch eigenaar] [date] NULL,
[Einddatum juridisch eigenaar] [date] NULL,
[Begindatum juridisch eigenaar ELS] [date] NULL,
[Einddatum juridisch eigenaar ELS] [date] NULL,
[Saldo_Huur_Binnen_Periode] [decimal] (12, 2) NULL,
[Saldo_Overig_Binnen_Periode] [decimal] (12, 2) NULL,
[Saldo_Buiten_Periode] [decimal] (12, 2) NULL,
[Aanvullende opmerking 1] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Classificatie] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [varchar] (25) COLLATE Latin1_General_CI_AS NOT NULL,
[Betreft] [varchar] (38) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
