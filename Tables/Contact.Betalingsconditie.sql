CREATE TABLE [Contact].[Betalingsconditie]
(
[Betalingsconditie_id] [int] NOT NULL IDENTITY(0, 1),
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Betalingsconditie] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
