CREATE TABLE [Eenheden].[Huurklasse]
(
[Huurklasse_id] [int] NULL,
[Omschrijving] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving huurprijsklasse] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving huurprijsklasse grensbedrag] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Omschrijving groep 1] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Sorteersleutel groep 1] [smallint] NULL,
[Geliberaliseerd] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[Minimum] [numeric] (12, 2) NULL,
[Maximum] [numeric] (12, 2) NULL,
[Ingangsdatum] [date] NULL,
[Einddatum] [date] NULL,
[BBSH jaardatum] [date] NULL,
[BBSH jaartal] [int] NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Jaco 15-09-2021
Eenmalig gevuld vanuit empire_dwh. Te gebruiken in datamart Eenheden. 
Jaarlijks vullen is een handmatige actie. Wellicht ook id incremental maken ?
Opzet zodanig dat bestaande rapporten gebruik kunnen gaan maken van deze tabel ipv huidige view 
staedion_dm.Algemeen.[Eenheid BBSH]

insert into Eenheden.Huurklasse (Huurklasse_id, Omschrijving, [Omschrijving huurprijsklasse], [Omschrijving huurprijsklasse grensbedrag],[Minimum], [Maximum],[Omschrijving groep 1],[Sorteersleutel groep 1], Geliberaliseerd, Ingangsdatum, Einddatum, [BBSH jaardatum], [BBSH jaartal])
 select 
      id
      ,[omschrijving]
      ,[huurprijsklasse_std_descr]
      ,[huurprijsklasse_std_bedrag_descr]
      ,[Minimum]
      ,[Maximum]
	  ,groep1_descr
	  ,groep1_key
	  ,case when geliberaliseerd = ''Geliberaliseerd''then ''Ja'' else ''Nee'' end
      ,vanaf
      ,tot
      ,convert(date,convert(varchar,YEAR(vanaf))+''01''+''01'')
  ,year(convert(date,convert(varchar,YEAR(vanaf))+''01''+''01''))
from [empire_dwh].[dbo].[bbshklasse]', 'SCHEMA', N'Eenheden', 'TABLE', N'Huurklasse', NULL, NULL
GO
