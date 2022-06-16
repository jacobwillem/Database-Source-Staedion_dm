SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view  [Datakwaliteit].[vw_FoutieveBoekingenA815360 TIJDELIJK]
as 
/* ##################################################################################################################################################
--------------------------------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'FoutieveBoekingenA815360 TIJDELIJK'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Updateextendedproperty   
@name = N'MS_Description',   
@value = N'Tijdelijke query om foutieve boekingen op A815360 op te sporen. Als dit na T1 2021 niet meer speelt kan deze query weggegooid worden.
Controle-rapport:
We komen kosten op A815360 aangemaakt met sjabloon ASBEST_INVENT die vreemd genoeg niet naar A021306 (R-100007) 
zijn gestuurd maar naar A815360. Idem kosten in 2021 voor oude sjablooncode R0012. Dat zou ASBEST_SAN_HERST moeten zijn en dan had ik naar A021306 gegaan.
A815360 ASBEST_INVENT
A815360 R0012',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815360 TIJDELIJK'
;
EXEC sys.sp_Updateextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815360 TIJDELIJK'
;
EXEC sys.sp_Updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from Datakwaliteit.[FoutieveBoekingenA815360 TIJDELIJK] order by Kosten desc',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815360 TIJDELIJK'
;  
EXEC sys.sp_Updateextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Ja',   
@level0type = N'SCHEMA', @level0name = 'Datakwaliteit',  
@level1type = N'VIEW',  @level1name = 'FoutieveBoekingenA815360 TIJDELIJK'
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
	AND P.[Rekeningnr geboekt] = 'A815360'
	AND (
		P.[Sjablooncode taak] IN (
			'ASBEST_INVENT'
			,'R0012'
			)
		OR coalesce(P.[Sjabloon inkooprekening], 'A815360') <> 'A815360'
		)

GO
