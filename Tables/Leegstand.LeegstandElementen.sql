CREATE TABLE [Leegstand].[LeegstandElementen]
(
[Leegstand_id] [int] NULL,
[Peildatum] [date] NULL,
[Bedrijf_id] [int] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Leegstandsperiode] [int] NULL,
[Ingangsdatum] [date] NULL,
[Elementnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Elementsoort] [int] NULL,
[Maandbedrag] [decimal] (12, 2) NULL,
[Derving] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
