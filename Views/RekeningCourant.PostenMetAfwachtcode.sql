SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [RekeningCourant].[PostenMetAfwachtcode] as
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
20210129 Ter vervanging van DWEX rapportage Huurders met afwachtcode
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'RekeningCourant', 'PostenMetAfwachtcode'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'Toont huidige regels in rekening-courant die openstaan en een afwachtcode hebben. Voorheen was hiervoor een noodzakelijk geachte dwex-rapportage voor. ',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.[RekeningCourant].[PostenMetAfwachtcode]',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee (wel empire_data)',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode'

-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Code zoals terug te vinden is in rekening-courant van de klant ',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Afwachtcode';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Zie klantkaart',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Huurdernaam';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Zie klantkaart',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Klantboekingsgroep';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Zie klantkaart',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Klantnr';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Nog toekomstige verplichtingen vanwege betalingsregeling ? Opgehaald met behulp van functie fnRekeningCourant',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Lopende betalingsregeling ?';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Ja als er nog niet-afgesloten deurwaarderdossiers zijn. Opgehaald met behulp van functie fnRekeningCourant',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Lopende deurwaarderszaak ?';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Saldo van betreffende huurder per laaddatum van het rapport',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Openstaand saldo';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Zoals in Empire ook terug te vinden is in betreffende rekening-courant-post',   
@level0type = N'SCHEMA', @level0name = 'RekeningCourant',  
@level1type = N'VIEW',  @level1name = 'PostenMetAfwachtcode',
@level2type = N'Column',@level2name = 'Omschrijving afwachtcode';
;  
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
select * from staedion_dm.[RekeningCourant].[PostenMetAfwachtcode]

--------------------------------------------------------------------------------------------------------------------------
ALTERNATIEVE OPZET QUERY
--------------------------------------------------------------------------------------------------------------------------
SELECT Bedrijf = 'Staedion'
	,Klantnr = CLE.[Customer No_]
	,Klantboekingsgroep = CUS.[Customer Posting Group]
	,[Openstaand bedrag] = convert(DECIMAL(12, 2), sum(iif(DCL.[Posting Date] <= getdatE(), DCL.amount, 0)))
	,CLE.[On Hold]
	,[Lopende deurwaarderszaak ?] = INFO.deurwaarder
	,[Lopende deurwaarderszaak ?] = iif(INFO.regelingen IS NOT NULL, 'Ja', 'Nee')
	,Huurder = HRD.huurder1
	,[Openstaand saldo] = INFO.openstaand_saldo
FROM empire_data.dbo.Staedion$Cust__Ledger_Entry AS CLE --empire_data.dbo.mg_cust_ledger_entry  as CLE
INNER JOIN empire_data.dbo.Staedion$Detailed_Cust__Ledg__Entry AS DCL -- empire_Data.dbo.mg_detailed_cust_ledg_entry as DCL ON CLE.mg_bedrijf = DCL.mg_bedrijf
	ON CLE.[Entry No_] = DCL.[Cust_ Ledger Entry No_]
INNER JOIN empire_data.dbo.Customer AS CUS ON CLE.[Customer No_] = CUS.[No_]
CROSS APPLY empire_staedion_data.[dbo].[fnRekeningCourant](CLE.[Customer No_], getdate()) AS INFO
CROSS APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(CLE.[Customer No_]) AS HRD
WHERE CUS.[Customer Posting Group] IN (
		'HUURDERS'
		,'DEB.ENERGI'
		,'DEB.HANDEL')
	--AND INFO.openstaand_saldo <> 0
	AND CLE.[On Hold] <> ''
	AND CLE.[Open] = 1
GROUP BY CLE.[Customer No_]
	,CUS.[Customer Posting Group]
	,CLE.[On Hold]
	,INFO.deurwaarder
	,INFO.regelingen
	,HRD.huurder1
################################################################################################################################## */    
WITH cte_details
AS (
	SELECT [Openstaand bedrag] = convert(DECIMAL(12, 2), sum(iif(DCL.[Posting Date] <= getdate(), DCL.amount, 0)))
		,Afwachtcode = CLE.[On Hold]
		,Klantnr = CLE.[Customer No_]
	FROM empire_data.dbo.Staedion$Cust__Ledger_Entry AS CLE --empire_data.dbo.mg_cust_ledger_entry  as CLE
	INNER JOIN empire_data.dbo.Staedion$Detailed_Cust__Ledg__Entry AS DCL -- empire_Data.dbo.mg_detailed_cust_ledg_entry as DCL ON CLE.mg_bedrijf = DCL.mg_bedrijf
		ON CLE.[Entry No_] = DCL.[Cust_ Ledger Entry No_]
	WHERE CLE.[On Hold] <> ''
		AND CLE.[Open] = 1
    group by CLE.[Customer No_], CLE.[On Hold]
	)
SELECT DET.Klantnr
	,Huurdernaam = HRD.huurder1
--	,DET.[Openstaand bedrag]
	,DET.Afwachtcode
	,[Omschrijving afwachtcode] = OHC.omschrijving
	,Klantboekingsgroep = CUS.[Customer Posting Group]
	,[Lopende deurwaarderszaak ?] = INFO.deurwaarder
	,[Lopende betalingsregeling ?] = iif(INFO.regelingen IS NOT NULL, 'Ja', 'Nee')
	,[Openstaand saldo] = INFO.openstaand_saldo
FROM cte_details AS DET
INNER JOIN empire_data.dbo.Customer AS CUS ON DET.Klantnr = CUS.[No_]
LEFT OUTER JOIN empire_data.dbo.Staedion$Afwachtcode as OHC on OHC.Code = DET.Afwachtcode 
--LEFT OUTER JOIN empire.empire.dbo.[Staedion$On Hold Code] as OHC on OCH.Code = DET.Afwachten
CROSS APPLY empire_staedion_data.[dbo].[fnRekeningCourant](DET.Klantnr, getdate()) AS INFO
CROSS APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(DET.Klantnr) AS HRD
WHERE CUS.[Customer Posting Group] IN (
		'HUURDERS'
		,'DEB.ENERGI'
		,'DEB.HANDEL'
		)
--	AND INFO.openstaand_saldo <> 0
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee (wel empire_data)', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Toont huidige regels in rekening-courant die openstaan en een afwachtcode hebben. Voorheen was hiervoor een noodzakelijk geachte dwex-rapportage voor. ', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.[RekeningCourant].[PostenMetAfwachtcode]', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Code zoals terug te vinden is in rekening-courant van de klant ', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Afwachtcode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Zie klantkaart', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Huurdernaam'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Zie klantkaart', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Klantboekingsgroep'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Zie klantkaart', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Klantnr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Nog toekomstige verplichtingen vanwege betalingsregeling ? Opgehaald met behulp van functie fnRekeningCourant', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Lopende betalingsregeling ?'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Ja als er nog niet-afgesloten deurwaarderdossiers zijn. Opgehaald met behulp van functie fnRekeningCourant', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Lopende deurwaarderszaak ?'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Zoals in Empire ook terug te vinden is in betreffende rekening-courant-post', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Omschrijving afwachtcode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Saldo van betreffende huurder per laaddatum van het rapport', 'SCHEMA', N'RekeningCourant', 'VIEW', N'PostenMetAfwachtcode', 'COLUMN', N'Openstaand saldo'
GO
