CREATE TABLE [Onderhoud].[AfspraakduurOnderhoudsverzoek_Data]
(
[Jaar] [int] NULL,
[Weeknr] [int] NULL,
[Maand] [nvarchar] (4000) COLLATE Latin1_General_CI_AS NULL,
[Weekomschrijving] [nvarchar] (7) COLLATE Latin1_General_CI_AS NULL,
[Verzoek] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Verzoek - status] [varchar] (39) COLLATE Latin1_General_CI_AS NOT NULL,
[Order] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Verzoek - omschrijving] [nvarchar] (150) COLLATE Latin1_General_CI_AS NOT NULL,
[Verzoek - datum invoer] [datetime] NOT NULL,
[Order - afspraakdatum] [datetime] NULL,
[Duur in werkdagen: afspraak order - verzoek invoerdatum] [numeric] (13, 1) NULL
) ON [PRIMARY]
GO
