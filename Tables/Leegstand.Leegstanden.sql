CREATE TABLE [Leegstand].[Leegstanden]
(
[Leegstand_id] [int] NULL,
[Peildatum] [date] NULL,
[Bedrijf_id] [int] NULL,
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Volgnr_] [int] NULL,
[Vorige huurder] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Leegstandsperiode] [int] NULL,
[Boekingsgroep] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[Ingangsdatum] [date] NULL,
[Einddatum] [date] NULL,
[Dagen] [int] NULL,
[Dagen boekingsgroep tm] [int] NULL,
[Dagen totaal tm] [int] NULL,
[Derving netto] [decimal] (12, 2) NULL,
[Derving netto boekingsgroep tm] [decimal] (12, 2) NULL,
[Derving netto totaal tm] [decimal] (12, 2) NULL,
[Derving bruto] [decimal] (12, 2) NULL,
[Derving bruto boekingsgroep tm] [decimal] (12, 2) NULL,
[Derving bruto totaal tm] [decimal] (12, 2) NULL,
[Laatste in maand] [tinyint] NULL,
[Laatste in periode] [tinyint] NULL,
[Meetwaarden_id] [int] NULL,
[Leegstandsduur] AS (case  when [Dagen totaal tm]<(31) then '< 1 maand' else case  when [Dagen totaal tm]<(61) then '1 tot 2 maanden' else case  when [Dagen totaal tm]<(61) then '1 tot 2 maanden' else case  when [Dagen totaal tm]<(91) then '2 tot 3 maanden' else case  when [Dagen totaal tm]<(365) then '3 tot 12 maanden' else '> dan 12 maanden' end end end end end),
[Volgende eenheidstatus] [int] NULL
) ON [PRIMARY]
GO
