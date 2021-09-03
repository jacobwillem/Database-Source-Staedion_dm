CREATE TABLE [Empire].[2C User Role per User Profile]
(
[timestamp] [timestamp] NOT NULL,
[User Profile] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[User Role ID] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Scope] [int] NOT NULL,
[App ID] [uniqueidentifier] NOT NULL,
[All Companies] [tinyint] NOT NULL,
[Sync Status] [int] NOT NULL,
[Starting Date] [datetime] NOT NULL,
[Ending Date] [datetime] NOT NULL
) ON [PRIMARY]
GO
