CREATE TABLE [bak].[vw_DimensieJoin]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[fk_indicator_id] [int] NULL,
[Clusternummer] [varchar] (7) COLLATE Latin1_General_CI_AS NULL,
[Dimensie.naam] [varchar] (9) COLLATE Latin1_General_CI_AS NOT NULL,
[Dimensie.id] [varchar] (22) COLLATE Latin1_General_CI_AS NOT NULL,
[Datum] [date] NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
