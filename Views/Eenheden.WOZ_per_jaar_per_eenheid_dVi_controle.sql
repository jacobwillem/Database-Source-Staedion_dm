SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Eenheden].[WOZ_per_jaar_per_eenheid_dVi_controle] as

	with CTE_DVI_INCR as (
        select *
		from [empire_staedion_data].[excel].[dvi] 
        )

	select WOZ.Jaartal,
			EenheidWOZ = WOZ.Eenheid,
			WOZ.[WOZ-objectnr],
			WOZ.[WOZ-peildatum],
			WOZ.[Jaar vanaf],
			WOZ.[Jaar tot],
			WOZaanslag = cast(WOZ.[WOZ-taxatiewaarde] as numeric(15,2)),
			EenheiddVi = dVi.Eenheid,
			WOZdVi = dVi.[WOZdVi],
			dViRapportageJaar = dVi.[Jaartal],
			ToenameRatioWOZdVi = case when CTE_DVI_INCR.[WOZdVi] = 0 then null
										else (dVi.[WOZdVi] - CTE_DVI_INCR.[WOZdVi]) / CTE_DVI_INCR.[WOZdVi]
										end,
			VerschilWOZaanslagWOZdVi = dVi.[WOZdVi] - WOZ.[WOZ-taxatiewaarde],
			WOZaanslag_gelijkaan_WOZdVi = case 
											when WOZ.[WOZ-taxatiewaarde] = dVi.[WOZdVi] then 1
											when WOZ.[WOZ-taxatiewaarde] is null then -1
											else 0
											end,
			ELS.clusternummer,
			ELS.clusternaam,
			Adres = replace(convert(varchar(128),ELS.straat) + ' ' + convert(varchar(64), ELS.huisnummer) + ' ' + convert(varchar(64), ELS.toevoegsel), '  ', ' '),
			Plaats = ELS.da_plaats,
			ELS.da_staedion_groep_technischtype

	from [Eenheden].[WOZ_per_jaar_per_eenheid] as WOZ
	right outer join [empire_staedion_data].[excel].[dvi] as dVi on
		WOZ.Eenheid = dVi.Eenheid and WOZ.Jaartal - 1 = dVi.Jaartal
	left outer join CTE_DVI_INCR on
		dVi.Eenheid = CTE_DVI_INCR.Eenheid and dVi.Jaartal = CTE_DVI_INCR.Jaartal + 1
	left outer join 
	[empire_staedion_data].[dbo].[ELS] as ELS on
	dVi.Eenheid = ELS.[eenheidnr]
	where datum_gegenereerd = (select max(datum_gegenereerd) from [empire_staedion_data].[dbo].[ELS])
GO
