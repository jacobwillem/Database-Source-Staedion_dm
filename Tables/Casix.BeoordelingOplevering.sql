CREATE TABLE [Casix].[BeoordelingOplevering]
(
[ID] [bigint] NULL,
[Toelichting] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Afwerktermijn] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Waardering] [bigint] NULL,
[BeoordelingOplevering_Opname] [bigint] NULL,
[BeoordelingOplevering_BeoordelingscriteriumOplevering] [bigint] NULL,
[changedDate] [datetime2] (0) NULL
) ON [PRIMARY]
GO
