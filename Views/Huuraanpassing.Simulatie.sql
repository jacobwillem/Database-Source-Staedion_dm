SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE view [Huuraanpassing].[Simulatie]
as
/* #################################################################################################################################

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Huuraanpassing', 'Simulatie'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'View op Empire-tabel [OGE Rent Increase] = simulatiebestand huurverhoging. 
Deze tabel wordt eerst gekopieerd van een testomgeving naar empire_staedion_data.hvh. 
Aangevuld met caption-benamingen + in Empire gehanteerde flow-fields',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'VIEW',  @level1name = 'Simulatie'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'VIEW',  @level1name = 'Simulatie'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select Tijdvakcode, Verwerkingsstatus, count(*) from dbo.tmv_oge_huurverhoging_testomgeving group by Tijdvakcode, Verwerkingsstatus order by Tijdvakcode, Verwerkingsstatus',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'VIEW',  @level1name = 'Simulatie'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'VIEW',  @level1name = 'Simulatie'
;  
------------------------------------------------------------------------------------------------------------------------------------
WIJZIGING	  
20180328 JvdW aangemaakt, conform Empire R16.FP01 
20200318 JvdW metadata, aparte versie voor data-testomgeving in tmv_oge_huurverhoging_testomgeving verwijzend naar empire_staedion_data
20200324 JvdW blob-veld leesbaar gemaakt met functie
------------------------------------------------------------------------------------------------------------------------------------
CHECK
------------------------------------------------------------------------------------------------------------------------------------
select 'Aantal rijen tabel',null, count(*)
from		empire_data.dbo.Staedion$Oge_Rent_Increase
union
select 'Aantal rijen view',Gegenereerd, count(*) 
from		empire_dwh.dbo.[tmv_oge_huurverhoging_testomgeving]
group by Gegenereerd
------------------------------------------------------------------------------------------------------------------------------------
################################################################################################################################# */

SELECT Eenheidnr = HVH.[Realty Object No_]
	,Tijdvakcode = HVH.[Period Code]
	,Contractsoort = CASE HVH.[Contract Type]
		WHEN 0
			THEN 'Inhuur'
		WHEN 1
			THEN 'Verhuur'
		WHEN 2
			THEN 'Erfpacht'
		WHEN 3
			THEN 'Moedercontract'
		END
	,Contractvolgnr_ = HVH.[Contract Entry No_]
	,Tijdvakomschrijving = HVH.[Period Description]
	,Tijdvakingangsdatum = HVH.[Period Starting Date]
	,Huurverhogingsbeleidstypecode = HVH.[Rent Incr_ Policy Type Code]
	,[Huurverhogingsbeleidstype-omschrijving] = HVH.[Rent Incr_ Policy Type Descr_]
	,[Basis verhogingspercentage] = HVH.[Basic Increase Percentage]
	,Verhogingspercentageprecisie = CASE HVH.[Increase Percentage Precision]
		WHEN 0
			THEN '1 decimaal'
		WHEN 1
			THEN '2 decimalen'
		WHEN 2
			THEN '3 decimalen'
		WHEN 3
			THEN '4 decimalen'
		END
	,Huishoudverklaring = HVH.[Income Class Code]
	,[Inkomensafhankelijk verhogingspercentage] = HVH.[Income Dep_ Incr_ Percentage]
	,[Totaal verhogingspercentage] = HVH.[Total Increase Percentage]
	,[Batch Code] = HVH.[Batch Code]
	,[Batch-omschrijving] = HVH.[Batch Description]
	,[DAEB-indicator] = HVH.[DAEB Indicator]
	,Liberalisatiegrens = HVH.[Liberalisation Limit]
	,[Geliberaliseerd contract] = CASE HVH.[Liberalized Contract]
		WHEN 0
			THEN 'Nee'
		WHEN 1
			THEN 'Ja'
		END
	,Streefhuurpercentage = HVH.[Target Rent Percentage]
	,Streefhuur = HVH.[Target Rent]
	,[Maximale huurprijs] = HVH.[Maximum Rent Price]
	,Waarderingspunten = HVH.[Valuation Points]
	,[Huidige nettohuur] = HVH.[Current Net Rent]
	,[Nettohuur aftoppingscode] = HVH.[Net Rent Capping Code]
	,[Aftoppingstype] = CASE HVH.[Net Rent Capping Type]
		WHEN 0
			THEN 'Voorgedefinieerd'
		WHEN 1
			THEN 'Additioneel'
		END
	,[Aftoppingsomschrijving] = HVH.[Net Rent Capping Description]
	,Aftopbedrag = HVH.[Net Rent Capping Amount]
	,Markthuur = HVH.[Market Rent]
	,[Subsidiabel servicebedrag inbegrepen] = CASE HVH.[Subsidy Service Amt_ Included]
		WHEN 0
			THEN 'Nee'
		WHEN 1
			THEN 'Ja'
		END
	,[Subsidiabel servicebedrag] = HVH.[Subsidy Service Amount]
	,[Aftoppingsregelpercentage] = HVH.[Net Rent Capping Line Perc_]
	,Aftoppingsregeltype = CASE HVH.[Net Rent Capping Line Type]
		WHEN 0
			THEN 'Bedrag'
		WHEN 1
			THEN 'Percentage van maximale huurprijs'
		WHEN 2
			THEN 'Streefhuur plus correctiebedrag'
		END
	,Aftoppingscorrectiebedrag = HVH.[Capping Correction Amount]
	,[Nettohuur vóór aftopping] = HVH.[Before Capping Net Rent]
	,[Nettohuur ná aftopping] = HVH.[After Capping Net Rent]
	,[Effectief verhogingspercentage] = HVH.[Effective Increase Percentage]
	,[Effectief aftopbedrag] = HVH.[Effective Capping Amount]
	,[Nieuwe nettohuur] = HVH.[New Net Rent]
	,[Berekend verhogingspercentage] = HVH.[Calculated Increase Perc_]
	,[Verhogingspercentagecorrectie] = HVH.[Increase Perc_ Correction]
	,[Huidige nettohuur / max. huurprijs %] = HVH.[Curr_ Net Rent Max_ Rent Ratio]
	,[Huidige nettohuur / liberalisatiegrens %] = HVH.[Curr_ Net Rent Lib_Limit Ratio]
	,[Nieuwe nettohuur / max. huurprijs %] = HVH.[New Net Rent Max_ Rent Ratio]
	,[Nieuwe nettohuur / liberalisatiegrens %] = HVH.[New Net Rent Lib_ Limit Ratio]
	,Berekeningsopmerkingen = HVH.[Calculation Remarks]
	,[Exceptiecode] = HVH.[Exception Code]
	,[Exceptietekst] = [empire_logic].[dbo].dlcf_navision_decompress_blob_to_readable(HVH.[Exception Text])
	,[Batchkeuze uitlegcode] = CASE HVH.[Batch Choice]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'BATOGEGEENINKIND'
		WHEN 2
			THEN 'BATOGEWELINKIND'
		WHEN 3
			THEN 'BATINKIND'
		END
	,[Aftoppingskeuze uitlegcode] = HVH.[Capping Choice]
	,[Aftopbedrag uitlegtype] = CASE HVH.[Capping Amount Type]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'AFTOPBDR'
		WHEN 2
			THEN 'AFTOPPCT'
		WHEN 3
			THEN 'STREEFHRPLUS'
		END
	,[Effectief aftopbedrag uitlegtype] = CASE HVH.[Eff_ Capping Amt_ Type]
		WHEN 0
			THEN ''
		WHEN 1
			THEN 'AFTOPBDREXCL'
		WHEN 2
			THEN 'AFTOPBDRINCL'
		END
	,Voorbereidingstijdstip = HVH.[Preparation Date-Time]
	,Berekeningstijdstip = HVH.[Calculation Date-Time]
	,[Aftopping op maximale huurprijs] = HVH.[Capping at Maximum Rent Price]
	,[Verlaging vanwege aftopping toegestaan] = CASE HVH.[Decr_ due to Capping Allowed]
		WHEN 0
			THEN 'Nee'
		WHEN 1
			THEN 'Ja'
		END
	,Huurprijspeildatum = HVH.[Rent Price Reference Date]
	,[Contract-huurverhogingsdatum] = HVH.[Contract Rent Increase Date]
	,[OG Eenheidstatus] = CASE HVH.[Realty Object Status]
		WHEN 0
			THEN 'Leegstand'
		WHEN 1
			THEN 'Uit beheer'
		WHEN 2
			THEN 'Renovatie'
		WHEN 3
			THEN 'Verhuurd'
		WHEN 4
			THEN 'Administratief'
		WHEN 5
			THEN 'Verkocht'
		WHEN 6
			THEN 'In ontwikkeling'
		END
	,Berekeningscode = HVH.[Calculation Code]
	,[Effectueringstijstip] = HVH.[Finalization Date-Time]
	,[Nieuw contractvolgnr_] = HVH.[New Contract Entry No_]
	,[Aftopping toegepast] = HVH.[Capping Applied]
	,[Huurverhogingsrelaascodes1] = HVH.[Rent Incr_ Narration Codes1]
	,Huurverhogingsrelaascodes2 = HVH.[Rent Incr_ Narration Codes2]
	,Huurverhogingsrelaascodes3 = HVH.[Rent Incr_ Narration Codes3]
	,[OG Eenheidtypecode] = HVH.[Realty Object Type Code]
	,
	-- Table Relatie = Type WHERE (Soort=FILTER(<>Collectief object))
	[OG Eenheidtype-omschrijving] = HVH.[Realty Object Type Descr_]
	,[OG Eenheid technisch type] = HVH.[Realty Object Technical Type]
	,
	-- Table Relatie = "Technical Unit Type"
	[OG Eenheidtype CorpoData] = HVH.[Realty Object Type CorpoData]
	,[Ingangsdatum huurcontract] = HVH.[Start Date Rental Contract]
	,[Code globale dimensie 1] = HVH.[Global Dimension 1 Code]
	,Gemeentecode = HVH.[Municipality Code]
	,Gemeentenaam = HVH.[Municipality Name]
	,[Huidige nettohuur / markthuur %] = HVH.[Curr_ Net Rent Mrkt Rent Ratio]
	,[Nieuwe nettohuur / markthuur %] = HVH.[New Net Rent Market Rent Ratio]
	,[Nettohuur verhogen ingeval van huurkorting] = CASE HVH.[Incr_ Net Rent when Rent Disc_]
		WHEN 0
			THEN 'Nee'
		WHEN 1
			THEN 'Ja'
		END
	,[Ingesteld huurverhogingspercentage is maximum] = CASE HVH.[Configured Incr_ Perc_ is Max_]
		WHEN 0
			THEN 'Nee'
		WHEN 1
			THEN 'Ja'
		END
	,[Huidige nettohuur / streefhuur %] = HVH.[Curr_ Net Rent Trg Rent Ratio]
	,[Nieuwe nettohuur / streefhuur %] = HVH.[New Net Rent Target Rent Ratio]
	,[Verwerkingsstatus] = CASE HVH.[Processing Status]
		WHEN 0
			THEN 'Overgeslagen'
		WHEN 1
			THEN 'Aangemaakt'
		WHEN 2
			THEN 'Simulatie'
		WHEN 3
			THEN 'Definitief'
		WHEN 4
			THEN 'Geëffectueerd'
		WHEN 5
			THEN 'Niet-geëffectueerd'
		WHEN 6
			THEN 'Ongeldig'
		WHEN 7
			THEN 'Vervallen'
		END
	,Gegenereerd = (
		SELECT create_Date
		FROM empire_staedion_data.sys.tables
		WHERE name = 'Staedion$Oge Rent Increase'
		)
	,Straat = OGE.Straatnaam
	,
	-- flowfield: Lookup(OGE.Straatnaam WHERE (Nr.=FIELD(Realty Object No.)))
	Huisnr_ = OGE.Huisnr_
	,
	-- flowfield: Lookup(OGE.Huisnr. WHERE (Nr.=FIELD(Realty Object No.)))
	Toevoegsel = OGE.Toevoegsel
	,
	-- flowfield: Lookup(OGE.Toevoegsel WHERE (Nr.=FIELD(Realty Object
	Postcode = OGE.Postcode
	,
	-- flowfield: Lookup(OGE.Postcode WHERE (Nr.=FIELD(Realty Object No.)))
	Plaats = OGE.Plaats
	,
	-- flowfield: Lookup(OGE.Plaats WHERE (Nr.=FIELD(Realty Object No.)))
	[Technisch type omschrijving] = TT.[Description]
	,
	-- flowfield: Lookup("Technical Unit Type".Description WHERE (Code=FIELD(Realty Object Technical Type)))
	Indexcode = CON.Indexcode
	,
	-- flowfield: Lookup(Contract.Indexcode WHERE (Eenheidnr.=FIELD(Realty Object No.),Volgnr.=FIELD(Contract Entry No.)))
	Indexeringsmethode = CON.Indexeringsmethode
-- flowfield: Lookup(Contract.Indexeringsmethode WHERE (Eenheidnr.=FIELD(Realty Object No.),Volgnr.=FIELD(Contract Entry No.)))
-- select count(*)
FROM staedion_dm.Huuraanpassing.[Staedion$Oge Rent Increase] AS HVH
LEFT OUTER JOIN staedion_dm.Huuraanpassing.[Staedion$OGE] AS OGE ON OGE.Nr_ collate DATABASE_default = HVH.[Realty Object No_] collate DATABASE_default
LEFT OUTER JOIN staedion_dm.Huuraanpassing.[Staedion$Technical Unit Type] AS TT ON HVH.[Realty Object Technical Type] collate DATABASE_default = TT.Code collate DATABASE_default
LEFT OUTER JOIN staedion_dm.Huuraanpassing.[Staedion$Contract] AS CON ON HVH.[Realty Object No_] collate DATABASE_default = CON.Eenheidnr_ collate DATABASE_default
	AND HVH.[Contract Entry No_] = CON.Volgnr_
WHERE HVH.[Period Code] LIKE left(year(getdate()), 4) + '%'
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Huuraanpassing', 'VIEW', N'Simulatie', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Huuraanpassing', 'VIEW', N'Simulatie', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View op Empire-tabel [OGE Rent Increase] = simulatiebestand huurverhoging. 
Deze tabel wordt eerst gekopieerd van een testomgeving naar empire_staedion_data.hvh. 
Aangevuld met caption-benamingen + in Empire gehanteerde flow-fields', 'SCHEMA', N'Huuraanpassing', 'VIEW', N'Simulatie', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select Tijdvakcode, Verwerkingsstatus, count(*) from staedion_dm.Huuraanpassing.Simulatie group by Tijdvakcode, Verwerkingsstatus order by Tijdvakcode, Verwerkingsstatus', 'SCHEMA', N'Huuraanpassing', 'VIEW', N'Simulatie', NULL, NULL
GO
