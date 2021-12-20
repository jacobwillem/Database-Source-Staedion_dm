CREATE TABLE [Elementen].[HuurkortingDetails]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Sleutel] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Grootboekrekening] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Eenheidnr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klantnr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Elementnr] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Stuknummer] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Boekdatum] [date] NULL,
[Bedrag] [decimal] (8, 2) NULL,
[Volgnummer] [int] NULL,
[Info notitieveld contractregels] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[Info verhuurmutatie] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL,
[Gebruiker] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Elementen].[HuurkortingDetails] ADD CONSTRAINT [PK__Huurkort__3214EC27C8E725E2] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [i1_HuurkortingDetails] ON [Elementen].[HuurkortingDetails] ([Sleutel]) ON [PRIMARY]
GO
ALTER TABLE [Elementen].[HuurkortingDetails] ADD CONSTRAINT [FK__Huurkorti__Sleut__35C8B659] FOREIGN KEY ([Sleutel]) REFERENCES [Elementen].[HuurkortingSamenvatting] ([Sleutel]) ON DELETE CASCADE
GO
