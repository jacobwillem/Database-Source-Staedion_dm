CREATE TABLE [Eenheden].[Kernvoorraad]
(
[Opmerking] [varchar] (55) COLLATE Latin1_General_CI_AS NOT NULL,
[Kernvoorraad] [int] NOT NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Netto huur] [decimal] (12, 2) NULL,
[Streefhuur] [decimal] (12, 2) NULL,
[Plaats] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Gemeente] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Corpodatatype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Geliberaliseerd contract] [varchar] (3) COLLATE Latin1_General_CI_AS NOT NULL,
[Jaar contract] [int] NULL,
[Doelgroepcode] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Verhuurteam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Huurprijsklasse corpodata] [varchar] (52) COLLATE Latin1_General_CI_AS NULL,
[Peildatum] [datetime] NULL,
[Sleutel huurklasse] [int] NULL
) ON [PRIMARY]
GO
