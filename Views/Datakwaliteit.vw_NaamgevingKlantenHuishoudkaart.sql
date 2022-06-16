SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Datakwaliteit].[vw_NaamgevingKlantenHuishoudkaart] AS
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC sys.sp_updateextendedproperty @name = N'MS_Description'
       ,@value = N'Consistentiecheck: Een overzicht van die huurders waarbij er aan afwijking is tussen de naamgeving op de klantkaart en die van de meest recente contractkaart.
Vraag is dan of de instructie met betrekking tot bijvoorbeeld een medehuurder dan goed is verwerkt.
Uitgezonderd: huurders met verzamelfacturering
NB: Naam (veld 2) op Huishoudenkaart van de Huidige huurder <> Klantnaam van de Klant (veld 7) – zonder “Mevrouw “ of “De heer “! 
NB: op de laatste/meest recente contractregel in de Contractentabel voor die OGEH.
NB: Naam (veld 2) van Huishoudenkaart die hoort bij dat Klantnr., 
NB: Naam Klant (veld 7, zonder “Mevrouw “ of “De heer “) op meest recente contractregel uit Contractentabel.'   
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'NaamgevingKlantenHuishoudkaart';
GO
exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit','vw_NaamgevingKlantenHuishoudkaart'


--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
JvdW 20211208 Aangemaakt obv input Marieke

--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
select	Huurdernr, [Huurdernaam contractkaart], [Huurdernaam huishoudkaart], Prioriteit
from	staedion_dm.Datakwaliteit.[vw_NaamgevingKlantenHuishoudkaart]
De heer/mevrouw C.F.H. Ladan
C.F.H. Ladan
--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------
-- eerste 3 pisities zelfde achternaam + zelfde geboortenaam ? => mogelijk fout bij gegadigdekoppeling
 SELECT	CONT1.No_, CONT1.[Name], CONT1.Geboortedatum, CONT2.No_, CONT2.[Name], CONT2.Geboortedatum  , CONT1.[Type], CONT2.[Type]
 from empire_data.dbo.Contact AS CONT1 
 JOIN empire_data.dbo.Contact AS CONT2
 ON LEFT(CONT1.[Surname],3) =  LEFT(CONT2.[Surname],3)
 AND CONT1.[Geboortedatum] = CONT2.Geboortedatum
 AND CONT1.No_ <> CONT2.No_
 AND CONT1.[Geboortedatum] <> '17530101'



Declare @Vhe as nvarchar(20) = 'OGEH-0001595'
set @Vhe = 'OGEH-0031068'
set @Vhe = null;
--set @Vhe = 'OGEH-0004518'
--set @Vhe = 'OGEH-0055333'

;
WITH cte_basis AS (
SELECT Eenheidnr = OGE.Nr_
	   ,[Adres OGE] = OGE.Straatnaam + ''+ OGE.Huisnr_ + ' '+ OGE.Toevoegsel
       ,[Status eenheidskaart] = CASE oge.[status]
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
       ,[Huidige klantnr] = HRD.[Customer No_]
	   ,[Huishoudkaart nr] = HRD.[Contact No_]
	   ,[Naam huishoudkaart] = C.[Name]
	   ,[Naam klantkaart] = CUST.[Name]
	   ,HPR.Volgnummer
--	   ,CONTR.Naam
	   ,[Gegenereerd op] = (select laaddatum from empire_Dwh.dbo.tmv_laaddatum)
--into #FF
FROM empire_data.dbo.Staedion$oge AS OGE
OUTER APPLY empire_Staedion_data.dbo.[ITVfnHuurprijs TEST](OGE.Nr_, GETDATE()) AS HPR
--OUTER APPLY empire_Staedion_data.dbo.ITVfnHuurprijs(OGE.Nr_, datefromparts(year(getdate()),8,1)) AS HPR18
--OUTER APPLY staedion_dm.Eenheden.fn_Eigenschappen(OGE.Nr_, getdate()) AS KENM
--OUTER APPLY empire_staedion_data.[dbo].ITVfnCLusterBouwblok(OGE.Nr_) AS CLUS
--OUTER APPLY empire_staedion_data.[dbo].[ITVFnContactbeheer](OGE.Nr_) AS CONT
OUTER APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(HPR.huurdernr) AS HRD
JOIN empire_Data.dbo.contact AS C ON HRD.[Contact No_] = C.No_
JOIN empire_Data.dbo.customer AS CUST ON HPR.huurdernr = CUST.No_
--JOIN empire_data.dbo.[Staedion$Contract] AS CONTR ON CONTR.[Eenheidnr_] = OGE.Nr_ 
--AND HPR.Volgnummer = CONTR.Volgnr_
WHERE OGE.[Common Area] = 0
       AND (
              OGE.nr_ = @Vhe
              OR @Vhe IS NULL
              )
       --AND KENM.[Corpodata type] LIKE 'WON%'
	   --AND C.[Name] <> CUST.[Name]
       AND OGE.[Begin exploitatie] <> '17530101'
       AND OGE.[Begin exploitatie] <= getdate()
       AND (
              OGE.[Einde exploitatie] = '17530101'
              OR OGE.[Einde exploitatie] > getdate()
              )
			  )
SELECT * 
INTO #cte_basis
FROM cte_basis
;


SELECT BASIS.* , CONTR.Naam
FROM #cte_basis AS BASIS 
JOIN empire_data.dbo.[Staedion$Contract] AS CONTR 
ON CONTR.[Eenheidnr_] = BASIS.Eenheidnr 
AND BASIS.Volgnummer = CONTR.Volgnr_
WHERE REPLACE(REPLACE(CONTR.Naam, 'Mevrouw ',''),'De heer ','') <> BASIS.[Naam huishoudkaart]
;


J.A. d' Arnault e.a.
J.A. d'Arnault e.a.

################################################################################################################################## */    
WITH cte_basis
AS (SELECT DISTINCT
           Eenheidnr,
           Huurdernr,
           Huurdernaam,
           Ingangsdatum
    --FROM [Contracten].[NieuwsteContractRegels]
    FROM [Contracten].[vw_NieuwsteContractRegelsZonderStaedionBredeElementen])
SELECT Ingangsdatum AS [Meest recente contractregel uit Contractentabel],
       CONT.No_ AS [Huishoudkaartnr],
       BASIS.Huurdernaam AS [Huurdernaam contractkaart],
       CONT.[Name] AS [Huurdernaam huishoudkaart],

	   CASE WHEN CONT.[Name] LIKE '%e.a.%' AND BASIS.Huurdernaam NOT LIKE '%e.a.%'
			THEN 'Prio 1: medehuurder erbij ?'
			ELSE CASE WHEN CONT.[Name] NOT LIKE '%e.a.%' AND BASIS.Huurdernaam LIKE '%e.a.%'
				THEN 'Prio 2: evt correctie huishoudkaart/contractregel ?' 
				ELSE CASE WHEN LEN(REPLACE(REPLACE(REPLACE(BASIS.Huurdernaam, 'De heer/mevrouw ', ''), 'De heer ', ''),'Mevrouw ','')) 
								- LEN(REPLACE(REPLACE(REPLACE(REPLACE(BASIS.Huurdernaam, 'De heer/mevrouw ', ''), 'De heer ', ''),'Mevrouw ',''), ' ',''))
								<>
								LEN(CONT.[Name]) - LEN(REPLACE(CONT.[Name],' ',''))
								AND REPLACE(CONT.[Name], ' ','') = REPLACE( REPLACE(REPLACE(REPLACE(BASIS.Huurdernaam, 'De heer/mevrouw ', ''), 'De heer ', ''),'Mevrouw ',''), ' ','') 
							THEN 'Prio 3: verschil in aantal spaties' END END END
				AS Omschrijving, 
	   OGE.straatnaam + ' ' + OGE.huisnr_ + ' ' + OGE.Toevoegsel AS [Adres eenheid],
       CAST(GETDATE() AS DATE) AS [Gegenereerd op],

       -- tbv insert in RealisatieDetails tabel
       1 AS Waarde,
       CAST(GETDATE() AS DATE) AS Laaddatum,
	   NULL AS Bevinding ,
       NULL AS Teller,
       NULL AS Noemer,
       OGE.Nr_ AS eenheidnr,
       BASIS.Huurdernr,
       CONVERT(DATE, NULL) AS datEinde,
       CONVERT(DATE, NULL) AS datIngang,
       NULL AS Hyperlink,
       NULL AS Gebruiker,
	   CUST.No_ AS Klantnr,
       CONT.No_ AS Relatienr

FROM cte_basis AS BASIS
    JOIN empire_data.dbo.Customer AS CUST
        ON CUST.No_ = BASIS.Huurdernr
    JOIN empire_data.dbo.Contact AS CONT
        ON CONT.No_ = CUST.[Contact No_]
    JOIN empire_data.dbo.Staedion$oge AS OGE
        ON OGE.Nr_ = BASIS.Eenheidnr
WHERE REPLACE(REPLACE(REPLACE(BASIS.Huurdernaam, 'De heer/mevrouw ', ''), 'De heer ', ''),'Mevrouw ','') <> CONT.[Name]
AND CUST.[Combine Shipments] <> 1
;
 
GO
