CREATE TABLE [Empire].[2C Secured Dataset Per Source]
(
[timestamp] [timestamp] NOT NULL,
[Source Type] [int] NOT NULL,
[Source No_] [nvarchar] (65) COLLATE Latin1_General_CI_AS NOT NULL,
[Company (Group)] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Table ID] [int] NOT NULL,
[Security Type] [int] NOT NULL,
[Line No_] [int] NOT NULL,
[Table Security No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Table Security Type] [int] NOT NULL,
[Filter Field 1] [int] NOT NULL,
[Filter 1] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Filter Field 2] [int] NOT NULL,
[Filter 2] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Filter And Or] [int] NOT NULL,
[DS_Insert Check] [tinyint] NOT NULL,
[DS_Modify Check Current Value] [tinyint] NOT NULL,
[DS_Modify Check New Value] [tinyint] NOT NULL,
[DS_Delete Check] [tinyint] NOT NULL,
[Filter 1 Value] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Filter 2 Value] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Source Scope] [int] NOT NULL,
[Source App ID] [uniqueidentifier] NOT NULL,
[Table Relation No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
