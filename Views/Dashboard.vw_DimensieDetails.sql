SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE view [Dashboard].[vw_DimensieDetails]
as
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
							when 11 then format(R.[Datum], 'dd MMM', 'nl-NL')	--convert(varchar, R.[Datum], 23)
							when 12 then format(R.[Datum], 'MMM', 'nl-NL')		-- left(convert(varchar, R.[Datum], 23), 7)
							when 13 then C.[Deelgebied]
							when 14 then C.[Wijk]
							when 15 then C.[Buurt]
							when 16 then R.[Clusternummer]
							when 17 then C.[Gemeente]
						end
			,[Detail sort] = case T.[num]
								when 1 then ascii(left(R.[Detail_01], 1))
								when 2 then ascii(left(R.[Detail_02], 1))
								when 3 then ascii(left(R.[Detail_03], 1))
								when 4 then ascii(left(R.[Detail_04], 1))
								when 5 then ascii(left(R.[Detail_05], 1))
								when 6 then ascii(left(R.[Detail_06], 1))
								when 7 then ascii(left(R.[Detail_07], 1))
								when 8 then ascii(left(R.[Detail_08], 1))
								when 9 then ascii(left(R.[Detail_09], 1))
								when 10 then ascii(left(R.[Detail_10], 1))
								when 11 then format(R.[Datum], 'MMdd', 'nl-NL')
								when 12 then format(R.[Datum], 'MM', 'nl-NL')
								when 13 then ascii(left(C.[Deelgebied], 1))
								when 14 then ascii(left(C.[Wijk], 1))
								when 15 then ascii(left(C.[Buurt], 1))
								when 16 then ascii(left(R.[Clusternummer], 1))
								when 17 then ascii(left(C.[Gemeente], 1))
							end
			/*,[Detail sort] = case T.[num]
								when 1 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_01])
								when 2 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_02])
								when 3 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_03])
								when 4 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_04])
								when 5 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_05])
								when 6 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_06])
								when 7 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_07])
								when 8 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_08])
								when 9 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_09])
								when 10 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by R.[Detail_10])
								when 11 then format(R.[Datum], 'MMdd', 'nl-NL')
								when 12 then format(R.[Datum], 'MM', 'nl-NL')
								when 13 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by C.[Deelgebied])
								when 14 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by C.[Wijk])
								when 15 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by C.[Buurt])
								when 16 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by C.[Clusternummer])
								when 17 then dense_rank() over (partition by (R.[fk_indicator_id] * 100) +  T.[num] order by C.[Gemeente])
							end
			*/
	from [Dashboard].[vw_RealisatiePrognose2] as R
	cross join T
	left join [Dashboard].[vw_Clusterlocatie] as C on R.[Clusternummer] = C.[Clusternummer] and T.[num] between 13 and 17
	where R.[fk_indicator_id] is not null -- and R.[fk_indicator_id] = 110
)

select * from Q

GO
