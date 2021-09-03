CREATE TABLE [Huuraanpassing].[Staedion$Type]
(
[timestamp] [timestamp] NOT NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Omschrijving] [nvarchar] (70) COLLATE Latin1_General_CI_AS NOT NULL,
[Soort] [int] NOT NULL,
[Markthuurwaarde (LV)] [numeric] (38, 20) NOT NULL,
[Soort woning] [int] NOT NULL,
[Alt_ omschrijving 1] [nvarchar] (70) COLLATE Latin1_General_CI_AS NOT NULL,
[Alt_ omschrijving 2] [nvarchar] (70) COLLATE Latin1_General_CI_AS NOT NULL,
[Analysis Group Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[No_ of Pre Intakes] [int] NOT NULL,
[No_ of Final Intakes] [int] NOT NULL,
[Duration Pre Intake] [bigint] NOT NULL,
[Duration Final Intake] [bigint] NOT NULL,
[Decision Tree Type Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Term First Inspection] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[To be deleted 11151950] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[To be deleted 11151952] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
