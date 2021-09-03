CREATE TABLE [Empire].[Permission]
(
[timestamp] [timestamp] NOT NULL,
[Role ID] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Object Type] [int] NOT NULL,
[Object ID] [int] NOT NULL,
[Read Permission] [int] NOT NULL,
[Insert Permission] [int] NOT NULL,
[Modify Permission] [int] NOT NULL,
[Delete Permission] [int] NOT NULL,
[Execute Permission] [int] NOT NULL,
[Security Filter] [varbinary] (504) NOT NULL
) ON [PRIMARY]
GO
