CREATE TABLE [Klanttevredenheid].[KpiScoresDetailsVanaf2020]
(
[KCM onderzoek] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[KCM vraag] [varchar] (500) COLLATE Latin1_General_CI_AS NULL,
[Indicator Staedion] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Datum ingevuld] [datetime] NULL,
[KCM vraagnummer intern] [int] NULL,
[KCM vraagdefinitie intern] [int] NULL,
[KCM vraagtypedefinitie intern] [smallint] NULL,
[KCM antwoord] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[KCM resultaat] [smallint] NULL,
[Bron] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
