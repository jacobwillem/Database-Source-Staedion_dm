CREATE TABLE [TMS].[MarktwaardeHistorie]
(
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Peildatum] [date] NULL,
[Netto marktwaarde] [decimal] (12, 2) NULL,
[Leegwaarde] [decimal] (12, 2) NULL,
[Markthuur per maand] [decimal] (12, 2) NULL,
[Beleidswaarde] [decimal] (12, 2) NULL,
[Scenario] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [i1_marktwaardehistorie] ON [TMS].[MarktwaardeHistorie] ([Eenheidnr]) ON [PRIMARY]
GO
