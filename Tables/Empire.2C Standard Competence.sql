CREATE TABLE [Empire].[2C Standard Competence]
(
[timestamp] [timestamp] NOT NULL,
[Code] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [nvarchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[Type] [int] NOT NULL,
[Status] [int] NOT NULL,
[Process] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Sub Process] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Business Impact] [int] NOT NULL,
[Business Risk] [nvarchar] (60) COLLATE Latin1_General_CI_AS NOT NULL,
[Last Date Modified] [datetime] NOT NULL,
[Responsible] [nvarchar] (65) COLLATE Latin1_General_CI_AS NOT NULL,
[Check Method] [int] NOT NULL,
[Action by Agreeing Profile] [int] NOT NULL,
[Def_ Eval_ for Acc_ Finding] [int] NOT NULL
) ON [PRIMARY]
GO
