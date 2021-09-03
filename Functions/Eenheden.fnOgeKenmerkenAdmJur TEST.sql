SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [Eenheden].[fnOgeKenmerkenAdmJur TEST] (@Eenheidnr varchar(20), @Peildatum date = null)
returns table
as
/* ########################################################################################################################## 
VAN 		  JvdW
Betreft		Functie voor ophalen van administratief eigenaar van een eenheid - alleen van bedrijf Staedion
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
-- per eenheid
select * from [Eenheden].[fnOgeKenmerkenAdmJur TEST] ( 'ADEH-0050003', getdate())

-- wijziging
SELECT Opmerking =  'Wijziging in administratief eigenaar',Was = KENM1.[Administratieve eigenaar], Wordt = KENM2.[Administratieve eigenaar] 
FROM empire_data.dbo.Staedion$OGE as OGE
OUTER APPLY staedion_dm.Eenheden.[fnOgeKenmerkenAdmJur TEST](OGE.Nr_, '20181231') AS KENM1
OUTER APPLY staedion_dm.Eenheden.[fnOgeKenmerkenAdmJur TEST](OGE.Nr_, '20201231') AS KENM2
WHERE OGE.[Common Area] = 0
       AND (
              oge.[Einde exploitatie] >= getdate()
              OR oge.[Einde exploitatie] = datefromparts(1753, 1, 1)
              )
and KENM1.[Administratieve eigenaar] <> KENM2.[Administratieve eigenaar] 

-- check met else-lijst
select Eenheidnr, beheerder from empire_staedion_data.dbo.els where datum_gegenereerd = (Select max(datum_Gegenereerd) from empire_staedion_data.dbo.els)
and beheerder <> 'Staedion'
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
20210215 Aangemaakt obv code van Roelof zoals ook in ELS-lijst wordt gebruikt (maar dan zonder pivot)
########################################################################################################################## */
RETURN
WITH cte_adm 
AS (
       SELECT oao.[Realty Object No_] AS Eenheidnr
              ,[Administratief eigenaar] = max(ado.[Name])
       FROM empire_data.dbo.Staedion$Oge_Administrative_Owner oao
       INNER JOIN empire_data.dbo.Staedion$Administrative_Owner ado
              ON oao.[Dimension Value] = ado.[Dimension Value]
       WHERE oao.[Start Date] <= @Peildatum
              AND (
                     oao.[End Date] = '1753-01-01'
                     OR oao.[End Date] >= @Peildatum
                     )
       GROUP BY oao.[Realty Object No_]
       )
       ,cte_hulp
AS (
       SELECT JUR.[Realty Object No_]
              ,JUR.[Type] 
              ,[Start Date] = max(jur.[Start Date])
       FROM empire_data.dbo.Staedion$Realty_Object_Owner_Supervisor as JUR 
       WHERE jur.[Start Date] <= @Peildatum
              AND jur.[Type] IN (
                     0
                     ,1
                     )
       GROUP BY jur.[Realty Object No_]
              ,jur.[Type]
       )
       ,cte_beheerder
AS (
       SELECT JUR.[Realty Object No_]
              ,Beheerder = BEH.NAME
       FROM empire_data.dbo.Staedion$Realty_Object_Owner_Supervisor AS JUR
       INNER JOIN cte_hulp AS CTE
              ON JUR.[Realty Object No_] = CTE.[Realty Object No_]
                     AND JUR.[Start Date] = CTE.[Start Date]
                     AND JUR.[Type] = CTE.[Type]
       LEFT OUTER JOIN empire_data.dbo.Contact AS BEH
              ON JUR.[Supervisor] = BEH.[No_]
       WHERE CTE.[Type] = 0 -- Beheerder
       ),cte_eigenaar
AS (
       SELECT JUR.[Realty Object No_]
              ,[Juridisch eigenaar] = EIG.NAME
       FROM empire_data.dbo.Staedion$Realty_Object_Owner_Supervisor AS JUR
       INNER JOIN cte_hulp AS CTE
              ON JUR.[Realty Object No_] = CTE.[Realty Object No_]
                     AND JUR.[Start Date] = CTE.[Start Date]
                     AND JUR.[Type] = CTE.[Type]
       LEFT OUTER JOIN empire_data.dbo.Contact AS EIG
              ON JUR.[Owner] = EIG.[No_]
       WHERE CTE.[Type] = 1 -- Eigenaar
       )
SELECT Eenheidnr = Nr_
       ,ADM.[Administratief eigenaar]
       ,BEH.Beheerder 
			 ,[Juridisch eigenaar] = coalesce(EIG.[Juridisch eigenaar] ,'Staedion')
FROM empire_data.dbo.staedion$oge AS OGE
LEFT OUTER JOIN cte_adm AS ADM
       ON ADM.Eenheidnr = OGE.Nr_
LEFT OUTER JOIN cte_beheerder AS BEH
       ON OGE.Nr_ = BEH.[Realty Object No_]
LEFT OUTER JOIN cte_eigenaar AS EIG
       ON OGE.Nr_ = EIG.[Realty Object No_]
where OGE.Nr_ = @Eenheidnr


GO
