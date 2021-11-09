CREATE TABLE [Casix].[Onderhoudsverzoek]
(
[ID] [bigint] NULL,
[Aanleiding] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Onderhoudsverzoeknummer] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ExternID] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Externcode] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Onderhoudsverzoek_Huurcontract] [bigint] NULL,
[Onderhoudsverzoek_Project] [bigint] NULL,
[Onderhoudsverzoek_Verblijfsobject] [bigint] NULL,
[changedDate] [datetime2] (0) NULL
) ON [PRIMARY]
GO
