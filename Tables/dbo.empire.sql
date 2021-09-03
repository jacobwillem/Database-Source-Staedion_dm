CREATE TABLE [dbo].[empire]
(
[No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Description Set ID] [int] NOT NULL,
[Creation Date] [datetime] NULL,
[Created By] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Created From] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[OpmerkingBlob] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Origin] [nvarchar] (250) COLLATE Latin1_General_CI_AS NULL,
[Laaddatum] [datetime] NULL
) ON [PRIMARY]
GO
