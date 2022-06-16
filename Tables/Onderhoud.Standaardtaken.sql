CREATE TABLE [Onderhoud].[Standaardtaken]
(
[Standaardtaak_id] [int] NOT NULL IDENTITY(1, 1),
[Bedrijf_id] [int] NULL,
[Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Standaardtaak] [nvarchar] (150) COLLATE Latin1_General_CI_AS NULL,
[Bouwelement] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Onderdeel] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Meeteenheid] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Bekwaamheid] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Voorcalculatorische prijs eigen dienst] [decimal] (12, 2) NULL,
[Voorcalculatorische inkoopprijs] [decimal] (12, 2) NULL,
[Standaard duur] [decimal] (12, 4) NULL,
[Aantal resources] [int] NULL,
[Taakgroep] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Verbergen voor vakman] [char] (3) COLLATE Latin1_General_CI_AS NULL,
[Activiteit] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Inkoopprijs wijzigbaar] [char] (3) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
