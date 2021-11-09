CREATE TABLE [Casix].[Verblijfsobject]
(
[ID] [bigint] NULL,
[AdresVolledig] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ExternID] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Objecttype] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[VerblijfsobjectID] [bigint] NULL,
[Verblijfsobjectcode] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Postcode] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Huisnummer] [bigint] NULL,
[HuisnummerEinde] [bigint] NULL,
[HuisnummerToevoeging] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Locatieaanduiding] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Straat] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Plaats] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Land] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[Bestemming] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[DatumBestemming] [datetime2] (0) NULL,
[Verblijfsobject_Cluster] [bigint] NULL,
[changedDate] [datetime2] (0) NULL
) ON [PRIMARY]
GO
