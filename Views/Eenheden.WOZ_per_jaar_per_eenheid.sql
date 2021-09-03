SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Eenheden].[WOZ_per_jaar_per_eenheid] as
	with CTE_jaargangen as ( 
		select [Jaartal] = 2000
		union all
		select Jaartal = yl.Jaartal + 1 
		from CTE_jaargangen as yl
		where yl.Jaartal + 1 <= year(getdate())
		)
    ,CTE_eenheid as (
        select distinct Eenheidnr_
        from empire_data.dbo.[Staedion$WOZgegevens]
        )

select CTE_JAAR.Jaartal
		,Eenheid = CTE_OGE.eenheidnr_
		,[WOZ-objectnr] = WOZ.[WOZ-objectnr_]
		,WOZ.[WOZ-peildatum]
		,WOZ.[Jaar vanaf]
		,WOZ.[Jaar tot]
		,WOZ.[WOZ-taxatiewaarde]
from CTE_eenheid as CTE_OGE
full outer join CTE_jaargangen as CTE_JAAR
	on 1=1
left outer join empire_data.dbo.[Staedion$WOZgegevens] as WOZ
       on CTE_JAAR.Jaartal >= WOZ.[Jaar vanaf]
              and CTE_JAAR.Jaartal < iif(WOZ.[Jaar tot] = WOZ.[Jaar vanaf], WOZ.[Jaar tot] + 1, WOZ.[Jaar tot])
              and WOZ.Eenheidnr_ = CTE_OGE.eenheidnr_
GO
