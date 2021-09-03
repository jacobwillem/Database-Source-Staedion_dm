CREATE TABLE [Empire].[2C User per User Profile]
(
[timestamp] [timestamp] NOT NULL,
[User Security ID] [uniqueidentifier] NOT NULL,
[User SID] [nvarchar] (119) COLLATE Latin1_General_CI_AS NOT NULL,
[User Profile] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Company (Group)] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Starting Date] [datetime] NOT NULL,
[Sync Status] [int] NOT NULL,
[User Name] [nvarchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[Ending Date] [datetime] NOT NULL,
[Save after Ending Date] [tinyint] NOT NULL
) ON [PRIMARY]
GO
