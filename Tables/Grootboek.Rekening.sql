CREATE TABLE [Grootboek].[Rekening]
(
[Rekening_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Rekeningnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Grootboekrekening] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Dimensiewaarde 1_id] [int] NULL,
[Dimensiewaarde 2_id] [int] NULL,
[Soort rekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Mutatiesoort] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Alternatief rekeningnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Geblokkeerd] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Direct boeken] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Reconciliatie rekening] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[Laatste wijziging] [datetime] NULL,
[Btwsoort_id] [int] NULL,
[Bedrijfsboekingsgroep_id] [int] NULL,
[Productboekingsgroep_id] [int] NULL,
[Btwproductboekingsgroep_id] [int] NULL,
[Comprimeren] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
