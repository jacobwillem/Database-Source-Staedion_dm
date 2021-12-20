CREATE TABLE [Elementen].[HuurkortingSamenvatting]
(
[Sleutel] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Eenheidnr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klantnr] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Klantnaam] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Elementnr] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[Elementnaam] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Adres] [nvarchar] (92) COLLATE Latin1_General_CI_AS NULL,
[Thuisteam] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Info verhuurmutatie geaggregeerd] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[Herzieningsdatum] [date] NULL,
[Info notitieveld contractregels geaggregeerd] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Elementen].[HuurkortingSamenvatting] ADD CONSTRAINT [PK__Huurkort__DCC0B3058584E54A] PRIMARY KEY CLUSTERED ([Sleutel]) ON [PRIMARY]
GO
