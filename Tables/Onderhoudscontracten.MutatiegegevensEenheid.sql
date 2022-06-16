CREATE TABLE [Onderhoudscontracten].[MutatiegegevensEenheid]
(
[MutatiegegevensEenheid_id] [int] NOT NULL IDENTITY(1, 1),
[Volgnummer] [int] NOT NULL,
[MDB regelnr] [int] NOT NULL,
[Regelnr] [int] NOT NULL,
[Geldig van] [date] NULL,
[Geldig tot] [date] NULL,
[Verwijderd] [bit] NULL,
[Huidig record] [bit] NULL,
[Bedrijf_id] [int] NULL,
[Timestamp] [binary] (8) NULL,
[Onderhoudscontractnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Prolongeren] [bit] NULL,
[Collectief object_id] [int] NULL,
[Eigenschappen_id] [int] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Collectief object] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
