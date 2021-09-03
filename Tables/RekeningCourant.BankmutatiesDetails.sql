CREATE TABLE [RekeningCourant].[BankmutatiesDetails]
(
[Importnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Boekdatum] [datetime] NOT NULL,
[Bedrag] [numeric] (38, 20) NOT NULL,
[Naam] [nvarchar] (45) COLLATE Latin1_General_CI_AS NOT NULL,
[Volgnr klantposten] [int] NOT NULL,
[Bron] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
