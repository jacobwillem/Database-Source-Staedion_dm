CREATE TABLE [Huuraanpassing].[Staedion$VAT Posting Setup]
(
[timestamp] [timestamp] NOT NULL,
[VAT Bus_ Posting Group] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[VAT Prod_ Posting Group] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[VAT Calculation Type] [int] NOT NULL,
[VAT _] [numeric] (38, 20) NOT NULL,
[Unrealized VAT Type] [int] NOT NULL,
[Adjust for Payment Discount] [tinyint] NOT NULL,
[Sales VAT Account] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Sales VAT Unreal_ Account] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Purchase VAT Account] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Purch_ VAT Unreal_ Account] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Reverse Chrg_ VAT Acc_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Reverse Chrg_ VAT Unreal_ Acc_] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[VAT Identifier] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Niet-geopteerde BTW-rekening] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[Pro-rata] [tinyint] NOT NULL,
[EU Service] [tinyint] NOT NULL,
[VAT Clause Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Certificate of Supply Required] [tinyint] NOT NULL,
[Tax Category] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[VERA VAT Code] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
