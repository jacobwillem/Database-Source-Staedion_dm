CREATE TABLE [Sharepoint].[NormenPlanningsEfficiencyPerVakgroep]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Vakgroep] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Volgorde] [smallint] NULL,
[week -1 (>)] [decimal] (4, 2) NULL,
[week -1 (<)] [decimal] (4, 2) NULL,
[week 1 (>)] [decimal] (4, 2) NULL,
[week 1 (<)] [decimal] (4, 2) NULL,
[week 2 (>)] [decimal] (4, 2) NULL,
[week 2 (<)] [decimal] (4, 2) NULL,
[week 3 (>)] [decimal] (4, 2) NULL,
[week 3 (<)] [decimal] (4, 2) NULL,
[Opmerking] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
