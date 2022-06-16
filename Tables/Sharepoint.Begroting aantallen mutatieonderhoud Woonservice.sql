CREATE TABLE [Sharepoint].[Begroting aantallen mutatieonderhoud Woonservice]
(
[Rekeningnr] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[kostenplaats] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[hoofdonderwerp] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[subonderwerp] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[jaartal] [float] NULL,
[aantal] [float] NULL,
[standaardprijs] [float] NULL,
[budget] [float] NULL,
[opmerking] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ID] [bigint] NULL,
[Sleutel voor Power BI] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
