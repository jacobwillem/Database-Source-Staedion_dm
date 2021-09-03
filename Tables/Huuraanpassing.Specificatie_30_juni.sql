CREATE TABLE [Huuraanpassing].[Specificatie_30_juni]
(
[Peildatum] [date] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Volgnummer] [int] NULL,
[Ingangsdatum contractregel] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Einddatum contractregel] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Huurdernaam] [nvarchar] (250) COLLATE Latin1_General_CI_AS NULL,
[Elementnr] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[ElementNaam] [nvarchar] (61) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving element] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Bedrag] [numeric] (38, 20) NULL,
[Bedrag niet afgerond] [numeric] (38, 20) NULL,
[Bedrag incl. BTW] [numeric] (38, 6) NULL,
[BTW-productboekingsgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Status ogekaart] [nvarchar] (15) COLLATE Latin1_General_CI_AS NULL,
[Op huurverhoging afdrukken] [tinyint] NULL,
[Eenmalig] [tinyint] NULL
) ON [PRIMARY]
GO
