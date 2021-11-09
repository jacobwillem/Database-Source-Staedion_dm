CREATE TABLE [Algemeen].[Bedrijven]
(
[Bedrijf_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Algemeen].[Bedrijven] ADD CONSTRAINT [PK_Bedrijven] PRIMARY KEY CLUSTERED ([Bedrijf_id]) ON [PRIMARY]
GO
