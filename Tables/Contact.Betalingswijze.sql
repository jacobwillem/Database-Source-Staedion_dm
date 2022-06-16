CREATE TABLE [Contact].[Betalingswijze]
(
[Betalingswijze_id] [int] NOT NULL IDENTITY(0, 1),
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Betalingswijze] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Tegenrekeningsoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Tegenrekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Incasso] [char] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
