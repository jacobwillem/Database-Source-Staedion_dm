CREATE TABLE [Empire].[User]
(
[timestamp] [timestamp] NOT NULL,
[User Security ID] [uniqueidentifier] NOT NULL,
[User Name] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Full Name] [nvarchar] (80) COLLATE Latin1_General_CI_AS NOT NULL,
[State] [int] NOT NULL,
[Expiry Date] [datetime] NOT NULL,
[Windows Security ID] [nvarchar] (119) COLLATE Latin1_General_CI_AS NOT NULL,
[Change Password] [tinyint] NOT NULL,
[License Type] [int] NOT NULL,
[Authentication Email] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Contact Email] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Exchange Identifier] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Application ID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
