SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [Huuraanpassing].[fn_Huurprijs] (@eenheidnr varchar(20), @peildatum date)
/******************************************************************************
Van		RvG
Betreft	functie om op @peildatum de kale, netto, bruto huur (exclusief en 
		inclusief btw) en de subsidiabele huur op te halen
Aanroep select oge.Nr_, hpr.Prolongatietermijn, hpr.kalehuur, hpr.kalehuur_inclbtw, 
			hpr.nettohuur, hpr.nettohuur_inclbtw, 
			hpr.brutohuur, hpr.brutohuur_inclbtw,
			hpr.btw_op_nettohuur,
			hpr.subsidiabelehuur
		from staedion_dm.Huuraanpassing.Staedion$OGE oge
		outer apply empire_staedion_data.dbo.[ITVfnHuurprijs](oge.nr_, @peildatum date) as hpr
		where oge.[Common Area] = 0 and
		oge.[Begin Exploitatie] <= getdate() and
		(oge.[Einde exploitatie] >= getdate() or oge.[Einde exploitatie] = '1753-01-01')
------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------
20200324 JvdW: markthuur toegevoegd, zie check in TIJDELIJK
20200525 JvdW: huurdernr toegevoegd, 20 05 839 Verzoek huurprijzen 1-7-2020 tbv GKB  + conditie [Dummy Contract] = 0 toegevoegd
20200619 RvG:  toegevoegd kolommen uit streefhuurfunctie omdat daarvoor naast de wwd gegevens ook de huurprijsgegevens nodig zijn
			   beter alles in 1 functie ophalen.
20210219 RvG:  Kolommen voor de opbouw van het subsidiabele deel van de huur toegevoegd in twee varianten: zonder en met aftopping
			   [Subsidiabele energiekosten] en [Subsidiabele energiekosten afgetopt],
			   [Subsidiabele schoonmaakkosten] en [Subsidiabele schoonmaakkosten afgetopt],
			   [Subsidiabele huismeesterkosten] en [Subsidiabele huismeesterkosten afgetopt],
			   [Subsidiabele kapitaal/onderhoudskosten] en [Subsidiabele kapitaal/onderhoudskosten afgetopt]
20210317 JvdW: Tabelnamen en kolomnamen aangepast aan Empire-benamingen
------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] empire_staedion_data, 'dbo', 'ITVfnHuurprijs'

USE empire_staedion_data;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'Functie waarbij op basis van oge-nummer en datum op basis van gekopieerde Empire-tabellen (empire_data) diverse huurprijzen worden berekend',   
@level0type = N'SCHEMA', @level0name = 'dbo',  
@level1type = N'FUNCTION',  @level1name = 'ITVfnHuurprijs'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'Roelof van Goor',   
@level0type = N'SCHEMA', @level0name = 'dbo',  
@level1type = N'FUNCTION',  @level1name = 'ITVfnHuurprijs'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select oge.Nr_, hpr.Prolongatietermijn, hpr.kalehuur, hpr.kalehuur_inclbtw, 
			hpr.nettohuur, hpr.nettohuur_inclbtw, 
			hpr.brutohuur, hpr.brutohuur_inclbtw,
			hpr.btw_op_nettohuur,
			hpr.subsidiabelehuur,
			hpr.streefhuur
		from staedion_dm.Huuraanpassing.Staedion$OGE oge
		outer apply empire_staedion_data.dbo.[ITVfnHuurprijs](oge.nr_,getdate()) as hpr
		where oge.[Common Area] = 0 and
		oge.[Begin Exploitatie] <= getdate() and
		(oge.[Einde exploitatie] >= getdate() or oge.[Einde exploitatie] = ''1753-01-01'')',   
@level0type = N'SCHEMA', @level0name = 'dbo',  
@level1type = N'FUNCTION',  @level1name = 'ITVfnHuurprijs'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'dbo',  
@level1type = N'FUNCTION',  @level1name = 'ITVfnHuurprijs'
------------------------------------------------------------------------------------------------------
TIJDELIJK
------------------------------------------------------------------------------------------------------
> check saldo vooraf:		
44735	44735	21499233.82	23104179.60
> check saldo achteraf: 44735	44735	21499233.82	23104179.60	7395859.03
		select count(*), count(distinct oge.Nr_), sum(hpr.kalehuur), sum(hpr.brutohuur_inclbtw), sum(hpr.markthuur)
		from staedion_dm.Huuraanpassing.Staedion$OGE as oge
		outer apply empire_staedion_data.dbo.[ITVfnHuurprijs](oge.nr_, '20200630') as hpr
		where oge.[Common Area] = 0 and
		oge.[Begin Exploitatie] <= getdate() and
		(oge.[Einde exploitatie] >= getdate() or oge.[Einde exploitatie] = '1753-01-01')
		;
> select eenheidnr_, Ingangsdatum, [Markthuurwaarde (LV)] from staedion_dm.Huuraanpassing.staedion$contract where Eenheidnr_ = 'ADEH-0044149'
  select  markthuur from empire_staedion_data.dbo.[ITVfnHuurprijs]('ADEH-0044149', '20180101') 
---------------------------------------------------------------------------------------------
select hpr.eenheidnr,  hpr.brutohuur_inclbtw, hpr.nettohuur_incl_korting_btw, hpr.kalehuur_inclbtw
--SELECT count(*)	,count(DISTINCT oge.Nr_) 	,sum(hpr.kalehuur) 	,sum(hpr.brutohuur_inclbtw) 	,sum(hpr.markthuur) 
FROM staedion_dm.Huuraanpassing.Staedion$OGE AS oge
OUTER APPLY [P-APPS].dbo.[ITVfnHuurprijs](oge.nr_, getdate()) AS hpr
WHERE oge.[Common Area] = 0
and oge.Nr_ = 'OGEH-0004711'
	AND oge.[Begin Exploitatie] <= getdate()
	AND (
		oge.[Einde exploitatie] >= getdate()
		OR oge.[Einde exploitatie] = '1753-01-01'
		);




******************************************************************************/

returns table
as
	return
	-- declare @peildatum date = getdate(), @eenheidnr nvarchar(20) = 'OGEH-0003490' ;
	with dat (peildatum)
	as (select isnull(@peildatum, convert(date, getdate()))),
	crg (peildatum, elementen2f, maxbedrag2f, elementen2g, maxbedrag2g, elementen2h, maxbedrag2h, elementen2i, maxbedrag2i, liberalisatiegrens)
	as (select dat.peildatum
			,'|' + crg.[Subs_element(en) 2f] + '|'
			,crg.[Max_bedrag 2f]
			,'|' + crg.[Subs_element(en) 2g] + '|'
			,crg.[Max_bedrag 2g]
			,'|' + crg.[Subs_element(en) 2h] + '|'
			,crg.[Max_bedrag 2h]
			,'|' + crg.[Subs_element(en) 2i] + '|'
			,crg.[Max_bedrag 2i]
			,(select [Liberalisation Limit]
			from staedion_dm.Huuraanpassing.[parameter state aid] psa
		where psa.[Start Date] <= @peildatum and psa.[End Date] >= @peildatum) liberalisatiegrens
		from staedion_dm.Huuraanpassing.[Staedion$CR-gegevens] crg INNER JOIN dat
		on 1 = 1
		where crg.Ingangsdatum = (
			select max(crm.Ingangsdatum)
			from staedion_dm.Huuraanpassing.[Staedion$CR-gegevens] crm
			where crm.Ingangsdatum <= dat.peildatum)),
	con (Prolongatietermijn)
	as (select Prolongatietermijn
		from staedion_dm.Huuraanpassing.Staedion$Contract con INNER JOIN dat
		on con.Ingangsdatum <= dat.peildatum AND 
		(con.Einddatum = '1753-01-01' OR con.Einddatum >= dat.peildatum)
		where con.Eenheidnr_ = @eenheidnr
		group by Prolongatietermijn),
	dgp (doelgroep, aftopgrens, inclusiefsubsidiabeldeel)
	as (select clt.[Target Group Code], clt.[Limit Amount], clt.SubsidyServiceAmountIncluded
		from staedion_dm.Huuraanpassing.[Staedion$Capping Limit per Target Grp_] clt inner join (
			select sel.[Target Group Code], max(sel.[Starting Date]) [Starting Date]
			from staedion_dm.Huuraanpassing.[Staedion$Capping Limit per Target Grp_] sel
			where sel.[Starting Date] <= @peildatum
			group by sel.[Target Group Code]) sel
		on clt.[Target Group Code] = sel.[Target Group Code] and clt.[Starting Date] = sel.[Starting Date]),
	prt (Prolongatietermijn, factor)
	as (select Prolongatietermijn
              ,case when charindex(char(5), Prolongatietermijn) > 0 then convert(int, replace(prolongatietermijn, char(5), ''))
                     when charindex(char(6), Prolongatietermijn) > 0 then convert(int, replace(prolongatietermijn, char(6), '')) * 3
                     when charindex(char(7), Prolongatietermijn) > 0 then convert(int, replace(prolongatietermijn, char(7), '')) * 12
                     else 1 end factor
       from con),
	flt (Eenheidnr_, Volgnr_, nr)
	as (select con.Eenheidnr_, con.Volgnr_, row_number() over (partition by con.Eenheidnr_ order by con.Ingangsdatum desc) nr
		from staedion_dm.Huuraanpassing.Staedion$Contract con inner join crg
		on 1 = 1
		where con.[Dummy Contract] = 0 and -- JvdW 20200525 toegevoegd
		con.Ingangsdatum <= crg.peildatum and
			(con.Einddatum = '1753-01-01' OR con.Einddatum >= crg.peildatum) and
		con.Eenheidnr_ = @eenheidnr),
	hpr (eenheidnr
		,huurdernr
		,Prolongatietermijn
		,kalehuur
		,kalehuur_inclbtw
		,nettohuur
		,nettohuur_inclbtw
		,btw_compensatie
		,btw_compensatie_inclbtw
		,huurkorting
		,huurkorting_inclbtw
		,verbruikskosten
		,verbruikskosten_inclbtw
		,servicekosten
		,servicekosten2
		,servicekosten_inclbtw
		,subsf
		,subsg
		,subsh
		,subsi
		,stookkosten
		,water
		,water_inclbtw
		,brutohuur
		,brutohuur_inclbtw
		,markthuur)
	as (select con.Eenheidnr_ eenheidnr
			,con.[Customer No_]
			,con.Prolongatietermijn
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort = 4
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) kalehuur
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort = 4
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) kalehuur_inclbtw
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (0, 4, 10)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) nettohuur
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (0, 4, 10)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) nettohuur_incbtw
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (10)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) btw_compensatie
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (10)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) btw_compensatie_inclbtw
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (9)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) huurkorting
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (9)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) huurkorting_inclbtw
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (2)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) verbruikskosten
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (2)
					AND elm.administratie = 0
					AND elm.diversen = 0
					AND elm.Leges = 0, elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) verbruikskosten_inclbtw
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (1), elm.[bedrag (lv)] / prt.factor, 0), 2)) servicekosten
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (1,2), elm.[bedrag (lv)] / prt.factor, 0), 2)) servicekosten2
			,sum(round(iif(elm.soort = 0
					AND elm.elementsoort IN (1), elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) servicekosten_inclbtw
			,sum(round(iif(charindex('|' + elm.Nr_ + '|', crg.elementen2f) > 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) subsf
			,sum(round(iif(charindex('|' + elm.Nr_ + '|', crg.elementen2g) > 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) subsg
			,sum(round(iif(charindex('|' + elm.Nr_ + '|', crg.elementen2h) > 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) subsh
			,sum(round(iif(charindex('|' + elm.Nr_ + '|', crg.elementen2i) > 0, elm.[bedrag (lv)] / prt.factor, 0), 2)) subsi
			,sum(round(iif(elm.Nr_ IN ('117', '123', '125', '126', '163', '166', '184', '192', '215'), elm.[bedrag (lv)] / prt.factor, 0), 2)) water
			,sum(round(iif(elm.[Productboekingsgroep] in ('VR CV','NV CV','VR STR IND','VR WATER','NV WATER','VR WARMWAT','VR WARMTEV','VR CV NWW','NV BRONWR','NV BRONWRB','NV WARMTEH','NV WARMTEU'), elm.[bedrag (lv)] / prt.factor, 0), 2)) stookkosten
			,sum(round(iif(elm.Nr_ IN ('117', '123', '125', '126', '163', '166', '184', '192', '215'), elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 0), 2)) water_inclbtw
			,sum(round(elm.[bedrag (lv)] / prt.factor, 2)) brutohuur
			,sum(round(elm.[bedrag (lv)] * (100.0 + isnull(vps.[Vat _], 0)) / (100.0 * prt.factor), 2)) brutohuur_inclbtw
			,max(round(con.[Markthuurwaarde (LV)], 2)) AS markthuur
	from staedion_dm.Huuraanpassing.Staedion$Contract con inner join flt 
	on con.Eenheidnr_ = flt.Eenheidnr_ and con.Volgnr_ = flt.Volgnr_ and flt.nr = 1
	inner join prt
	on con.Prolongatietermijn = prt.Prolongatietermijn
	inner join crg
	on 1 = 1
	left outer join staedion_dm.Huuraanpassing.Staedion$Element elm
	on con.Eenheidnr_ = elm.Eenheidnr_ and con.Volgnr_ = elm.Volgnummer and elm.Tabel = 3 and elm.eenmalig = 0
	left outer join staedion_dm.Huuraanpassing.[Staedion$VAT Posting Setup] vps
	on vps.[VAT Bus_ Posting Group] = 'NL' and vps.[VAT Prod_ Posting Group] = elm.[btw-productboekingsgroep]
	group by con.Eenheidnr_, con.Prolongatietermijn, con.[Customer No_]),
	wwd (Eenheidnr_, Woonruimte, Ingangsdatum, Volgnummer)
	as (select pva.Eenheidnr_, 0, pva.Ingangsdatum, max(pva.Volgnummer)
		from staedion_dm.Huuraanpassing.[Staedion$Property Valuation] pva
		where pva.Eenheidnr_ = @eenheidnr and
		pva.Ingangsdatum <= @peildatum and 
		pva.Einddatum >= @peildatum
		group by pva.Eenheidnr_, pva.Ingangsdatum
		union
		select pvo.Eenheidnr_, 1, pvo.Ingangsdatum, max(pvo.Volgnummer)
		from staedion_dm.Huuraanpassing.[Staedion$Prop_ Valuation (Shared Acc_)] pvo   --
		where pvo.Eenheidnr_ = @eenheidnr and
		pvo.Ingangsdatum <= @peildatum and 
		pvo.Einddatum >= @peildatum
		group by pvo.Eenheidnr_, pvo.Ingangsdatum),
	ept (Woonruimte, puntprijs)
	as (-- voor punten boven 250 per punt verschil tussen 249 en 250 punten per punt toekennen
		select 0, sum(iif(mhp.Punten = 249, -1, 1) * mhp.[Maximale huurprijs (LV)]) puntprijs
		from staedion_dm.Huuraanpassing.[Staedion$Maximale huurprijzen] mhp
		where mhp.tabel = 0 and 
		mhp.Punten >= 249 and
		mhp.jaar = year(dateadd(month, -6, @peildatum))
		union
		-- voor punten boven 750 per punt verschil tussen 749 en 750 punten per punt toekennen
		select 1, sum(iif(mhp.Punten = 749, -1, 1) * mhp.[Maximale huurprijs (LV)]) puntprijs
		from staedion_dm.Huuraanpassing.[Staedion$Maximale huurprijzen] mhp
		where mhp.tabel = 1 and 
		mhp.Punten >= 749 and
		mhp.jaar = year(dateadd(month, -6, @peildatum))),
	sfh (Eenheidnr, doelgroep, Woningwaardering, [Ingangsdatum], Totaal_punten, 
			Totaal_punten_afgerond, [Maximaal_toegestane_huur], [Streefhuur], totaal_oppervlakte, perc_max_red_huur,
			energiewaardering, EPA_label, Energie_index, Bouwjaar, datum_afgemeld, 
			energiepunten)
	as (select pva.Eenheidnr_, 
			oge.[Target Group Code] doelgroep,
			'Zelfstandig' Woningwaardering, 
			pva.[Ingangsdatum], 
			pva.[Totaal punten] Totaal_punten, 
			pva.[Totaal punten afgerond] Totaal_punten_afgerond, 
			round(mhp.[Maximale huurprijs (LV)] + iif(pva.[Totaal punten afgerond] > 250, pva.[Totaal punten afgerond] - 250, 0) * ept.puntprijs, 2) [Maximaal_toegestane_huur],
			round((mhp.[Maximale huurprijs (LV)] + iif(pva.[Totaal punten afgerond] > 250, pva.[Totaal punten afgerond] - 250, 0) * ept.puntprijs) * isnull(trm.[Target Rent _], 0) / 100.0, 2) [Streefhuur],
			pva.[Total Surface] totaal_oppervlakte, 
			trm.[Target Rent _] perc_max_red_huur,
			case pva.[Energy Validation] when 0 then 'Verwarming en isolatie'
				when 1 then 'EPA-label'
				when 2 then 'Energie-index'
				when 3 then 'Bouwjaar'
				else 'Onbekend' end energiewaardering, 
			pva.[EPA-label] EPA_label, 
			pva.[Energy Index] Energie_index, 
			pva.Bouwjaar, 
			pva.[date certificate granted] datum_afgemeld, 
			pva.[energy points] energiepunten
		from staedion_dm.Huuraanpassing.[Staedion$Property Valuation] pva inner join wwd
		on pva.Eenheidnr_ = wwd.Eenheidnr_ and pva.Ingangsdatum = wwd.Ingangsdatum and pva.Volgnummer = wwd.Volgnummer
		inner join staedion_dm.Huuraanpassing.Staedion$oge oge
		on pva.Eenheidnr_ = oge.Nr_ and oge.Woonruimte = wwd.Woonruimte
		inner join staedion_dm.Huuraanpassing.[Staedion$Maximale huurprijzen] mhp
		on mhp.tabel = 0 and 
		mhp.jaar = year(dateadd(month, -6, @peildatum)) and
		iif(pva.[Totaal punten afgerond] < 40, 40, iif(pva.[Totaal punten afgerond] > 250, 250, pva.[Totaal punten afgerond])) = mhp.Punten
		inner join ept
		on oge.Woonruimte = ept.Woonruimte
		left outer join staedion_dm.Huuraanpassing.[Staedion$target rent _ max_ reas_ rent] trm  
		on oge.[Code huur _ max_ huurprijs] COLLATE database_default = trm.Code    COLLATE database_default
		where pva.Eenheidnr_ = @eenheidnr
		union
		select pvo.Eenheidnr_, oge.[Target Group Code] doelgroep,
			'Onzelfstandig' Woningwaardering, 			
			pvo.Ingangsdatum, 
			pvo.[Totaal punten] Totaal_punten, 
			pvo.[Totaal punten afgerond] Totaal_punten_afgerond, 
			round(mhp.[Maximale huurprijs (LV)] + iif(pvo.[Totaal punten afgerond] > 750, pvo.[Totaal punten afgerond] - 750, 0) * ept.puntprijs, 2) [Maximaal toegestane huur],
			round((mhp.[Maximale huurprijs (LV)] + iif(pvo.[Totaal punten afgerond] > 750, pvo.[Totaal punten afgerond] - 750, 0) * ept.puntprijs) * isnull(trm.[Target Rent _], 0) / 100.0, 2) [Streefhuur],
			pvo.[Total Surface], 
			trm.[Target Rent _],
			null energiewaardering, null [EPA-label], null [Energy Index], null Bouwjaar, null [date certificate granted], null [energy points]
		from staedion_dm.Huuraanpassing.[Staedion$Prop_ Valuation (Shared Acc_)] pvo inner join wwd
		on pvo.Eenheidnr_ = wwd.Eenheidnr_ and pvo.Ingangsdatum = wwd.Ingangsdatum and pvo.Volgnummer = wwd.Volgnummer
		inner join staedion_dm.Huuraanpassing.Staedion$oge oge
		on pvo.Eenheidnr_ = oge.Nr_ and oge.Woonruimte = wwd.Woonruimte
		inner join staedion_dm.Huuraanpassing.[Staedion$Maximale huurprijzen] mhp
		on mhp.tabel = 1 and 
		mhp.jaar = year(dateadd(month, -6, @peildatum)) and
		iif(pvo.[Totaal punten afgerond] > 750, 750, pvo.[Totaal punten afgerond]) = mhp.Punten
		inner join ept
		on oge.Woonruimte = ept.Woonruimte
		left outer join staedion_dm.Huuraanpassing.[Staedion$target rent _ max_ reas_ rent] trm
		on oge.[Code huur _ max_ huurprijs]  COLLATE database_default = trm.Code  COLLATE database_default
		where pvo.Eenheidnr_ = @eenheidnr)
select hpr.eenheidnr
		,hpr.huurdernr
		,replace(replace(replace(hpr.Prolongatietermijn, char(5), 'M'), char(6), 'K'), char(7), 'J') Prolongatietermijn
		,convert(decimal(12, 2), hpr.kalehuur) kalehuur
		,convert(decimal(12, 2), hpr.kalehuur_inclbtw) kalehuur_inclbtw
		,convert(decimal(12, 2), hpr.nettohuur) nettohuur
		,convert(decimal(12, 2), hpr.nettohuur_inclbtw) nettohuur_inclbtw
		,iif(hpr.nettohuur = hpr.nettohuur_inclbtw, 'Nee', 'Ja') btw_op_nettohuur
		,convert(decimal(12, 2), hpr.huurkorting) huurkorting
		,convert(decimal(12, 2), hpr.huurkorting_inclbtw) huurkorting_inclbtw
		,convert(decimal(12, 2), coalesce(hpr.nettohuur_inclbtw,0)+coalesce(hpr.huurkorting_inclbtw,0)) as nettohuur_incl_korting_btw
		,convert(decimal(12, 2), hpr.btw_compensatie) btw_compensatie
		,convert(decimal(12, 2), hpr.btw_compensatie_inclbtw) btw_compensatie_inclbtw
		,convert(decimal(12, 2), hpr.verbruikskosten) verbruikskosten
		,convert(decimal(12, 2), hpr.verbruikskosten_inclbtw) verbruikskosten_inclbtw
		,convert(decimal(12, 2), hpr.servicekosten) servicekosten
		,convert(decimal(12, 2), hpr.servicekosten2) servicekosten2
		,convert(decimal(12, 2), hpr.servicekosten_inclbtw) servicekosten_inclbtw
		,convert(decimal(12, 2), hpr.stookkosten) stookkosten
		,convert(decimal(12, 2), hpr.water) water
		,convert(decimal(12, 2), hpr.water_inclbtw) water_inclbtw
		,convert(decimal(12, 2), hpr.brutohuur) brutohuur
		,convert(decimal(12, 2), hpr.brutohuur_inclbtw) brutohuur_inclbtw
		,convert(decimal(12, 2), hpr.subsf) [Subsidiabele energiekosten]
		,convert(decimal(12, 2), iif(hpr.subsf > crg.maxbedrag2f, crg.maxbedrag2f, hpr.subsf)) [Subsidiabele energiekosten afgetopt]
		,convert(decimal(12, 2), hpr.subsg) [Subsidiabele schoonmaakkosten]
		,convert(decimal(12, 2), iif(hpr.subsg > crg.maxbedrag2g, crg.maxbedrag2g, hpr.subsg)) [Subsidiabele schoonmaakkosten afgetopt]
		,convert(decimal(12, 2), hpr.subsh) [Subsidiabele huismeesterkosten]
		,convert(decimal(12, 2), iif(hpr.subsh > crg.maxbedrag2h, crg.maxbedrag2h, hpr.subsh)) [Subsidiabele huismeesterkosten afgetopt] 
		,convert(decimal(12, 2), hpr.subsi) [Subsidiabele kapitaal/onderhoudskosten]
		,convert(decimal(12, 2), iif(hpr.subsi > crg.maxbedrag2i, crg.maxbedrag2i, hpr.subsi)) [Subsidiabele kapitaal/onderhoudskosten afgetopt]
		,convert(decimal(12, 2), iif(hpr.subsf > crg.maxbedrag2f, crg.maxbedrag2f, hpr.subsf) + iif(hpr.subsg > crg.maxbedrag2g, crg.maxbedrag2g, hpr.subsg) + iif(hpr.subsh > crg.maxbedrag2h, crg.maxbedrag2h, hpr.subsh) + iif(hpr.subsi > crg.maxbedrag2i, crg.maxbedrag2i, hpr.subsi)) subsidiabeldeel
		,convert(decimal(12, 2), hpr.nettohuur + iif(hpr.subsf > crg.maxbedrag2f, crg.maxbedrag2f, hpr.subsf) + iif(hpr.subsg > crg.maxbedrag2g, crg.maxbedrag2g, hpr.subsg) + iif(hpr.subsh > crg.maxbedrag2h, crg.maxbedrag2h, hpr.subsh) + iif(hpr.subsi > crg.maxbedrag2i, crg.maxbedrag2i, hpr.subsi)) subsidiabelehuur
		,convert(decimal(12, 2), hpr.markthuur) markthuur
		,sfh.Woningwaardering
		,sfh.[Ingangsdatum]
		,convert(decimal(12, 2), sfh.Totaal_punten) Totaal_punten
		,sfh.Totaal_punten_afgerond
		,convert(decimal(12, 2), sfh.[Maximaal_toegestane_huur]) [Maximaal_toegestane_huur]
		,convert(decimal(12, 2), sfh.totaal_oppervlakte) totaal_oppervlakte
		,convert(decimal(12, 2), sfh.perc_max_red_huur) perc_max_red_huur
		,energiewaardering
		,EPA_label
		,convert(decimal(12, 2), sfh.Energie_index) Energie_index
		,sfh.Bouwjaar
		,sfh.datum_afgemeld
		,convert(decimal(12, 2), sfh.energiepunten) energiepunten
		,dgp.doelgroep
		,dgp.aftopgrens
		,iif(sfh.doelgroep <> '' and 
			isnull(sfh.streefhuur, 0) + (iif(hpr.subsf > crg.maxbedrag2f, crg.maxbedrag2f, hpr.subsf) + iif(hpr.subsg > crg.maxbedrag2g, crg.maxbedrag2g, hpr.subsg) + iif(hpr.subsh > crg.maxbedrag2h, crg.maxbedrag2h, hpr.subsh) + iif(hpr.subsi > crg.maxbedrag2i, crg.maxbedrag2i, hpr.subsi)) * dgp.inclusiefsubsidiabeldeel > dgp.aftopgrens, 
				dgp.aftopgrens - (iif(hpr.subsf > crg.maxbedrag2f, crg.maxbedrag2f, hpr.subsf) + iif(hpr.subsg > crg.maxbedrag2g, crg.maxbedrag2g, hpr.subsg) + iif(hpr.subsh > crg.maxbedrag2h, crg.maxbedrag2h, hpr.subsh) + iif(hpr.subsi > crg.maxbedrag2i, crg.maxbedrag2i, hpr.subsi))* dgp.inclusiefsubsidiabeldeel, sfh.streefhuur) streefhuur_oud
		,convert(decimal(12, 2), sfh.perc_max_red_huur * sfh.[Maximaal_toegestane_huur] / 100.0) streefhuur
		,crg.liberalisatiegrens
from hpr inner join crg crg
on 1 = 1
left outer join sfh
on hpr.eenheidnr = sfh.Eenheidnr
left outer join dgp
on sfh.doelgroep = dgp.doelgroep
GO
