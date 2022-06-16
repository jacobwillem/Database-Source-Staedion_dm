CREATE TABLE [Rapport].[InvesteringenToegerekend_Clusterverdeelsleutels]
(
[Cluster No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Project No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Distribution Key Type] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Start Date] [datetime] NOT NULL,
[End Date] [datetime] NOT NULL,
[Status] [int] NOT NULL,
[Version No_] [int] NOT NULL,
[Budget Line No_] [int] NOT NULL,
[Realty Unit No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Numerator] [numeric] (38, 20) NOT NULL,
[Volgnr] [bigint] NULL
) ON [PRIMARY]
GO
