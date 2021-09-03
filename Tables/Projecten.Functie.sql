CREATE TABLE [Projecten].[Functie]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[bedrijf_id] [int] NULL,
[Functie] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Functie] ADD CONSTRAINT [PK_Functie] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[Functie] ADD CONSTRAINT [FK_Functie_Bedrijf] FOREIGN KEY ([bedrijf_id]) REFERENCES [Projecten].[Bedrijf] ([id])
GO
