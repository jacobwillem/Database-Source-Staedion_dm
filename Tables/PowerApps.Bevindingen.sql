CREATE TABLE [PowerApps].[Bevindingen]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Sleutel] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Gebruiker] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Tijdstip] [datetime] NULL,
[Onderwerp] [nvarchar] (40) COLLATE Latin1_General_CI_AS NULL,
[Opmerking] [nvarchar] (510) COLLATE Latin1_General_CI_AS NULL,
[Prioriteit] [bit] NULL,
[Voorlopige einddatum] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [PowerApps].[Bevindingen] ADD CONSTRAINT [PK__Bevindin__3214EC2771176F31] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [i1_Bevindingen] ON [PowerApps].[Bevindingen] ([Sleutel]) ON [PRIMARY]
GO
