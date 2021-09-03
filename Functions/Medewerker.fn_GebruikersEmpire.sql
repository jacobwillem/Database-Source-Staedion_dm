SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Medewerker].[fn_GebruikersEmpire] (@Gebruiker NVARCHAR(50) = NULL)
RETURNS TABLE
AS
/* ########################################################################################################################## 
VAN 		JvdW
Betreft		Functie die per aangemelde gebruiker in Empire volgende retourneert:
gebruikersnaam   functie		Bedrijf Staedion  |  Bedrijf X ...	Bedrijf laatste
AVD				 controller		Ja				  |  Ja				Nee

--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
-- performance
select * from [staedion_dm].[Medewerker].[fn_GebruikersEmpire] ('STAEDION\TITIA.WITTE')
select * from [staedion_dm].[Medewerker].[fn_GebruikersEmpire] (default)



-- check dubbele regels

--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden]  staedion_dm, 'Medewerker', 'fn_GebruikersEmpire'


--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
20210519 Aangemaakt op verzoek van Marieke Peeters


--------------------------------------------------------------------------------------------------------------------------
LATER
--------------------------------------------------------------------------------------------------------------------------
Dynamisch te maken evt op basis van afzonderlijke tabellen [XXX$User Setup]

########################################################################################################################## */
RETURN
WITH cte_userid AS (
		SELECT Functie = SAL.[Job Title]
			,Bedrijf = GEBR.mg_bedrijf
			,Werknemersnummer = GEBR.[Salesperson Code]
			,GEBR.[User ID]
		FROM empire_data.[dbo].[mg_user_setup] AS GEBR
		LEFT OUTER JOIN empire_data.dbo.[salesperson_purchaser] AS SAL ON GEBR.[Salesperson Code] = SAL.[Code]
		)

SELECT [User ID]
	,Functie
	,Werknemersnummer
	,Gegenereerd = getdate()
	,[Komt voor in hoeveel bedrijven] = iif(Staedion IS NULL, 0, 1) + iif(N_V__Stedelijk_Belang IS NULL, 0, 1) + iif(Niet_DAEB_Staedion IS NULL, 0, 1) + iif(Staedion_VG_Holding_BV IS NULL, 0, 1) + iif(Energiek_2_B_V_ IS NULL, 0, 1) + iif(Woondynamics IS NULL, 0, 1) + iif(Consol__Stg_Staedion IS NULL, 0, 1) + iif(Consol__SVG_Holding_BV IS NULL, 0, 1) + iif(Consol_bedr__Staedion IS NULL, 0, 1) + iif(Consol_bedr__Vastgoed_Holding IS NULL, 0, 1) + iif(Eliminatie IS NULL, 0, 1) + iif(Eliminatie_Groep IS NULL, 0, 1) + iif(Eliminatie_niveau_2 IS NULL, 0, 1) + iif(Aardwarmte_VOF IS NULL, 0, 1) + iif(Argion_Beheer_B_V_ IS NULL, 0, 1) + iif(Balkengat_VOF IS NULL, 0, 1) + iif(BO__Del_B_V_ IS NULL, 0, 1) + iif(BO__Laak_B_V_ IS NULL, 0, 1) + iif(BO__Moer_B_V_ IS NULL, 0, 1) + iif(BO__Mor_B_V_ IS NULL, 0, 1) + iif(BO__Trans_B_V_ IS NULL, 0, 1) + iif(BO__Wat_B_V_ IS NULL, 0, 1) + iif(Invex_B_V_ IS NULL, 0, 1) + iif(Pyloon_Monumenten_B_V_ IS NULL, 0, 1) + iif(Rozenburg_Kwartier_B_V_ IS NULL, 0, 1) + iif(S_B_Theaterproject_B_V_ IS NULL, 0, 1) + iif(Sta_Pro_1 IS NULL, 0, 1) + iif(SWY_projecten_B_V_ IS NULL, 0, 1) + iif(Villa_Luccio_B_V_ IS NULL, 0, 1) + iif(Villa_Luccio_VOF 
		IS NULL, 0, 1) + iif(WOM_C_V_ IS NULL, 0, 1)
	,Staedion = iif(Staedion IS NULL, 0, 1)
	,[NV Stedelijk Belang] = iif(N_V__Stedelijk_Belang IS NULL, 0, 1)
	,[Niet DAEB Staedion] = iif(Niet_DAEB_Staedion IS NULL, 0, 1)
	,[Staedion VG Holding BV] = iif(Staedion_VG_Holding_BV IS NULL, 0, 1)
	,[Energiek 2 BV] = iif(Energiek_2_B_V_ IS NULL, 0, 1)
	,Woondynamics = iif(Woondynamics IS NULL, 0, 1)
	,[Consol Stg Staedion] = iif(Consol__Stg_Staedion IS NULL, 0, 1)
	,[Consol SVG Holding BV] = iif(Consol__SVG_Holding_BV IS NULL, 0, 1)
	,[Consol bedr Staedion] = iif(Consol_bedr__Staedion IS NULL, 0, 1)
	,[Consol bedr Vastgoed Holding] = iif(Consol_bedr__Vastgoed_Holding IS NULL, 0, 1)
	,Eliminatie = iif(Eliminatie IS NULL, 0, 1)
	,[Eliminatie_Groep] = iif(Eliminatie_Groep IS NULL, 0, 1)
	,[Eliminatie niveau 2] = iif(Eliminatie_niveau_2 IS NULL, 0, 1)
	,[Aardwarmte VOF] = iif(Aardwarmte_VOF IS NULL, 0, 1)
	,[Argion Beheer BV] = iif(Argion_Beheer_B_V_ IS NULL, 0, 1)
	,[Balkengat VOF] = iif(Balkengat_VOF IS NULL, 0, 1)
	,[BO Del BV] = iif(BO__Del_B_V_ IS NULL, 0, 1)
	,[BO Laak BV] = iif(BO__Laak_B_V_ IS NULL, 0, 1)
	,[BO Moer BV] = iif(BO__Moer_B_V_ IS NULL, 0, 1)
	,[BO Mor BV] = iif(BO__Mor_B_V_ IS NULL, 0, 1)
	,[BO Trans BV] = iif(BO__Trans_B_V_ IS NULL, 0, 1)
	,[BO Wat BV] = iif(BO__Wat_B_V_ IS NULL, 0, 1)
	,[Invex BV] = iif(Invex_B_V_ IS NULL, 0, 1)
	,[Pyloon Monumenten BV] = iif(Pyloon_Monumenten_B_V_ IS NULL, 0, 1)
	,[Rozenburg Kwartier BV] = iif(Rozenburg_Kwartier_B_V_ IS NULL, 0, 1)
	,[SB Theaterproject BV] = iif(S_B_Theaterproject_B_V_ IS NULL, 0, 1)
	,[Sta Pro 1] = iif(Sta_Pro_1 IS NULL, 0, 1)
	,[SWY projecten BV] = iif(SWY_projecten_B_V_ IS NULL, 0, 1)
	,[Villa Luccio BV] = iif(Villa_Luccio_B_V_ IS NULL, 0, 1)
	,[Villa Luccio VOF] = iif(Villa_Luccio_VOF IS NULL, 0, 1)
	,[WOM CV] = iif(WOM_C_V_ IS NULL, 0, 1)
FROM (
	SELECT [User ID]
		,Functie
		,Bedrijf
		,Werknemersnummer
	FROM cte_userid
	) col
pivot(max(Bedrijf) FOR Bedrijf IN (
			Aardwarmte_VOF
			,Argion_Beheer_B_V_
			,Balkengat_VOF
			,BO__Del_B_V_
			,BO__Laak_B_V_
			,BO__Moer_B_V_
			,BO__Mor_B_V_
			,BO__Trans_B_V_
			,BO__Wat_B_V_
			,Consol__Stg_Staedion
			,Consol__SVG_Holding_BV
			,Consol_bedr__Staedion
			,Consol_bedr__Vastgoed_Holding
			,Eliminatie
			,Eliminatie_Groep
			,Eliminatie_niveau_2
			,Energiek_2_B_V_
			,Invex_B_V_
			,N_V__Stedelijk_Belang
			,Niet_DAEB_Staedion
			,Pyloon_Monumenten_B_V_
			,Rozenburg_Kwartier_B_V_
			,S_B_Theaterproject_B_V_
			,Sta_Pro_1
			,Staedion
			,Staedion_VG_Holding_BV
			,SWY_projecten_B_V_
			,Villa_Luccio_B_V_
			,Villa_Luccio_VOF
			,WOM_C_V_
			,Woondynamics
			)) AS piv
WHERE (
		[User ID] = @Gebruiker
		OR @Gebruiker IS NULL
		)
GO
