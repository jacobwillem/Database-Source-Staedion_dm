SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE function [Huuraanpassing].[fn_ControleMaximaalRedelijk] (@Percentage decimal(8,2) = 1.0)
returns table
AS
/* #################################################################################################################################
VAN			JvdW
BETREFT		Functie voor check op maximaal redelijk bij 30-6 en 1-7 tijdens proces huuraanpassing
------------------------------------------------------------------------------------------------------------------------------------
CHECK		select * from staedion_dm.Huuraanpassing.[fn_ControleMaximaalRedelijk] (default) 
------------------------------------------------------------------------------------------------------------------------------------
WIJZIGING	  
20210413 JvdW - Versie 1: aangemaakt obv versie in empire_dwh - nu geent op schema-naam staedion_dm.Huuraanpassing
------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Huuraanpassing', 'fn_ControleMaximaalRedelijk'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
;
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
;
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
@level2type = N'Column',@level2name = 'KOLOM';
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
@level2type = N'Column',@level2name = 'KOLOM';
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
@level2type = N'Column',@level2name = 'KOLOM';
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
@level2type = N'Column',@level2name = 'KOLOM';
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
@level2type = N'Column',@level2name = 'KOLOM';
;  
-- extended property toevoegen op object-niveau
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',
@level1type = N'fn_ControleMaximaalRedelijk',  @level1name = 'ObjectName'
@level2type = N'Column',@level2name = 'KOLOM';
;  


################################################################################################################################# */
	return

WITH CTE_verhuurteam
     AS (SELECT Eenheidnr = EC.Eenheidnr_, 
                Verhuurteam = C.NAME, 
                Volgnr = ROW_NUMBER() OVER(PARTITION BY EC.Eenheidnr_
                ORDER BY EC.Contactnr_) -- als er per abuis dubbele in zitten, toch maar 1 regel selecteren
         FROM staedion_dm.Huuraanpassing.[Staedion$Eenheid contactpersoon] AS EC
              JOIN staedion_dm.Huuraanpassing.[Staedion$Job Responsibility] AS JR ON EC.Functie = JR.Code
              JOIN empire_data.dbo.Contact AS C ON EC.Contactnr_ = C.No_
         WHERE JR.Code = 'CB-VHTEAM'),
     CTE_geliberaliseerd
     AS (SELECT Eenheidnr_, 
                [Customer No_], 
                Huurprijsliberalisatie, 
                Volgnummer = ROW_NUMBER() OVER(PARTITION BY Eenheidnr_
                ORDER BY Eenheidnr_)
         FROM empire_staedion_data.hvh.staedion$contract
         WHERE Huurprijsliberalisatie = 1
               AND Ingangsdatum <= GETDATE()
               AND (Einddatum = '17530101'
                    OR Einddatum >= GETDATE()))

     -- afwijkingen tussen gemeentecode, gemeentenaam, Plaats 
     SELECT Eenheidnr = SIM.[Realty Object No_], 
            [Huidige nettohuur] = SIM.[Current Net Rent], 
            [Nieuwe nettohuur] = SIM.[New Net Rent], 
            BRONOGE.[Municipality Code], 
            [Corpodatatype] = TT.[Analysis Group Code], 
            BRONOGE.[Target Group Code], 
            [Huidige Maximale huurprijs] = ITVF1.Maximaal_toegestane_huur, 
            [Nieuwe Maximale huurprijs] = SIM.[Maximum Rent Price], 
            [Huidige nettohuur / max. huurprijs %] = IIF(COALESCE(ITVF1.Maximaal_toegestane_huur, 0) <> 0, SIM.[Current Net Rent] / ITVF1.Maximaal_toegestane_huur * 1.00, 0), 
            [Nieuwe nettohuur / max. huurprijs %] = IIF(COALESCE(SIM.[Maximum Rent Price], 0) <> 0, SIM.[New Net Rent] / SIM.[Maximum Rent Price] * 1.00, 0), 
            CTE_V.Verhuurteam, 
            [Daeb eigenaar Empire-kaart] = AO.[Dimension Value], 
            [DAEB-indicator] = AO.[Dimension Value]
            ,
            --,Teller = SIM.[Nieuwe nettohuur]
            --,Noemer = SIM.[Maximale huurprijs] 
            [Aantal boven percentage per 30-6] = IIF(COALESCE(ITVF1.Maximaal_toegestane_huur, 0) <> 0, IIF(ISNULL(SIM.[Current Net Rent], 0) / ITVF1.Maximaal_toegestane_huur > @Percentage, 1, 0), NULL), 
            [Aantal boven percentage per 1-7] = IIF(COALESCE(SIM.[Maximum Rent Price], 0) <> 0, IIF(ISNULL(SIM.[New Net Rent], 0) / SIM.[Maximum Rent Price] > @Percentage, 1, 0), NULL), 
            [Geliberaliseerd contract] = CASE
                                             WHEN LIB.Eenheidnr_ IS NULL
                                             THEN 'Nee'
                                             ELSE 'Ja'
                                         END
     --,[Opmerking datakwaliteit DAEB-indicator] = iif([DAEB-indicator] collate database_default <> replace(AO.[Dimension Value],'N_DAEB','Niet-DAEB') collate database_default, 'Afwijking in simulatie.daeb indictor vs Empire', '')
     --,[Opmerking datakwaliteit zelfstandig] = iif(BRONOGE.Woonruimte <> 0, 'Check eenheidkaart - toch onzelfstandig ?', '')

     FROM staedion_dm.Huuraanpassing.[Staedion$Oge Rent Increase] AS SIM
          JOIN staedion_dm.Huuraanpassing.Staedion$OGE AS BRONOGE ON BRONOGE.Nr_ COLLATE database_default = SIM.[Realty Object No_] COLLATE database_default
                                                                   AND BRONOGE.[Common Area] = 0
                                                                   AND BRONOGE.[Begin Exploitatie] <= GETDATE()
                                                                   AND (BRONOGE.[Einde exploitatie] >= GETDATE()
                                                                        OR BRONOGE.[Einde exploitatie] = '1753-01-01')
          LEFT OUTER JOIN CTE_geliberaliseerd AS LIB ON LIB.Eenheidnr_ COLLATE database_Default = SIM.[Realty Object No_] COLLATE database_Default
          LEFT OUTER JOIN staedion_dm.Huuraanpassing.Staedion$Type AS TT ON TT.Soort = 0
                                                                 AND TT.[Code] COLLATE database_default = BRONOGE.[Type] COLLATE database_default
          LEFT OUTER JOIN staedion_dm.Huuraanpassing.[Staedion$Oge Administrative Owner] AS AO ON AO.[Realty Object No_] COLLATE database_default = BRONOGE.Nr_ COLLATE database_default
                                                                                  AND AO.[Start Date] <= GETDATE()
                                                                                  AND (AO.[End Date] = '1753-01-01'
                                                                                       OR AO.[End Date] >= GETDATE())
          LEFT OUTER JOIN CTE_verhuurteam AS CTE_V ON CTE_V.Eenheidnr COLLATE database_default = SIM.[Realty Object No_] COLLATE database_default
          OUTER APPLY staedion_dm.Huuraanpassing.fn_Huurprijs(SIM.[Realty Object No_] COLLATE database_default, DATEFROMPARTS(YEAR(GETDATE()), 6, 30)) AS ITVF1
          OUTER APPLY staedion_dm.Huuraanpassing.fn_Huurprijs(SIM.[Realty Object No_], DATEFROMPARTS(YEAR(GETDATE()), 7, 1)) AS ITVF2
WHERE SIM.[Period Code] collate database_default like left(year(getdate()),4)+'%' collate database_default
and TT.[Analysis Group Code] = 'WON ZELF'
			-- Toen kpi maximaal redelijk boven 90% speelde werden deze condities toegevoegd
			--AND AO.[Dimension Value] = 'DAEB'
			--and CTE_V.Verhuurteam <> 'Verhuurteam 3 - studenten'



GO
