CREATE TABLE [Casix].[Bevindingtype]
(
[ID] [bigint] NULL,
[Bevindingtype Omschrijving] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[BevindingtypeID] [bigint] NULL,
[ExternID] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Bevindingtype__Eenheid] [bigint] NULL,
[Bevindingtype_Onderhoudssjabloon] [bigint] NULL,
[Bevindingtypecode] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[changedDate] [datetime2] (0) NULL
) ON [PRIMARY]
GO
