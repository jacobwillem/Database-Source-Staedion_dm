CREATE TABLE [Contact].[Leverancierbankrekening]
(
[Leverancierbankrekening_id] [int] NOT NULL IDENTITY(0, 1),
[Timestamp] [varbinary] (8) NULL,
[Ingangsdatum] [date] NULL,
[Einddatum] [date] NULL,
[Leveranciernr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Rekeningcode] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[IBAN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[SWIFT Code] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[G-rekening] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Rekeninghouder] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Rekeninghouder adres] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Rekeninghouder postcode] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Rekeninghouder plaats] [varchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Rekeninghouder land] [varchar] (10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Leverancier_rekening_einddatum] ON [Contact].[Leverancierbankrekening] ([Leveranciernr], [Rekeningcode], [Einddatum]) ON [PRIMARY]
GO
