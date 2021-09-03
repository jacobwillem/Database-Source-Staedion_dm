CREATE TABLE [Grootboek].[Dimensiesets]
(
[Dimensieset_id] [int] NOT NULL IDENTITY(0, 1),
[Bedrijf_id] [int] NULL,
[Dimension Set ID] [int] NULL,
[Dimensiewaarde 1_id] [int] NULL,
[Dimensiewaarde 2_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Dimensiesets_01] ON [Grootboek].[Dimensiesets] ([Dimensieset_id]) ON [PRIMARY]
GO
