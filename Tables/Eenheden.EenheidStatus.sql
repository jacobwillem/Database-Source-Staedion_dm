CREATE TABLE [Eenheden].[EenheidStatus]
(
[Eenheidstatus_id] [int] NOT NULL,
[EenheidStatus] [varchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [EenheidStatus01] ON [Eenheden].[EenheidStatus] ([Eenheidstatus_id]) ON [PRIMARY]
GO
