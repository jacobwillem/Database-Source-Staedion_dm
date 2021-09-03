SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [Contracten].[fn_ControleIngangsdataHuurcontract] (@OgeNr nvarchar(20) = 'OGEH-0059086', @HuurderNr nvarchar(20) = null, @AlleenFouteData smallint = 1) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Check op eerste ingangsdata huurcontract van eenheid: wordt op minimaal 3 plekken vastgelegd
ZIE         : 
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: 20210707 Aangemaakt op basis van  empire_Dwh.dbo.[ITVF_check_ingangsdata_huurcontract] 
> hernoemd en info generieke kenmerken toegevoegd
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
select * from staedion_dm.Contracten.[fn_ControleIngangsdataHuurcontract] (null,null,0)				-- 93.468 - alle info
select * from staedion_dm.Contracten.[fn_ControleIngangsdataHuurcontract] (null,null,1)				-- 2.989 - alleen foute info
select [Reden afwijking], count(*) 
from staedion_dm.Contracten.[fn_ControleIngangsdataHuurcontract] (null,null,1)				-- 2.988
group by  [Reden afwijking] 

------------------------------------------------------------------------------------------------------
LATER
------------------------------------------------------------------------------------------------------
Eventueel voor alle contracten
------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------
	Declare @Nr as nvarchar(20) = 'OGEH-0061279'
	-- Toch niet helemaal top
	select [Dummy Contract],Eenheidnr_, Volgnr_, Ingangsdatum, Einddatum
	from	 empire_Data.dbo.[staedion$Contract]		
	where	 Ingangsdatum > iif(Einddatum='17530101','20990101',Einddatum)
	and		 [Dummy Contract] = 0
	union
	select [Dummy Contract],Eenheidnr_, Volgnr_, Ingangsdatum, Einddatum
	from	 empire_Data.dbo.[staedion$Contract]		
	where	 NOT(Ingangsdatum > iif(Einddatum='17530101','20990101',Einddatum))
	and		 [Dummy Contract] = 1



		select e.bk_nr_, f.* 
		from empire_dwh.dbo.f_verhuringen as f
		join empire_Dwh.dbo.eenheid as e
		on f.fk_eenheid_id = e.id
		where e.bk_nr_ = @Nr

		select top 10 * 
		from	empire_Data.dbo.[staedion$OGE_Status_History] 
		where [Unit No_] = @Nr

		select top 10 * 
		from	empire_Data.dbo.[staedion$Contract] 
		where Eenheidnr_ = @Nr

		select top 10 * 
		from	empire_Data.dbo.[staedion$Additioneel] 
		where Eenheidnr_ = @Nr


################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
	SELECT datum AS Laaddatum
	FROM empire_dwh.dbo.tijd
	WHERE [last_loading_day] = 1
	)
	,CTE_Additioneel
AS (
	SELECT Eenheidnr = Eenheidnr_
		,Ingangsdatum = Ingangsdatum
		,Einddatum
		,Huurder = [Customer No_]
		,VolgnrContract = row_number() OVER (
			PARTITION BY Eenheidnr_
			,[Customer No_] ORDER BY Ingangsdatum ASC
			)
		,VolgnrAllecontracten = row_number() OVER (
			PARTITION BY Eenheidnr_ ORDER BY Ingangsdatum ASC
			)
	FROM empire_Data.dbo.[staedion$Additioneel]
	WHERE [Customer No_] <> ''
		AND Ingangsdatum <= iif(Einddatum = '17530101', '20990101', Einddatum)
		AND (
			Eenheidnr_ = @OgeNr
			OR @OgeNr IS NULL
			)
	)
	,CTE_Contract
AS (
	SELECT Eenheidnr = Eenheidnr_
		,Ingangsdatum = Ingangsdatum
		,Huurder = [Customer No_]
		,VolgnrContract = row_number() OVER (
			PARTITION BY Eenheidnr_
			,[Customer No_] ORDER BY Ingangsdatum ASC
			)
		,VolgnrAllecontracten = row_number() OVER (
			PARTITION BY Eenheidnr_ ORDER BY Ingangsdatum ASC
			)
		,[Dummy Contract]
	FROM empire_Data.dbo.[staedion$Contract]
	WHERE [Customer No_] <> ''
		AND Ingangsdatum <= iif(Einddatum = '17530101', '20990101', Einddatum)
		AND (
			Eenheidnr_ = @OgeNr
			OR @OgeNr IS NULL
			)
		-- and [Dummy Contract] = 0				-- zou gelijk moeten zijn aan: ingangsdatum na einddatum
	), CTE_generiek_kenmerk_contract
AS (
	SELECT Kenmerk = A.[Description]
		,Ingangsdatum = AVE.Ingangsdatum
		,Einddatum = AVE.Einddatum
		,[Eigenschap optieveld generieke kenmerk] = AP.[Description]
		,Huurder = staedion_dm.[Algemeen].[fn_StringToArray](AVE.Sleutel, ',', 1)
		,Eenheidnr = staedion_dm.[Algemeen].[fn_StringToArray](AVE.Sleutel, ',', 2)
		,Volgnr = row_number() over (partition by AVE.[Sleutel] order by AVE.Ingangsdatum desc)
	FROM empire_data.dbo.[Staedion$Attribute_Value_Entry] AS AVE -- order by [Entry No_] desc
	LEFT OUTER JOIN empire_data.dbo.[Staedion$Attribute_Group] AS AG ON AG.No_ = AVE.[Group No_]
	LEFT OUTER JOIN empire_data.dbo.[Staedion$Attribute] AS A ON A.[Group No_] = AVE.[Group No_]
		AND A.No_ = AVE.[Attribute No_]
	LEFT OUTER JOIN empire_data.dbo.[Staedion$Attribute_Property] AS AP ON AP.[Group No_] = AVE.[Group No_]
		AND AP.[Attribute No_] = AVE.[Attribute No_]
		AND AP.[Value] = AVE.[Value]
	where AVE.[Group No_] = 10 -- Reden afwijking Ingangsdatum hc tov 1e contr.reg.
	)

SELECT Eenheidnr = coalesce(CONTR.Eenheidnr, ADDIT.Eenheidnr)
	,[Huurder tabel contract] = CONTR.Huurder
	,[Huurder tabel huurcontractgegevens] = ADDIT.Huurder
	,[Ingangsdatum tabel huurcontractgegevens] = nullif(ADDIT.Ingangsdatum, '17530101')
	,[Einddatum tabel huurcontractgegevens] = nullif(ADDIT.Einddatum, '17530101')
	,[Eerste ingangsdatum tabel contract] = nullif(CONTR.Ingangsdatum, '17530101')
	,[Afwijking in dagen] = datediff(d, ADDIT.Ingangsdatum, CONTR.Ingangsdatum)
	,[Opmerking] = iif(CONTR.VolgnrAllecontracten = 1, 'Eerste verhuurcontract', '')
	,[Conversie-eenheid] = coalesce(VES1.Herkomst,VES2.Herkomst)
	,[Ingangsdatum generiek kenmerk] = KENM.Ingangsdatum
	,[Reden afwijking] = KENM.[Eigenschap optieveld generieke kenmerk]
	,[Gegenereerd] = P.Laaddatum
FROM CTE_Contract AS CONTR
FULL OUTER JOIN CTE_Additioneel AS ADDIT ON ADDIT.Eenheidnr = CONTR.Eenheidnr
	AND ADDIT.Huurder = CONTR.Huurder
FULL OUTER JOIN CTE_peildata AS P ON 1 = 1
left outer join empire_staedion_data.Vestia.Overname2013April as VES1 
on VES1.Eenheidnr = coalesce(CONTR.Eenheidnr, ADDIT.Eenheidnr)
left outer join empire_staedion_data.Vestia.Overname2020Nov as VES2 
on VES2.Eenheidnr = coalesce(CONTR.Eenheidnr, ADDIT.Eenheidnr)
left outer join CTE_generiek_kenmerk_contract as KENM 
on KENM.Eenheidnr = ADDIT.Eenheidnr
and KENM.Huurder = ADDIT.Huurder 
and KENM.Volgnr = 1
WHERE ADDIT.VolgnrContract = 1
	AND CONTR.VolgnrContract = 1
	AND (
		(
			@AlleenFouteData = 1
			AND CONTR.Ingangsdatum <> ADDIT.Ingangsdatum
			)
		OR @AlleenFouteData = 0
		)
   AND (ADDIT.Huurder = @HuurderNr 
   OR @HuurderNr  is null)
GO
