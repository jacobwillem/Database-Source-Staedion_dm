CREATE TABLE [Sharepoint].[AantallenStartBouwOplevering]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Title] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Pad] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Jaar] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[StartOplevering] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Norm] [int] NULL,
[Jan] [float] NULL,
[Feb] [float] NULL,
[Mrt] [float] NULL,
[Apr] [float] NULL,
[Mei] [float] NULL,
[Jun] [float] NULL,
[Jul] [float] NULL,
[Aug] [float] NULL,
[Sept] [float] NULL,
[Okt] [float] NULL,
[Nov] [float] NULL,
[Dec] [float] NULL,
[Totaal] [float] NULL,
[GemaaktDoor] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[GewijzigdDoor] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Projectmanager] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[TypeProject] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[TijdstipGenereren] [datetime] NULL,
[Peildatum] [date] NULL,
[Gemaakt] [datetimeoffset] NULL,
[Gewijzigd] [datetimeoffset] NULL,
[FT-cluster] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Projectnummer] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Sharepoint].[AantallenStartBouwOplevering] ADD CONSTRAINT [PK_AantallenStartBouwOplevering] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'TOELICHTING OP RELEVANTE DATABASE OBJECTEN = 
* Tabel staedion_dm.Sharepoint.AantallenStartBouwOplevering
BRON: Microsoft list (https://staedionict.sharepoint.com/sites/onderhoud-vastgoed/afdelingprojecten/Lists/Aantallen Start Bouw%20 Oplevering)
* Stored procedure [Sharepoint].[sp_AantallenStartBouwOplevering] (@Peildatum)
Via power automate wordt standaard (default @Peildatum is null) een snapshot gevuld met einddatum van vorige maand
tot aan dinsdag 2de week van de maand. Daarna wordt snapshot verschoven naar huidige maand.
Stel dat data van een paar maanden geleden niet klopt. Dan kan eenmalig deze procedure gedraaid worden met @Peildatum = datum in verleden.
Dan direct daarna PowerAutomate uitvoeren. Dan zou de gekozen peildatum vervangen moeten worden in onderliggende tabel met actuele gegevens van de tabel.
* Functie [Projecten].[fn_AantallenOnderhandenWerkMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en groepeert de start- en oplever-aantallen per project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum
* Functie [Projecten].[fn_AantallenProjectenMicrosoftList] (@Peildatum)
Haalt meest actuele snapshot op en en haalt start- en oplever-aantallen op project+jaar. 
Zet de kolommen jaar-jan-dec om naar rijen met peildatum.
* Stored procedure [Dashboard].[sp_load_kpi_projecten_onderhanden_werk]
Vult adhv functie fn_AantallenOnderhandenWerkMicrosoftList het kpi-framework incl prognoses voor resterende maanden
* Stored procedure [Dashboard].[sp_load_kpis_projecten]
Vult adhv functie fn_AantallenProjectenMicrosoftList het kpi-framework voor meerdere kps incl prognoses voor resterende maanden
* ETL: PowerAutomate.Microsoft List - StartBouwAantallen', 'SCHEMA', N'Sharepoint', 'TABLE', N'AantallenStartBouwOplevering', NULL, NULL
GO
