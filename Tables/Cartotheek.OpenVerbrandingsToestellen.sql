CREATE TABLE [Cartotheek].[OpenVerbrandingsToestellen]
(
[Sleutel] [varchar] (24) COLLATE Latin1_General_CI_AS NULL,
[Corpodatatype] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Eenheid] [varchar] (128) COLLATE Latin1_General_CI_AS NULL,
[Eenheidnr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Datum] [datetime] NOT NULL,
[Cartotheek-item] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Cartotheek-item-omschrijving] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Categorie OVT] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[aanwezig] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[status eenheidskaart] [varchar] (39) COLLATE Latin1_General_CI_AS NULL,
[Bouwjaar] [int] NULL,
[Exploitatiestatus] [varchar] (30) COLLATE Latin1_General_CI_AS NULL,
[rekenregel] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Clusternr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Hyperlink Empire] [varchar] (1035) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
