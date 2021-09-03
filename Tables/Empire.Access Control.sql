CREATE TABLE [Empire].[Access Control]
(
[timestamp] [timestamp] NOT NULL,
[User Security ID] [uniqueidentifier] NOT NULL,
[Role ID] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Company Name] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Scope] [int] NOT NULL,
[App ID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
