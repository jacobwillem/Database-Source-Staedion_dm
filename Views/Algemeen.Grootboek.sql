SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [Algemeen].[Grootboek]
as

select
[clusternummer]         = [Clusternr_],
[Rekeningnummer]        = [G_L Account No_],
[Bedrag]                = [Amount],
[Bedrag excl. EXTBEHEER|DAEBRC|DAEBVERD]    = case when [Source Code] in ('EXTBEHEER','DAEBRC','DAEBVERD') then null
                                                else [Amount] end,
[Bedrag EXTBEHEER|DAEBRC|DAEBVERD]          = case when [Source Code] in ('EXTBEHEER','DAEBRC','DAEBVERD') then [Amount]
                                                  else null end,
[Credit Amount],
[Debit Amount],
[Posting Date],
[Omschrijving]          = [Description],
[Source Code]

from empire_data.[dbo].[Staedion$G_L_Entry]
where year([Posting Date]) >=2016
--and [Source Code] not like 'DAEB%'
and [G_L Account No_] like 'A8%'








GO
