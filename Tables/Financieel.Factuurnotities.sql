CREATE TABLE [Financieel].[Factuurnotities]
(
[Bedrijf_id] [int] NULL,
[Factuurnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Notities] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
