CREATE TABLE [Huren].[f_huursom]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Eenheidnr] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Datum] [date] NULL,
[Huursom_telt_mee_ja_nee] [smallint] NULL,
[Huursom_periode] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[Huursom_begin] [decimal] (8, 2) NULL,
[Huursom_einde] [decimal] (8, 2) NULL,
[Huursom_wijziging] AS (isnull([Huursom_einde],(0))-isnull([Huursom_begin],(0))),
[Huursom_telt_mee_ja_nee_oms] AS (case  when [Huursom_telt_mee_ja_nee]=(1) then 'Telt mee' else 'Telt niet mee' end)
) ON [PRIMARY]
GO
