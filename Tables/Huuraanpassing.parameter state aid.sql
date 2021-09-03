CREATE TABLE [Huuraanpassing].[parameter state aid]
(
[timestamp] [timestamp] NOT NULL,
[Start Date] [datetime] NOT NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[End Date] [datetime] NOT NULL,
[Descr_ Income Limit] [nvarchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[Income Limit Low] [numeric] (38, 20) NOT NULL,
[Income Limit High] [numeric] (38, 20) NOT NULL,
[Liberalisation Limit] [numeric] (38, 20) NOT NULL
) ON [PRIMARY]
GO
