CREATE TABLE [Huuraanpassing].[staedion$OGE Rent Sum]
(
[timestamp] [timestamp] NOT NULL,
[Rent Sum Period Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Realty Object No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Counts For Rent Sum] [tinyint] NOT NULL,
[Starting Contract Entry No_] [int] NOT NULL,
[Starting Contract Type] [int] NOT NULL,
[Ending Contract Entry No_] [int] NOT NULL,
[Ending Contract Type] [int] NOT NULL,
[Rent Sum Period Description] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Rent Sum Period Starting Date] [datetime] NOT NULL,
[Begin of Period Net Rent] [numeric] (38, 20) NOT NULL,
[End of Period Net Rent] [numeric] (38, 20) NOT NULL,
[Net Rent Increase] [numeric] (38, 20) NOT NULL,
[Net Rent Increase Percentage] [numeric] (38, 20) NOT NULL,
[Creation Date-Time] [datetime] NOT NULL,
[Rent Increase Period Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Maximum Basic Increase Perc_] [numeric] (38, 20) NOT NULL,
[Effective Rent Increase Perc_] [numeric] (38, 20) NOT NULL,
[To be deleted 120] [int] NOT NULL,
[Justify as House] [int] NOT NULL,
[Performance Agreement Made] [tinyint] NOT NULL,
[Municipality Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Municipality Name] [nvarchar] (250) COLLATE Latin1_General_CI_AS NOT NULL,
[Meets Basic Conditions] [tinyint] NOT NULL,
[Living Space] [int] NOT NULL
) ON [PRIMARY]
GO
