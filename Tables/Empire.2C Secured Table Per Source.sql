CREATE TABLE [Empire].[2C Secured Table Per Source]
(
[timestamp] [timestamp] NOT NULL,
[Source Type] [int] NOT NULL,
[Source No_] [nvarchar] (65) COLLATE Latin1_General_CI_AS NOT NULL,
[Company (Group)] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Table ID] [int] NOT NULL,
[Security Type] [int] NOT NULL,
[Filter Field No_] [int] NOT NULL,
[Internal Filter Value] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Default Editable] [tinyint] NOT NULL,
[Table Security No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Table Security Type] [int] NOT NULL,
[Full Access] [tinyint] NOT NULL,
[Filter Field Name] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Filter Field Caption] [nvarchar] (80) COLLATE Latin1_General_CI_AS NOT NULL,
[Filter Value] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
