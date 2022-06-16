CREATE TABLE [Rapport].[InvesteringenToegerekend_Eenheid]
(
[Bedrijf] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Adres] [nvarchar] (70) COLLATE Latin1_General_CI_AS NULL,
[Technisch Type] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Administratief eigenaar] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Datum uit exploitatie] [date] NULL,
[Projectnrs] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[FT cluster] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[A021300 investeringen vastgoed verbeteringen] [float] NULL,
[A021302 Investeringen duurzaamheid zonnepanelen] [float] NULL,
[A021304 Investeringen duurzaamheid aardgasloos] [float] NULL,
[A021306 Investeringen achterstallig onderhoud] [float] NULL,
[A021308 Investeringen energetische verbeteringen] [float] NULL
) ON [PRIMARY]
GO
