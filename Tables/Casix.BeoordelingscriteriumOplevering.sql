CREATE TABLE [Casix].[BeoordelingscriteriumOplevering]
(
[ID] [bigint] NULL,
[Volgnr] [bigint] NULL,
[Naam] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[BeoordelingscriteriumOplevering_Verhuurder] [bigint] NULL,
[changedDate] [datetime2] (0) NULL,
[txt_ID] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
