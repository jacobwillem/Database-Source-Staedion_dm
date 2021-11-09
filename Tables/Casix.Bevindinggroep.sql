CREATE TABLE [Casix].[Bevindinggroep]
(
[ID] [bigint] NULL,
[Aantal] [float] NULL,
[Naam] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Bevindinggroep_Werkopdracht] [bigint] NULL,
[Bevindinggroep_Specialismegroep] [bigint] NULL,
[Bevindinggroep_Bevindingtype] [bigint] NULL,
[changedDate] [datetime2] (0) NULL
) ON [PRIMARY]
GO
