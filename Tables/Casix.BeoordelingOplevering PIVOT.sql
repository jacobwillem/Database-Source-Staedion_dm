CREATE TABLE [Casix].[BeoordelingOplevering PIVOT]
(
[BeoordelingOplevering_Opname] [bigint] NULL,
[Kwaliteit] [float] NULL,
[Oplevering] [float] NULL,
[Communicatie] [float] NULL,
[Doorlooptijd] [float] NULL,
[Toelichting kwaliteit] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Toelichting oplevering] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Toelichting doorlooptijd] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Toelichting communicatie] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
