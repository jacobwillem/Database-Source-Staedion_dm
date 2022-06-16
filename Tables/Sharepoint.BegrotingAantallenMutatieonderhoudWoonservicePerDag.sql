CREATE TABLE [Sharepoint].[BegrotingAantallenMutatieonderhoudWoonservicePerDag]
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
[Sleutel voor Power BI] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[datum] [date] NULL
) ON [PRIMARY]
GO
