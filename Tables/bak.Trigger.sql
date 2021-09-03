CREATE TABLE [bak].[Trigger]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NOT NULL,
[Naam] [nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
[Norm] [numeric] (12, 4) NULL,
[Laatste] [datetime] NULL,
[maxOuderdom] [int] NOT NULL,
[Melding] [ntext] COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
