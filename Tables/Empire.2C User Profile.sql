CREATE TABLE [Empire].[2C User Profile]
(
[timestamp] [timestamp] NOT NULL,
[User Profile] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Status] [int] NOT NULL,
[Last Date Modified] [datetime] NOT NULL,
[Responsible] [nvarchar] (65) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
