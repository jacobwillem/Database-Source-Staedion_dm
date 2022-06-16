CREATE TABLE [Onderhoudscontracten].[WijzigingslogboekMutatiegegevensEenheid]
(
[Wijziging_id] [int] NOT NULL IDENTITY(1, 1),
[Onderhoudscontractnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Volgnummer] [int] NULL,
[MDB Regelnr] [int] NULL,
[Regelnr] [int] NULL,
[Primary Key] [nvarchar] (250) COLLATE Latin1_General_CI_AS NULL,
[Actuele waarde Prolongeren] [bit] NULL,
[Prolongatie aangezet] [datetime] NULL,
[Prolongatie uitgezet] [datetime] NULL,
[Prolongatie aangezet door] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Prolongatie uitgezet door] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[EenheidOfCollectiefnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
