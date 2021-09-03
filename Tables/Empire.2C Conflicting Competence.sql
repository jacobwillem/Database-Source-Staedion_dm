CREATE TABLE [Empire].[2C Conflicting Competence]
(
[timestamp] [timestamp] NOT NULL,
[Competence] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Conflicts with] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[Internal Control Impact] [int] NOT NULL,
[Internal Control Risk] [nvarchar] (60) COLLATE Latin1_General_CI_AS NOT NULL,
[Conflict Reason] [int] NOT NULL,
[Company] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
