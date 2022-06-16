CREATE TABLE [RekeningCourant].[StornoCode]
(
[Storno code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Storno omschrijving] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Stornocode en omschrijving] [nvarchar] (122) COLLATE Latin1_General_CI_AS NULL,
[Telt mee als storno] [bit] NULL
) ON [PRIMARY]
GO
