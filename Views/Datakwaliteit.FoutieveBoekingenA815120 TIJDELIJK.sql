SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view  [Datakwaliteit].[FoutieveBoekingenA815120 TIJDELIJK]
as 
/* ##################################################################################################################################################
--------------------------------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'FoutieveBoekingenA815120 TIJDELIJK'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Addextendedproperty   
@name = N'MS_Description',   
@value = N'Tijdelijke query om foutieve boekingen op A815120 op te sporen. 
Bedragen de kosten hoger dan 5000 dan hoort een andere rekening te worden gebruikt: A815130 Dagelijks Groot onderhoud
',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815120 TIJDELIJK'
;
EXEC sys.sp_Addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815120 TIJDELIJK'
;
EXEC sys.sp_Addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from Datakwaliteit.[FoutieveBoekingenA815120 TIJDELIJK] order by Kosten desc',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815120 TIJDELIJK'
;  
EXEC sys.sp_Addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Ja',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815120 TIJDELIJK'
;  
--------------------------------------------------------------------------------------------------------------------------------------------------
ALTERNATIEF
--------------------------------------------------------------------------------------------------------------------------------------------------
--2: Groot Dagelijks Onderhoud
--> Tot 5000
--> Oorzaakcode aanpassen zodat ie van OND-0532 naar OND-06 - fout OND00185684-000
--=> afstemmen met Jos
WITH cte_basis
AS (
       SELECT BASIS.Verzoek
              ,BASIS.[Order]
              ,BASIS.[Taak]
              ,BASIS.[Order - leverancier]
              ,[Leverancier rekening houdend met afhaalorder] = CASE 
                     WHEN BASIS.[Order - leverancier] <> 'LEVE-02164'
                            AND BASIS.[Taak - standaard taakcode] like 'AFHAALORDER%'
                            THEN 'LEVE-02164'
                     ELSE BASIS.[Order - leverancier]
                     END
              ,BASIS.[Taak - bekwaamheidscode]
              ,BASIS.[Taak - standaard taakcode]
              ,BASIS.[Taak - sjablooncode]
              ,BASIS.[Order - status]
              ,BASIS.[Verzoek - datum invoer]
              ,BASIS.[Taak - afgehandeld per]
              ,BASIS.[Order - kostencode]
              ,BASIS.[Taak - kostencode]
              ,[Rekening - kostencode] = (
                     SELECT staedion_inkooprekening
                     FROM empire_staedion_data.dwh.kostensoort
                     WHERE bk_nr_ = BASIS.[Order - kostencode]
                     )
              ,[Max Productboekingsgroep] = (
                     SELECT max([Gen_ Prod_ Posting Group])
                     FROM empire_Data.dbo.Staedion$Job_Ledger_Entry
                     WHERE [Job No_] = BASIS.[Order]
                     )
              ,[Aantal verschillende productboekingsgroepen] = (
                     SELECT count(DISTINCT [Gen_ Prod_ Posting Group])
                     FROM empire_Data.dbo.Staedion$Job_Ledger_Entry
                     WHERE [Job No_] = BASIS.[Order]
                     )
              ,[Boekdatum order] = (
                     SELECT max([Posting Date])
                     FROM empire_Data.dbo.Staedion$Job_Ledger_Entry
                     WHERE [Job No_] = BASIS.[Order]
                     )
              --,[Kosten order] = convert(FLOAT, coalesce((
              --                     SELECT sum([Total Cost (LCY)])
              --                     FROM empire_Data.dbo.Staedion$Job_Ledger_Entry
              --                     WHERE [Job No_] = BASIS.[Order]
              --                     ), 0))
              ,[Kosten totale verzoek] = convert(FLOAT, coalesce((
                                   SELECT sum([Total Cost (LCY)])
                                   FROM empire_Data.dbo.Staedion$Job_Ledger_Entry
                                   WHERE [Maintenance Request No_] = BASIS.Verzoek
                                   ), 0))
              ,[Opbrengsten totale verzoek] = convert(FLOAT, coalesce((
                                   SELECT sum(iif(JLE.[Entry Type] = 1, jle.[Total Cost (LCY)] + jle.[Total Price (LCY)], 0))
                                   FROM empire_Data.dbo.Staedion$Job_Ledger_Entry AS JLE
                                   WHERE [Maintenance Request No_] = BASIS.Verzoek
                                   ), 0))
       FROM empire_Dwh.dbo.[ITVF_npo_regels]('Afgerond', '20210101', DEFAULT, 0, DEFAULT) AS BASIS --'OND00096166-000' )  as BASIS
       --WHERE BASIS.Verzoek = 'OND00185684-000'
              --where BASIS.[Order - kostencode] = 'OND-0532'
       )
--SELECT *
--FROM cte_basis
--WHERE [Kosten totale verzoek] >= 5000
--       AND year([Boekdatum order]) >= 2021
--			 and [Rekening - kostencode] in ('A815120 Reparaties en vandalisme')
--UNION
SELECT *
FROM cte_basis
WHERE [Kosten totale verzoek] >= 5000
       AND year([Boekdatum order]) >= 2021
			 and [Rekening - kostencode] in  ('A815120 Reparaties en vandalisme')

################################################################################################################################################## */


with cte_laaddatum (Laaddatum) as 
(select Laaddatum from [staedion_dm].[Algemeen].[Laaddatum]	
)
SELECT [Verzoeknr] = V.bk_no_
	,[Ordernr] = O.bk_no_
	,P.Datum
	,P.Factuur
	,P.Kosten
	,P.[Rekeningnr geboekt]
	,P.[Sjabloon inkooprekening]
	,P.[Sjablooncode taak]
	,P.[REP Taak]
	,P.eenheid
	,P.Adres
	,[Hyperlink verzoek] = empire_staedion_data.empire.fnEmpireLink('Staedion', 11031240, 'No.=''' + V.bk_no_ + '''', 'view')
	,Gegenereerd = T.laaddatum
--	,[Hyperlink verzoek NOT YET] = '=HYPERLINK('+ empire_staedion_data.empire.fnEmpireLink('Staedion', 11031240, 'No.=''' + V.bk_no_ + '''', 'view') + ';'+ V.bk_no_  + ')'
-- select sum(P.Kosten)
FROM empire_dwh.dbo.tmv_npo_projectpost AS P
LEFT OUTER JOIN empire_dwh.dbo.npo_verzoek AS V ON V.id = P.Sleutel_verzoek
LEFT OUTER JOIN empire_dwh.dbo.npo_order AS O ON O.id = P.Sleutel_order
LEFT OUTER JOIN cte_laaddatum as T on 1=1
WHERE year(P.datum) = 2021
	AND P.[Rekeningnr geboekt] = 'A815120'
	AND V.bk_no_ in (select V_kopie.bk_no_ from empire_dwh.dbo.npo_verzoek as V_kopie group by V_kopie.bk_no_ having sum(V_kopie.staedion_geboekte_kosten)>5000)
-- and V.bk_no_ = 'OND00191971-000'
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'FoutieveBoekingenA815120 TIJDELIJK', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Ja', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'FoutieveBoekingenA815120 TIJDELIJK', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tijdelijke query om foutieve boekingen op A815120 op te sporen. 
Bedragen de kosten hoger dan 5000 dan hoort een andere rekening te worden gebruikt: A815130 Dagelijks Groot onderhoud
', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'FoutieveBoekingenA815120 TIJDELIJK', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from Datakwaliteit.[FoutieveBoekingenA815120 TIJDELIJK] order by Kosten desc', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'FoutieveBoekingenA815120 TIJDELIJK', NULL, NULL
GO
