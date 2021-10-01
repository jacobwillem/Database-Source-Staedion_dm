SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [RekeningCourant].[vw_Betalingsregelingen]
AS
/* #########################################################################################################################################
VAN		Jaco van der Wel
DOEL	View over onderliggende tabel heen ter vergemakkelijking van PBI-rapportages
--------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------------------
20210920 JvdW 


--------------------------------------------------------------------------------------------------------------------------------------------
TESTEN
--------------------------------------------------------------------------------------------------------------------------------------------
-- 1: beginstand + aangemaakt - afgerond = eindstand
-- 2: eindstand vorige periode = beginstand huidige periode
SELECT Peildatum
       ,Beginstand = sum(Beginstand)
       ,Aangemaakt = sum(Aangemaakt)
       ,Afgerond = sum(Afgerond)
       ,Eindstand = sum(Eindstand)
			 -- select min(Peildatum)
			 -- select top 10 *
FROM [staedion_dm].[RekeningCourant].[vw_Betalingsregelingen]
where Peildatum >= '20208131' 
GROUP BY Peildatum
order by Peildatum desc
;

SELECT Peildatum
       ,Aangemaakt = sum(Aangemaakt)
FROM [staedion_dm].[RekeningCourant].[vw_Betalingsregelingen]
where Peildatum >= '20210101' 
and Aangemaakt = 1
group by Peildatum
order by Peildatum


--------------------------------------------------------------------------------------------------------------------------------------------
STEEKPROEF
--------------------------------------------------------------------------------------------------------------------------------------------

-- STEEKPROEF
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Nr as nvarchar(20) = 'BETR-1100729'
set @Nr = 'BETR-1803976'
set @Nr = 'BETR-2001611'
set @Nr = 'BETR-2101706'
set @nr = 'BETR-2102078' --,'BETR-2102149','BETR-2102063')'
Declare @Peildatum as date = '20210831'

-- bronbestand Empire
select btr.*
  FROM [empire_data].[dbo].[Staedion$Payment_Scheme] as btr
            INNER JOIN [empire_data].[dbo].[Staedion$Payment_Scheme_Line] reg
                ON btr.Code = reg.Code
        WHERE btr.[Termination Code] NOT IN ( 'FB' )
				and btr.Code = @Nr
				and btr.[Posting Date] <= @Peildatum
;
-- stand door de maanden heen
SELECT Peildatum
       ,Beginstand = sum(Beginstand)
       ,Aangemaakt = sum(Aangemaakt)
       ,Afgerond = sum(Afgerond)
       ,Eindstand = sum(Eindstand)
			 -- select min(Peildatum)
			 -- select top 10 *
FROM [staedion_dm].[RekeningCourant].[vw_Betalingsregelingen]
where Betalingsregelingnr = @Nr
GROUP BY Peildatum
order by Peildatum desc
;

-- view
select top 10 *
FROM [staedion_dm].[RekeningCourant].[vw_Betalingsregelingen]
where Betalingsregelingnr = @Nr
;
-- tabel
select Betalingsregelingnr,*
FROM [staedion_dm].[RekeningCourant].[Betalingsregelingen]
where   Betalingsregelingnr = @Nr
;
-- bron
select btr.*
  FROM [empire_data].[dbo].[Staedion$Payment_Scheme] as btr
            INNER JOIN [empire_data].[dbo].[Staedion$Payment_Scheme_Line] reg
                ON btr.Code = reg.Code
        WHERE btr.[Termination Code] NOT IN ( 'FB' )
				and btr.Code = @Nr
;

--------------------------------------------------------------------------------------------------------------------------------------------
Vergelijk CNS: gestart in maand 
--------------------------------------------------------------------------------------------------------------------------------------------
select Betalingsregelingnr = BTR.bk_code
--select  ST.*, BTR.bk_code, BTR.aantal_termijnen, BTR.totaalbedrag, BTR.staed_laatste_vervaldatum, BTR.dt_document, BTR.boekdatum,*
-- select distinct ST.*
from empire_dwh.dbo.d_betalingsregeling as D
join empire_dwh.dbo.statusbetalingsregeling as ST
on ST.id = D.fk_statusbetalingsregeling_id_betalingsregeling
join empire_dwh.dbo.betalingsregeling as BTR 
on BTR.id = D.fk_betalingsregeling_id
where D.Datum = '20210831'
and ST.descr in ('Gestart en beëindigd','Gestart')
and BTR.bk_code in ('BETR-2102358','BETR-2102136','BETR-2102054','BETR-2102310','BETR-2102097')
and BTR.fk_redenbeeindiging_id <> 'FB'
except
select Betalingsregelingnr ,*
FROM [staedion_dm].[RekeningCourant].[vw_Betalingsregelingen]
where Peildatum = '20210831' 
and Aangemaakt = 1
and Betalingsregelingnr in ('BETR-2102358','BETR-2102136','BETR-2102054','BETR-2102310','BETR-2102097')
;

--------------------------------------------------------------------------------------------------------------------------------------------
Eindstand vs beginstand
--------------------------------------------------------------------------------------------------------------------------------------------
-- 245 eindstand 
select Betalingsregelingnr, [Aanmaakdatum] , [Einddatum]--, ST.Omschrijving,BASIS.Rapportagestatus_id, Peildatum
from [staedion_dm].[RekeningCourant].[Betalingsregelingen] AS BASIS
left outer join [staedion_dm].[RekeningCourant].[Rapportagestatus] as ST 
on ST.Rapportagestatus_id = BASIS.Rapportagestatus_id
							WHERE  Peildatum = '20210831' 
					 	and BASIS.Rapportagestatus_id IN (1,2)
						--	and BASIS.Betalingsregelingnr = @Nr
EXCEPT
-- 1090 beginstand februari
select Betalingsregelingnr, [Aanmaakdatum] , [Einddatum] -- , ST.Omschrijving, BASIS.Rapportagestatus_id, Peildatum
from [staedion_dm].[RekeningCourant].[Betalingsregelingen] AS BASIS
left outer join [staedion_dm].[RekeningCourant].[Rapportagestatus] as ST 
on ST.Rapportagestatus_id = BASIS.Rapportagestatus_id
							WHERE  Peildatum = '20210430' 
						 and BASIS.Rapportagestatus_id IN (2, 3)
							and BASIS.Betalingsregelingnr = @Nr
;



########################################################################################################################################## */
WITH cte_contract_zittend ([Customer No_])
AS (
       SELECT adi.[Customer No_]
       FROM empire_data.[dbo].[Staedion$Additioneel] adi
       WHERE adi.Ingangsdatum <= GETDATE()
              AND (
                     adi.Einddatum = '1753-01-01'
                     OR adi.Ingangsdatum >= GETDATE()
                     )
       GROUP BY adi.[Customer No_]
       )
-- toevoegen huidige status huurder ?
SELECT DISTINCT BETR.Peildatum
       ,FORMAT(BETR.peildatum, 'yyyy MMMM', 'nl-NL') AS Rapportagemaand
       ,BETR.Betalingsregelingnr
       ,BETR.[Klantnr]
       ,Klantnaam = BETR.[Klant naam]
       ,BETR.Boekingsdatum
			 ,BETR.Documentdatum
       ,BETR.Einddatum
       ,BETR.[Bedrag betalingsregeling] -- = SUM(BETR.[Bedrag betalingsregeling])
       ,BETR.Deurwaarderszaak
       ,BETR.Derdendossier
       ,BETR.Leefbaarheidsdossier
       ,BETR.[Betaalwijze huur]
       ,BETR.[Betaalwijze regeling]
       ,BETR.[Klachtstatus CM]
       ,BETR.[Openstaand saldo]
       ,BETR.[Afsluitreden]
       ,BETR.[Klant status]
       ,BETR.Rapportagestatus_id
       ,[Huidige status klant] = iif(CONTR.[Customer No_] IS NULL, 'Vertrokken', 'Zittend')
       ,Beginstand = IIF(BETR.Rapportagestatus_id IN (
                     2
                     ,3
                     ), 1, 0)
       ,Aangemaakt = IIF(BETR.Rapportagestatus_id IN (
                     1
                     ,4
                     ), 1, 0)
       ,Afgerond = IIF(BETR.Rapportagestatus_id IN (
                     3
                     ,4
                     ), 1, 0)
       ,Eindstand = IIF(BETR.Rapportagestatus_id IN (
                     1
                     ,2
                     ), 1, 0)
			 ,Termijnen
       ,[Categorie termijnen] = CASE 
              WHEN Coalesce(Termijnen,0) <= 0
                     THEN 'geen termijnen'
              ELSE CASE 
                            WHEN Termijnen <= 1
                                   THEN '1 termijn'
                            ELSE CASE 
                                          WHEN Termijnen < 4
                                                 THEN '2-3 termijnen'
                                          ELSE CASE 
                                                        WHEN Termijnen < 7
                                                               THEN '4-6 termijnen'
                                                        ELSE CASE 
                                                                      WHEN Termijnen < 13
                                                                             THEN '7-12 termijnen'
																																						 ELSE '13+ termijnen'
                                                                      END
                                                        END
                                          END
                            END
              END
       ,[Categorie termijnen sortering] = CASE 
              WHEN Coalesce(Termijnen,0) <= 0
                     THEN 1
              ELSE CASE 
                            WHEN Termijnen <= 1
                                   THEN 2
                            ELSE CASE 
                                          WHEN Termijnen < 4
                                                 THEN 3
                                          ELSE CASE 
                                                        WHEN Termijnen < 7
                                                               THEN 4
                                                        ELSE CASE 
                                                                      WHEN Termijnen < 13
                                                                             THEN 5
																																						 ELSE 6
                                                                      END
                                                        END
                                          END
                            END
              END
-- select count(*), count(distinct convert(nvarchar(20),Peildatum,105) + '|' + Betalingsregelingnr)
-- select BETR.*
FROM [staedion_dm].[RekeningCourant].[Betalingsregelingen] AS BETR
LEFT OUTER JOIN cte_contract_zittend AS CONTR
       ON BETR.Klantnr = CONTR.[Customer No_]
              --WHERE Peildatum = '20210131'
              --GROUP BY BETR.Peildatum
              --		,FORMAT(BETR.peildatum, 'yyyy MMMM', 'nl-NL')
              --		,BETR.Betalingsregelingnr
              --		--,BETR.[Klant naam]
              --		,BETR.[Klantnr]
              --		,BETR.Aanmaakdatum
              --		,BETR.Einddatum
              --		,BETR.[Klant status]
              --		,BETR.Rapportagestatus_id
              --		,CONTR.[Customer No_]
GO
