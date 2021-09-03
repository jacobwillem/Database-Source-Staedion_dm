CREATE TABLE [Empire].[2C User Role]
(
[timestamp] [timestamp] NOT NULL,
[Scope] [int] NOT NULL,
[App ID] [uniqueidentifier] NOT NULL,
[Role ID] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Status] [int] NOT NULL
) ON [PRIMARY]
GO
