CREATE TABLE [Huuraanpassing].[Staedion$Capping Limit per Target Grp_]
(
[timestamp] [timestamp] NOT NULL,
[Starting Date] [datetime] NOT NULL,
[Target Group Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Limit Amount] [numeric] (38, 20) NOT NULL,
[SubsidyServiceAmountIncluded] [tinyint] NOT NULL
) ON [PRIMARY]
GO
