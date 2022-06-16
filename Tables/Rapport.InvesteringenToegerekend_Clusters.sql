CREATE TABLE [Rapport].[InvesteringenToegerekend_Clusters]
(
[Bedrijf] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Rekening] [nvarchar] (71) COLLATE Latin1_General_CI_AS NULL,
[Empire projectnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Empire werksoort] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Empire Projecttype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Cluster] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Laatste omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Bedrag] [float] NULL,
[Clusterverdeelsleutels obv cluster] [numeric] (38, 20) NULL,
[Clusterverdeelsleutels obv cluster+project] [numeric] (38, 20) NULL,
[Opmerking1] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
