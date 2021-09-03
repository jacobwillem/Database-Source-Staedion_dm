CREATE TABLE [Eenheden].[Reden afwijkende WOZ]
(
[Reden afwijkende WOZ id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Reden afwijkende WOZ] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
