SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view  [Datakwaliteit].[vw_FoutieveBoekingenA815120 TIJDELIJK]
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
WHERE year(P.datum) >= 2022
	AND P.[Rekeningnr geboekt] = 'A815120'
	AND V.bk_no_ in (select V_kopie.bk_no_ from empire_dwh.dbo.npo_verzoek as V_kopie group by V_kopie.bk_no_ having sum(V_kopie.staedion_geboekte_kosten)>5000)
-- and V.bk_no_ = 'OND00191971-000'
GO
