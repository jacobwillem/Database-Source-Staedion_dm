SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [Dashboard].[vw_DimensieDetails]
AS
with
T as (
	select [num] = 1
	union all
	select [num] + 1
	from T
	where [num] < 17
),

Q as (
	select 	 [id] = R.[id]
			,[Dimensie_id] = (R.[fk_indicator_id] * 100) +  T.[num]
			,[Detail] = case T.[num]
							when 1 then R.[Detail_01]
							when 2 then R.[Detail_02]
							when 3 then R.[Detail_03]
							when 4 then R.[Detail_04]
							when 5 then R.[Detail_05]
							when 6 then R.[Detail_06]
							when 7 then R.[Detail_07]
							when 8 then R.[Detail_08]
							when 9 then R.[Detail_09]
							when 10 then R.[Detail_10]
							when 11 then convert(varchar, R.[Datum], 23)
							when 12 then left(convert(varchar, R.[Datum], 23), 7)
							when 13 then C.[Buurt]
							when 14 then R.[Clusternummer]
							when 15 then C.[Deelgebied]
							when 16 then C.[Gemeente]
							when 17 then C.[Wijk]
						end
	from [Dashboard].[vw_RealisatiePrognose2] as R
	full outer join T on 1 = 1
	left join [Dashboard].[vw_Clusterlocatie] as C on R.[Clusternummer] = C.[Clusternummer] and T.[num] between 13 and 17
	where R.[fk_indicator_id] is not null --and fk_indicator_id = 110
)

select * from Q 

GO
