CREATE TABLE [Empire].[Object]
(
[timestamp] [timestamp] NOT NULL,
[Type] [int] NOT NULL,
[Company Name] [varchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[ID] [int] NOT NULL,
[Name] [varchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Modified] [tinyint] NOT NULL,
[Compiled] [tinyint] NOT NULL,
[BLOB Reference] [image] NULL,
[BLOB Size] [int] NOT NULL,
[DBM Table No_] [int] NOT NULL,
[Date] [datetime] NOT NULL,
[Time] [datetime] NOT NULL,
[Version List] [varchar] (248) COLLATE Latin1_General_CI_AS NOT NULL,
[Locked] [tinyint] NOT NULL,
[Locked By] [varchar] (132) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
