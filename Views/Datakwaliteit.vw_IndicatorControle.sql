SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Datakwaliteit].[vw_IndicatorControle]
AS 

select distinct
		 R.[fk_indicator_id]
		,R.[id_samengesteld]
		,[Attribuut] = IND.[Omschrijving]
		,[Controle] = DIM.Vertaling
from [Datakwaliteit].[RealisatieDetails] as R
join [Datakwaliteit].[Indicator] as IND
	on IND.[id] = R.[fk_indicator_id]
join [Datakwaliteit].[Indicatordimensie] as DIM
	 on DIM.id = R.fk_indicatordimensie_id

GO
