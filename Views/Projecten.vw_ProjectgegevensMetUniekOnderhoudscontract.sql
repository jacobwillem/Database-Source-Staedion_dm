SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Projecten].[vw_ProjectgegevensMetUniekOnderhoudscontract]
AS
WITH cte_projectgegevens_alles
AS
/* ################################################################################################################
Nav PBI Bron ICLM: foutmelding omdat COOH-200135 gekoppeld is aan POCO-2100002 en POCO-2200010
Deze view retourneert in dit geval alleen POCO-2200010

ZIE 21 12 1004 Verversing bron ICLM mislukt

CHECK
select count(*),count(distinct [Projectnr]) from Projecten.vw_Projectgegevens
select count(*),count(distinct Projectnr) from Projecten.vw_ProjectgegevensMetUniekOnderhoudscontract

select Projectnr,Contractnr from Projecten.vw_Projectgegevens --where Contractnr = 'COOH-200135' 
except
select  Projectnr,Contractnr from Projecten.vw_ProjectgegevensMetUniekOnderhoudscontract --where Contractnr = 'COOH-200135' 
################################################################################################################ */

(
SELECT PR.[project_id],
       PR.[bedrijf_id],
       PR.[Bedrijf],
       PR.[Projectnr],
       PR.[Naam],
       PR.[Projectnaam],
       PR.[Omschrijving],
       PR.[Projecttype],
       PR.[Projecttype_oms],
       PR.[projectstatus],
       PR.[projectstatus_oms],
       PR.[Projectfase],
       PR.[Projectfase_oms],
       PR.[projectfase dan wel status],
       PR.[Geblokkeerd],
       PR.[Startdatum],
       PR.[Contractnr],
       PR.[Begrotingsjaar],
       PR.[Begrotingsjaar relatief],
       PR.[Nr_ Hoofdproject],
       PR.[Aangemaakt op],
       PR.[Finish Year],
       PR.[Date Closed],
       PR.[Actief],
       PR.[Functie 1],
       PR.[Functie1_oms],
       PR.[Contact No_1],
       PR.[Functie 2],
       PR.[Functie2_oms],
       PR.[Contact No_2],
       PR.[Functie 3],
       PR.[Functie3_oms],
       PR.[Contact No_3],
       PR.[Projectleider_id],
       PR.[Projectleider],
       PR.[Opzichter],
       PR.[Projectmanager],
       PR.[Niet begroot],
       ROW_NUMBER() OVER (PARTITION BY Contractnr ORDER BY Projectnr DESC) AS volgnr
FROM Projecten.vw_Projectgegevens AS PR
WHERE NULLIF(Contractnr, '') IS NOT NULL
UNION
SELECT PR.[project_id],
       PR.[bedrijf_id],
       PR.[Bedrijf],
       PR.[Projectnr],
       PR.[Naam],
       PR.[Projectnaam],
       PR.[Omschrijving],
       PR.[Projecttype],
       PR.[Projecttype_oms],
       PR.[projectstatus],
       PR.[projectstatus_oms],
       PR.[Projectfase],
       PR.[Projectfase_oms],
       PR.[projectfase dan wel status],
       PR.[Geblokkeerd],
       PR.[Startdatum],
       PR.[Contractnr],
       PR.[Begrotingsjaar],
       PR.[Begrotingsjaar relatief],
       PR.[Nr_ Hoofdproject],
       PR.[Aangemaakt op],
       PR.[Finish Year],
       PR.[Date Closed],
       PR.[Actief],
       PR.[Functie 1],
       PR.[Functie1_oms],
       PR.[Contact No_1],
       PR.[Functie 2],
       PR.[Functie2_oms],
       PR.[Contact No_2],
       PR.[Functie 3],
       PR.[Functie3_oms],
       PR.[Contact No_3],
       PR.[Projectleider_id],
       PR.[Projectleider],
       PR.[Opzichter],
       PR.[Projectmanager],
       PR.[Niet begroot],
       1 AS volgnr
FROM Projecten.vw_Projectgegevens AS PR
WHERE NULLIF(Contractnr, '') IS NULL)
SELECT CTE.[project_id],
       CTE.[bedrijf_id],
       CTE.[Bedrijf],
       CTE.[Projectnr],
       CTE.[Naam],
       CTE.[Projectnaam],
       CTE.[Omschrijving],
       CTE.[Projecttype],
       CTE.[Projecttype_oms],
       CTE.[projectstatus],
       CTE.[projectstatus_oms],
       CTE.[Projectfase],
       CTE.[Projectfase_oms],
       CTE.[projectfase dan wel status],
       CTE.[Geblokkeerd],
       CTE.[Startdatum],
       CTE.[Contractnr],
       CTE.[Begrotingsjaar],
       CTE.[Begrotingsjaar relatief],
       CTE.[Nr_ Hoofdproject],
       CTE.[Aangemaakt op],
       CTE.[Finish Year],
       CTE.[Date Closed],
       CTE.[Actief],
       CTE.[Functie 1],
       CTE.[Functie1_oms],
       CTE.[Contact No_1],
       CTE.[Functie 2],
       CTE.[Functie2_oms],
       CTE.[Contact No_2],
       CTE.[Functie 3],
       CTE.[Functie3_oms],
       CTE.[Contact No_3],
       CTE.[Projectleider_id],
       CTE.[Projectleider],
       CTE.[Opzichter],
       CTE.[Projectmanager],
       CTE.[Niet begroot]
FROM cte_projectgegevens_alles AS CTE
WHERE COALESCE(CTE.volgnr, 1) = 1;
-- and Contractnr = 'COOH-200135' 
GO
