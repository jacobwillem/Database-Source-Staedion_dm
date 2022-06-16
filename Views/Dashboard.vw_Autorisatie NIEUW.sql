SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [Dashboard].[vw_Autorisatie NIEUW]
AS
	with
	-- Haal accounts op waarbij niveau 2 het hoogste niveau is
	cte_niveau2 as (
		select [Organisatie niveau 2]
			,[Organisatie niveau 4]
		from [empire_staedion_data].[visma].[werknemers]
		where [Datum in dienst] <= getdate()
			and ([Datum Uit Dienst] is null
			or [Datum Uit Dienst] > getdate())
			and [Werk email] is not null
			and nullif([Organisatie niveau 4], '') is not null
		group by [Organisatie niveau 2], [Organisatie niveau 4]
	)

	-- Haal accounts op waarbij niveau 3 het hoogste niveau is
	,cte_niveau3 as (
		select [Organisatie niveau 3]
			,[Organisatie niveau 4]
		from [empire_staedion_data].[visma].[werknemers]
		where [Datum in dienst] <= getdate()
			and ([Datum Uit Dienst] is null
			or [Datum Uit Dienst] > getdate())
			and [Werk email] is not null
			and nullif([Organisatie niveau 4], '') is not null
		group by [Organisatie niveau 3], [Organisatie niveau 4]
	),

	-- Haal rapporten op
	cte_rapport as (
		select [Rapport]
			  ,[Doelgroep]
			  ,[Rol]
		from [Dashboard].[Rapport]
	),

	-- Haal gebruiker accounts op
	cte_accounts as (
		select [Naam] = tv.[Volledige naam]
			  ,[Account] = tv.[Werk email]
			  ,[Afdeling] = case
								when coalesce(nullif(cte2.[Organisatie niveau 4], ''), nullif(cte3.[Organisatie niveau 4], ''), tv.[Organisatie niveau 4]) like 'Thuisteam%' then 'Thuisteams'
								when coalesce(nullif(cte2.[Organisatie niveau 4], ''), nullif(cte3.[Organisatie niveau 4], ''), tv.[Organisatie niveau 4]) like 'Financiële administratie%' then 'Shared Service Center'
								when coalesce(nullif(cte2.[Organisatie niveau 4], ''), nullif(cte3.[Organisatie niveau 4], ''), tv.[Organisatie niveau 4]) like 'Service- en stookkosten%' then 'Shared Service Center'
								else coalesce(nullif(cte2.[Organisatie niveau 4], ''), nullif(cte3.[Organisatie niveau 4], ''), tv.[Organisatie niveau 4])
							end
		from [Medewerker].[TalentVisma] as tv
		left outer join cte_niveau2 as cte2
			on cte2.[Organisatie niveau 2] = tv.[Organisatie niveau 2]
			and nullif(tv.[Organisatie niveau 3], '') is null
			and nullif(tv.[Organisatie niveau 4], '') is null
		left outer join cte_niveau3 as cte3
			on cte3.[Organisatie niveau 3] = tv.[Organisatie niveau 3]
			and nullif(tv.[Organisatie niveau 4], '') is null
		where [Datum in dienst] <= getdate()
			and ([Datum Uit Dienst] is null or [Datum Uit Dienst] > getdate())
			and [Werk email] is not null
			and  nullif(coalesce(nullif(cte2.[Organisatie niveau 4], ''), nullif(cte3.[Organisatie niveau 4], ''), tv.[Organisatie niveau 4]), '') is not null
			--and tv.[Volledige naam] like '%vre%'
	),

	cte_rol as (
		-- Wijs per account rapporten toe op basis van afdeling
		select acc.[Account]
			  ,acc.[Naam]
			  ,rap.[Rol]
		from cte_accounts as acc
		left outer join cte_rapport rap on rap.Rapport = acc.afdeling
			and rap.[Doelgroep] = 'Afdeling'

		union

		-- Wijs per account rapporten toe waar iedereen toegang toe heeft
		select acc.[Account]
			  ,acc.[Naam]
			  ,rap.[Rol]
		from cte_accounts as acc
		full outer join cte_rapport rap on 1=1
			and rap.[Doelgroep] = 'Iedereen'
		where acc.account is not null
		group by [Naam], [Account], [Rol]
	)

	-- Trek autorisaties in obv handmatige aanpassingen in autorisatie tabel (toegang = 0)
	select cte_rol.[Account]
		  ,cte_rol.[Naam]
		  ,cte_rol.[Rol]
	from cte_rol
	where not exists (
		select * from [Dashboard].[Autorisatie] as cte_aut
		where cte_aut.[Account] = cte_rol.[Account]
		and cte_aut.[Rol] = cte_rol.[Rol]
		and cte_aut.Toegang = 0
	)
	and cte_rol.[Rol] is not null

	union

	-- Verleen autorisaties obv handmatige aanpassingen in autorisatie tabel (toegang = 1)
	select [Account] = aut.[Account]
		  ,[Naam] = tv.[Volledige naam]
		  ,aut.[Rol]
	from [Dashboard].[Autorisatie] as aut
	left outer join [Medewerker].[TalentVisma] as tv
		on aut.[Account] = tv.[Werk email]
		and aut.[Toegang] = 1
	
	union

	-- Verleen de afdeling Risk & Control volledig toegang tot alle rapporten, behalve indien de autorisatie expliciet is ingetrokken middels de autorisatie tabel (toegang = 0)
	select [Account] = tv.[Werk email]
		  ,[Naam] = tv.[Volledige naam]
		  ,rap.[Rol]
	from [Medewerker].[TalentVisma] as tv
	full outer join cte_rapport as rap on 1=1
	where tv.[Datum in dienst] <= getdate()
		and (tv.[Datum Uit Dienst] is null
		or tv.[Datum Uit Dienst] > getdate())
		and tv.[Werk email] is not null
		and tv.[Organisatie niveau 4] = 'Risk & Control'
		and tv.[Functie] <> 'proces- en informatieanalist'
		and not exists (
		select * from [Dashboard].[Autorisatie] as cte_aut
		where cte_aut.[Account] = tv.[Werk email]
		and cte_aut.[Rol] = rap.[Rol]
		and cte_aut.Toegang = 0
		)



GO
