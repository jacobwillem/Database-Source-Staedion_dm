SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [Eenheden].[fn_Kernvoorraad] (@Peildatum date = null) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Proefopzet om de kernvoorraad voor Den Haag te berekenen zonder gebruik te maken van dwh-gegevens (zoals bbsh-klasse / nettohuur)
ZIE         : ...
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: 20200608 Tbv voorraadrapportage CNS / O&V
Versie 2: 20210311 Nav overleg met Margot+Hailey
	NB: definitie moet nog worden aangepast: alleen eenheden van niet-geliberaliseerde contracten kunnen meegeteld worden in de kernvoorraad als ze nu een huurprijs hebben die boven de liberalisatiegrens zit maar wel een doelgroepcode onder deze grens
	NB: ingangsdatum contract hoeft niet als aparte conditie te worden opgenomen in deze voorwaarde 
> gemakshalve nu alle doelgroepen meegenomen omdat deze allemaal sociaal zijn
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
-- dubbelen mogen niet voorkomen
SELECT count(*) ,count(DISTINCT Eenheidnr)
FROM staedion_dm.Eenheden.[fn_Kernvoorraad TEST]('20190101')
;
SELECT '20190101'
       ,[Kernvoorraad]
			 ,Opmerking
       ,[Aantal kernvoorraad] = sum([Kernvoorraad])
       ,[Check max netto huur] = max([Netto huur])
-- select top 10 *
FROM staedion_dm.Eenheden.[fn_Kernvoorraad TEST]('20190101')
where Plaats = 'DEN HAAG'
and [Kernvoorraad] = 1
GROUP BY [Kernvoorraad],Opmerking
;
SELECT '20200101'
       ,[Kernvoorraad]
			 ,Opmerking
       ,[Aantal kernvoorraad] = sum([Kernvoorraad])
       ,[Check max netto huur] = max([Netto huur])
-- select top 10 *
FROM staedion_dm.Eenheden.[fn_Kernvoorraad TEST]('20200101')
where Plaats = 'DEN HAAG'
and [Kernvoorraad] = 1
GROUP BY [Kernvoorraad],Opmerking
;
SELECT '20200701'
       ,[Kernvoorraad]
			 ,Opmerking
       ,[Aantal kernvoorraad] = sum([Kernvoorraad])
       ,[Check max netto huur] = max([Netto huur])
-- select top 10 *
FROM staedion_dm.Eenheden.[fn_Kernvoorraad TEST]('202001701')
where Plaats = 'DEN HAAG'
and [Kernvoorraad] = 1
GROUP BY [Kernvoorraad],Opmerking


select * FROM staedion_dm.Eenheden.[fn_Kernvoorraad TEST]('20200101') 
union
select * FROM staedion_dm.Eenheden.[fn_Kernvoorraad TEST]('20200701') 


------------------------------------------------------------------------------------------------------
TEMP                   
------------------------------------------------------------------------------------------------------
-- CNS obv data uit dwh over snapshotperiodes van de laatste 2 jaar
select count(*),min(datum),max(datum) from staedion_dm.Algemeen.[Eenheid meetwaarden]
select datum,count(*) from staedion_dm.Algemeen.[Eenheid meetwaarden] group by datum

	-- 1.126.210
	-- 0:07
	select
		[Datum]                           = db.datum,
		[Sleutel eenheid]                 = db.fk_eenheid_id,
		[Sleutel huurklasse]              = db.fk_bbshklasse_id_eenheid
	from empire_dwh.dbo.d_bestand as db
	inner join empire_dwh.dbo.eenheid as e on 
		e.id = db.fk_eenheid_id and
		db.datum between e.dt_in_exploitatie and isnull(e.dt_uit_exploitatie, '99991231')
	left join empire_dwh.dbo.bbshklasse bbs on
		getdate() between bbs.vanaf and bbs.tot and
		isnull(db.kalehuur,0) between bbs.minimum and bbs.maximum 
	left join empire_dwh.dbo.bbshklasse bbk on
		getdate() between bbk.vanaf and bbk.tot and
		isnull(db.streefhuur,0) between bbk.minimum and bbk.maximum 
	left join empire_dwh.dbo.bbshklasse bbss on
		bbss.id = db.fk_bbshklasse_id_eenheid
	where db.datum > dateadd(yy,-2,getdate())
	and e.da_bedrijf = 'Staedion' 

-- Methode 1
	select distinct datum from staedion_dm.Algemeen.[Eenheid meetwaarden]

	drop table if exists empire_staedion_data.bak.kernvoorraad;
	select * into empire_staedion_data.bak.kernvoorraad from staedion_dm.dbo.ITVF_Kernvoorraad ('20190101');
	insert into empire_staedion_data.bak.kernvoorraad select * from staedion_dm.dbo.ITVF_Kernvoorraad ('20200101');
	insert into empire_staedion_data.bak.kernvoorraad select * from staedion_dm.dbo.ITVF_Kernvoorraad ('20200701');

	update  empire_staedion_data.bak.kernvoorraad 
	set			[Telt mee voor kernvoorraad] =  1
					,Opmerking = 'Kernvoorraad - nu boven grens na mutatie niet meer'
	where		[Corpodatatype] = 'WON ZELF'
	and			[Geliberaliseerd contract] = 'Nee'
	and			[Huurprijsklasse corpodata] = 'Duur boven hoogste grens'	
	and			nullif(Doelgroepcode,'') is not null		
	and			Plaats = 'DEN HAAG'
	;
	select  * 
	from		empire_staedion_data.bak.kernvoorraad
	where		Corpodatatype like '%WON%'
	and			Plaats = 'DEN HAAG'


	update  empire_staedion_data.bak.kernvoorraad 
	set			[Telt mee voor kernvoorraad] = 1 
					,Opmerking = 'Kernvoorraad - nu boven grens na mutatie niet meer'
	where		[Corpodatatype] = 'WON ZELF'
	and			[Geliberaliseerd contract] = 'Nee'
	and			[Huurprijsklasse corpodata] = 'Duur boven hoogste grens'	
	and			nullif(Doelgroepcode,'') is not null		
	and			Plaats = 'DEN HAAG'
	;

	select  Peildatum = convert(nvarchar(20),BASIS.Peildatum,105)
					, [Sleutel eenheid] = DWH.id
					, [Sleutel huurklasse] = BASIS.[Sleutel huurklasse]
					, BASIS.Eenheidnr
					, BASIS.[Netto huur]
					, BASIS.Plaats
					, BASIS.Gemeente
					, BASIS.Corpodatatype
					, BASIS.[Geliberaliseerd contract]
					, BASIS.[Jaar contract]
					, BASIS.[Doelgroepcode]
					, BASIS.[Verhuurteam]
					, BASIS.[Huurprijsklasse corpodata]
					, BASIS.[Telt mee voor kernvoorraad]
					, BASIS.Streefhuur
					, Opmerking
	from empire_staedion_data.bak.ff_kernvoorraad2 as BASIS
	left outer join empire_dwh.dbo.eenheid as DWH
	on DWH.bk_nr_ = BASIS.eenheidnr
	where Plaats = 'DEN HAAG'  
	and Gemeente = '0518'
	;
	update  empire_staedion_data.bak.ff_kernvoorraad2 
	set			[Telt mee voor kernvoorraad] =  1
					,Opmerking = 'Kernvoorraad - nu boven grens na mutatie niet meer'
	where		[Corpodatatype] = 'WON ZELF'
	and			[Geliberaliseerd contract] = 'Nee'
	and			[Huurprijsklasse corpodata] = 'Duur boven hoogste grens'	
	and			[Streefhuur] <= 737.14
	--and			BASIS.[Jaar contract] <=2016
	--and			nullif(Doelgroepcode,'') is not null		
	and			Plaats = 'DEN HAAG'
	;

	select  Peildatum = convert(nvarchar(20),BASIS.Peildatum,105)
					, [Sleutel eenheid] = DWH.id
					, [Sleutel huurklasse] = BASIS.[Sleutel huurklasse]
					, BASIS.Eenheidnr
					, BASIS.[Netto huur]
					, BASIS.Plaats
					, BASIS.Gemeente
					, BASIS.Corpodatatype
					, BASIS.[Geliberaliseerd contract]
					, BASIS.[Jaar contract]
					, BASIS.[Doelgroepcode]
					, BASIS.[Verhuurteam]
					, BASIS.[Huurprijsklasse corpodata]
					, BASIS.[Telt mee voor kernvoorraad]
					, BASIS.Streefhuur
					, Opmerking
	from empire_staedion_data.bak.ff_kernvoorraad2 as BASIS
	left outer join empire_dwh.dbo.eenheid as DWH
	on DWH.bk_nr_ = BASIS.eenheidnr
	where Plaats = 'DEN HAAG'  
	and Gemeente = '0518'
	;
------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Eenheden', 'fn_Kernvoorraad TEST'

################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
       SELECT		Laaddatum = Datum 
								,Peildatum = coalesce(@Peildatum,getdate())
                --,Huurverhogingsdatum = datefromparts(year(coalesce(@Peildatum,getdate())), 7, 1) 
       FROM empire_dwh.dbo.tijd
       WHERE [last_loading_day] = 1
       )
       ,cte_verhuurteam
AS (
       SELECT Verhuurteam = staedion_verhuurteam
              ,Eenheidnr = bk_nr_
       FROM empire_dwh.dbo.eenheid
       WHERE da_bedrijf = 'Staedion'
       )
       ,cte_huurgrenzen
AS (
       SELECT vanaf
              ,tot
              ,minimum
              ,maximum
              ,geliberaliseerd
              ,huurprijsklasse_corpo_descr
							,id
       FROM staedion_dm.Algemeen.[Huurklasse]
       --WHERE geliberaliseerd = 'Geliberaliseerd'
       )
       ,cte_contract
AS (
       SELECT Eenheidnr = eenheidnr_
              ,Huurprijsliberalisatie
              ,Huurdernr = [Customer No_]
       FROM empire_data.dbo.Staedion$Contract
       WHERE [Dummy Contract] = 0
              AND iif(Ingangsdatum = '17530101', '20990101',Ingangsdatum)  <= (select Peildatum from CTE_peildata)
              AND iif(Einddatum = '17530101', '20990101', Einddatum) >= (select Peildatum from CTE_peildata)
       )
       ,cte_additioneel
AS (
       SELECT Eenheidnr = Eenheidnr_
              ,Ingangsdatum = Ingangsdatum
              ,Einddatum
              ,Huurdernr = [Customer No_]
              ,VolgnrContract = row_number() OVER (
                     PARTITION BY Eenheidnr_
                     ,[Customer No_] ORDER BY Ingangsdatum ASC
                     )
       FROM empire_Data.dbo.[staedion$Additioneel]
       WHERE [Customer No_] <> ''
			 and iif(Ingangsdatum = '17530101', '20990101',Ingangsdatum)  <= (select Peildatum from CTE_peildata)
			 and iif(Einddatum = '17530101', '20990101', Einddatum) >= (select Peildatum from CTE_peildata)
       )
-- afwijkingen tussen gemeentecode, gemeentenaam, Plaats 
SELECT  Opmerking = 
							case when CTE_H.huurprijsklasse_corpo_descr <> 'Duur boven hoogste grens'
														and TT.[Analysis Group Code] like '%WON%'	
														--and BRONOGE.Plaats = 'DEN HAAG'
									then 'Kernvoorraad - oude netto huur onder liberalisatiegrens'
									else case when CTE_H.huurprijsklasse_corpo_descr = 'Duur boven hoogste grens'
														and TT.[Analysis Group Code] like '%WON%'
														--and BRONOGE.Plaats = 'DEN HAAG'
														--and CTE_C.Huurprijsliberalisatie = 0 
														and nullif(BRONOGE.[Target Group Code],'') is not null	
														--and  (year(CTE_A.Ingangsdatum) <= 2016 or year(CTE_A.Ingangsdatum) is null)
														then 'Kernvoorraad IAH - nu boven grens na mutatie niet meer'
														else 'Geen kernvoorraad' end end
			 ,Kernvoorraad = 
							case when CTE_H.huurprijsklasse_corpo_descr <> 'Duur boven hoogste grens'
														and TT.[Analysis Group Code] like '%WON%'									
														--and BRONOGE.Plaats = 'DEN HAAG'
									then 1 
									else case when CTE_H.huurprijsklasse_corpo_descr = 'Duur boven hoogste grens'
														and TT.[Analysis Group Code] like '%WON%'					
														and BRONOGE.Plaats = 'DEN HAAG'
														and CTE_C.Huurprijsliberalisatie = 0												-- geliberaliseerde contracten uitsluiten
														and nullif(BRONOGE.[Target Group Code],'') is not null								-- geen vrije sector
														--and (year(CTE_A.Ingangsdatum) <= 2016 or year(CTE_A.Ingangsdatum) is null)												-- tot en met 2016 kon er sprake zijn van inkomensafhankelijke hvh
														then 1
														else 0 end end
       ,Eenheidnr = BRONOGE.Nr_
       ,[Netto huur] = ITVF1.nettohuur
	   ,Streefhuur = convert(decimal(12,2),null)
       ,Plaats = BRONOGE.Plaats
       ,Gemeente = BRONOGE.[Municipality Code]
       ,Corpodatatype = TT.[Analysis Group Code]
       ,[Geliberaliseerd contract] = iif(CTE_C.Huurprijsliberalisatie = 1, 'Ja', 'Nee')
       ,[Jaar contract] = year(CTE_A.Ingangsdatum)
       ,Doelgroepcode = BRONOGE.[Target Group Code]
       ,CTE_V.Verhuurteam
       ,[Huurprijsklasse corpodata] = CTE_H.huurprijsklasse_corpo_descr
		,Peildatum = CTE_P.Peildatum
		,[Sleutel huurklasse] = CTE_H.id
FROM Empire_data.dbo.Staedion$OGE AS BRONOGE																											-- brontabel Empire, andere bedrijven doen niet mee
JOIN CTE_peildata AS CTE_P
       ON 1 = 1
LEFT OUTER JOIN empire_Data.dbo.Staedion$Type AS TT
       ON TT.[Code] = BRONOGE.[Type]
              AND TT.Soort <> 2 -- conform filter in Empire collectief object
LEFT OUTER JOIN cte_contract AS CTE_C																															-- voor ophalen vinkje geliberaliseerd contract
       ON CTE_C.Eenheidnr = BRONOGE.Nr_
LEFT OUTER JOIN cte_additioneel AS CTE_A																													-- voor ophalen ingangsdatum huurcontract
       ON CTE_A.Eenheidnr = BRONOGE.Nr_
              AND CTE_A.Huurdernr = CTE_C.Huurdernr
OUTER APPLY empire_staedion_data.dbo.ITVfnHuurprijs(BRONOGE.Nr_, CTE_P.Peildatum) AS ITVF1				-- voor berekening nettohuur obv empire_data
LEFT OUTER JOIN cte_huurgrenzen AS CTE_H
       ON CTE_P.Peildatum BETWEEN CTE_H.vanaf
                     AND dateadd(d,-1,CTE_H.tot) -- bbsh-tabel: van 01-01-jjjj tm 01-01-jjjjj
              AND ITVF1.nettohuur BETWEEN CTE_H.minimum
                     AND CTE_H.maximum
LEFT OUTER JOIN cte_verhuurteam AS CTE_V																													-- check voor vrije sector woningen
       ON CTE_V.Eenheidnr = BRONOGE.Nr_
WHERE BRONOGE.[Common Area] = 0 -- geen collectieve objecten
       AND iif(BRONOGE.[Begin Exploitatie] = '17530101', '20990101', BRONOGE.[Begin Exploitatie]) <=  CTE_P.Peildatum 
       AND  iif(BRONOGE.[Einde exploitatie] = '17530101', '20990101', BRONOGE.[Einde exploitatie]) >= CTE_P.Peildatum 
       --AND TT.[Analysis Group Code] LIKE '%WON%'
       --AND upper(BRONOGE.Plaats) = 'DEN HAAG'
 
GO
