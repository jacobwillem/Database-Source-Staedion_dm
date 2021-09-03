CREATE TABLE [Excel].[tmp_bik_2018]
(
[gemeente] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[complex naam] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Thuisteam] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[buurt] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Aantal woningen] [float] NULL,
[Teamscore] [float] NULL,
[Leefbaarometer] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Leefbaarometer BIK] [float] NULL,
[Woonoverlast] [float] NULL,
[Woonfraude] [float] NULL,
[Meldingen fraude en overlast BIK] [float] NULL,
[Klantmeting BIK] [float] NULL,
[BIK buurtscore] [float] NULL,
[BIK Complex] [float] NULL,
[Rang         (1-636)] [float] NULL
) ON [PRIMARY]
GO
