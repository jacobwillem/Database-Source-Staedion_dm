CREATE TABLE [Contact].[Transactiewijze]
(
[Transactiewijze_id] [int] NOT NULL IDENTITY(0, 1),
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Transactiewijze] [nvarchar] (80) COLLATE Latin1_General_CI_AS NULL,
[Rekeningsoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Opdrachtsoort] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
