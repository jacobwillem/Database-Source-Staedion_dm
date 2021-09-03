CREATE TABLE [Projecten].[Bedrijf]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Bedrijf] ADD CONSTRAINT [PK_Bedrijf] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
