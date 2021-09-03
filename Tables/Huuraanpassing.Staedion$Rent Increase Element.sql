CREATE TABLE [Huuraanpassing].[Staedion$Rent Increase Element]
(
[timestamp] [timestamp] NOT NULL,
[Realty Object No_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Period Code] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Element No_] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Contract Type] [int] NOT NULL,
[Contract Entry No_] [int] NOT NULL,
[Element Type] [int] NOT NULL,
[Element Description] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Unit Price] [numeric] (38, 20) NOT NULL,
[Current Amount] [numeric] (38, 20) NOT NULL,
[Increase Percentage] [numeric] (38, 20) NOT NULL,
[New Amount] [numeric] (38, 20) NOT NULL
) ON [PRIMARY]
GO
