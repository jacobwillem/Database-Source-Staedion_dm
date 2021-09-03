CREATE TABLE [Parameters].[HuurgrenzenLiberalisatie]
(
[geliberaliseerd] [varchar] (16) COLLATE Latin1_General_CI_AS NULL,
[minimum] [numeric] (12, 2) NULL,
[maximum] [numeric] (12, 2) NULL,
[vanaf] [datetime] NULL,
[tot] [datetime] NULL,
[opmerking] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Parameters', 'TABLE', N'HuurgrenzenLiberalisatie', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Parameters', 'TABLE', N'HuurgrenzenLiberalisatie', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tabel met de grenzen door de liberalisatie
https://jnwadvocaten.nl/artikelen/geliberaliseerde-huur-wanneer-is-een-aanbod-redelijk/
https://www.rijksoverheid.nl/onderwerpen/woning-huren/vraag-en-antwoord/woon-ik-in-een-sociale-huurwoning-of-niet
https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/toeslagen/huurtoeslag/uw-inkomen-is-niet-te-hoog-voor-de-huurtoeslag/
', 'SCHEMA', N'Parameters', 'TABLE', N'HuurgrenzenLiberalisatie', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'
select min(vanaf), max(tot), datediff(d,min(vanaf), max(tot)),sum(datediff(d,vanaf,tot)+1) -- check of er dubbele dagen in zitten of dagen ontbreken
	   FROM staedion_dm.[Parameters].HuurgrenzenLiberalisatie
	   where tot <> ''20991231''

', 'SCHEMA', N'Parameters', 'TABLE', N'HuurgrenzenLiberalisatie', NULL, NULL
GO
