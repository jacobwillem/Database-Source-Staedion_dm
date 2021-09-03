CREATE TABLE [Contracten].[ActueleContractRegelsServiceAbonnementen TE VERWIJDEREN]
(
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Huurdernr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Volgnummer] [int] NOT NULL,
[Elementnr] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Bedrag] [numeric] (38, 20) NOT NULL,
[Eenmalig] [tinyint] NOT NULL,
[Afwijking standaardprijs] [varchar] (9) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ActueleContractRegelsServiceAbonnementen_Elementnr] ON [Contracten].[ActueleContractRegelsServiceAbonnementen TE VERWIJDEREN] ([Elementnr]) INCLUDE ([Bedrag], [Eenheidnr], [Eenmalig], [Volgnummer]) ON [PRIMARY]
GO
