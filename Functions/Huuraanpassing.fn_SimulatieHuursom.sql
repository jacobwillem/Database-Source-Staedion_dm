SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [Huuraanpassing].[fn_SimulatieHuursom] (@Tijdvak nvarchar(20) = null ) 
returns table 
as
/* #################################################################################################################################
VAN				  JvdW
BETREFT			Functie voor verslaglegging om data van huursombenadering te kunnen analyseren na simulatie huurverhoging. Alleen default parameter voor tijdvak hoeft te worden aangepast.
------------------------------------------------------------------------------------------------------------------------------------
CHECK				select * from staedion_dm.Huuraanpassing.[[fn_SimulatieHuursom]] (default) where Opmerking = 'Contract 2020 ongewijzigd'
------------------------------------------------------------------------------------------------------------------------------------
WIJZIGING	  
20200323 JvdW - Versie 1: aangemaakt 
------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Huuraanpassing', 'fn_SimulatieHuursom'

SELECT *
FROM staedion_dm.Huuraanpassing.[fn_SimulatieHuursom](DEFAULT)
WHERE [Begin van tijdvak nettohuur] <> [Oude nettohuur simulatie]



################################################################################################################################# */
RETURN
WITH CTE_Additioneel
AS (
       SELECT Eenheidnr = Eenheidnr_ collate database_Default
              ,[Customer No_]
              ,Ingangsdatum
              ,Einddatum
              ,Opmerking = CASE 
                     WHEN Ingangsdatum <= datefromparts(year(getdate()), 1, 1)
                            AND Einddatum = '17530101'
                            THEN 'Contract ' + convert(NVARCHAR(4), year(getdate())) + ' ongewijzigd'
                     ELSE CASE 
                                   WHEN year(Einddatum) = year(getdate())
                                          OR year(Ingangsdatum) = year(getdate())
                                          THEN 'Telt volgens Empire mee maar contract-wijzging ?'
                                   END
                     END
              ,Volgnummer = row_number() OVER (
                     PARTITION BY Eenheidnr_ ORDER BY coalesce(nullif(Einddatum, '17530101'), '20991231') DESC
                            ,Ingangsdatum DESC
                     )
       FROM staedion_dm.Huuraanpassing.[Staedion$Additioneel]
       WHERE coalesce(nullif(Einddatum, '17530101'), '20991231') > Ingangsdatum
              --and Eenheidnr_  in ('OGEH-0018553','OGEH-0028594','OGEH-0026784')
       )
       ,CTE_Simulatie
AS (
       SELECT [Realty Object No_]
              ,Huurverhogingsbeleidstypecode = [Rent Incr_ Policy Type Code]
              ,[Huurverhogingsbeleidstype-omschrijving] = [Rent Incr_ Policy Type Descr_]
              ,[Oude netto huur] = [Current Net Rent]
              ,[Nieuwe netto huur] = [New Net Rent]
              ,[Corpodatatype] = [Realty Object Type CorpoData]
              ,[Verwerkingsstatus] = CASE [Processing Status]
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
              ,Volgnummer = row_number() OVER (
                     PARTITION BY [Realty Object No_] ORDER BY [Period Code] desc
                     )
       FROM staedion_dm.Huuraanpassing.[staedion$OGE Rent Increase] [Realty Object No_]
       WHERE ([Period Code] LIKE left(year(getdate()), 4) + '%' AND @Tijdvak IS NULL)
				OR [Period Code] = @Tijdvak
				)
SELECT Huursomtijdvakcode = HUURSOM.[Rent Sum Period Code]
       ,Eenheidnr = HUURSOM.[Realty Object No_]
       ,[Telt mee voor huursom] = HUURSOM.[Counts For Rent Sum]
       --,[Starting Contract Entry No_]
       --,[Starting Contract Type]
       --,[Ending Contract Entry No_]
       --,[Ending Contract Type]
       --,[Rent Sum Period Description]
       --,[Rent Sum Period Starting Date]
       ,[Begin van tijdvak nettohuur] = convert(FLOAT, HUURSOM.[Begin of Period Net Rent])
       ,[Oude nettohuur simulatie] = convert(FLOAT, SIM.[Oude netto huur])
       ,[Eind van tijdvak nettohuur] = convert(FLOAT, HUURSOM.[End of Period Net Rent])
       ,[Nieuwe nettohuur simulatie] = convert(FLOAT, SIM.[Nieuwe netto huur])
       ,[Nieuwe nettohuur 1-7] = convert(FLOAT, ITVF2.[Nettohuur])
       ,[Netto huur toename] = convert(FLOAT, HUURSOM.[Net Rent Increase])
       ,[Nettohuurtoenamepercentage] = convert(FLOAT, HUURSOM.[Net Rent Increase Percentage])
       ,[Gegenereerd] = HUURSOM.[Creation Date-Time]
       ,[Rent Increase Period Code]
       --,HUURSOM.[Maximum Basic Increase Perc_]
       --,HUURSOM.[Effective Rent Increase Perc_]			-- soms gekke percentages
       --,[Als woning verantwoorden] = HUURSOM.[Justify as House]
       --,HUURSOM.[Performance Agreement Made]
       ,HUURSOM.[Municipality Code]
       ,HUURSOM.[Municipality Name]
       --,[Voldoet aan randvoorwaarden] = HUURSOM.[Meets Basic Conditions]
       --,[Woonruimte] = HUURSOM.[Living Space]
       ,ADDIT.Opmerking
       ,[Ingangsdatum contract] = ADDIT.Ingangsdatum
       ,[Einddatum contract] = ADDIT.Einddatum
       ,Huurder = ADDIT.[Customer No_]
       ,SIM.Huurverhogingsbeleidstypecode
       ,SIM.[Huurverhogingsbeleidstype-omschrijving]
       ,SIM.[Corpodatatype]
       ,[Datum gegevens huursombenadering Empire] = HUURSOM.[Creation Date-Time]
       ,SIM.[Verwerkingsstatus] 
-- select distinct HUURSOM.[Justify as House],HUURSOM.[Meets Basic Conditions],HUURSOM.[Living Space],HUURSOM.[Counts For Rent Sum]
-- select sum([Net Rent Increase]) / sum([Begin of Period Net Rent]), count(*),  sum([Net Rent Increase]) 
-- select top 10 *
FROM staedion_dm.Huuraanpassing.[staedion$OGE Rent Sum] AS HUURSOM
LEFT OUTER JOIN CTE_Additioneel AS ADDIT
       ON ADDIT.Eenheidnr = HUURSOM.[Realty Object No_]
              AND ADDIT.Volgnummer = 1
LEFT OUTER JOIN CTE_Simulatie AS SIM
       ON SIM.[Realty Object No_] COLLATE database_default= HUURSOM.[Realty Object No_] COLLATE database_default
              AND SIM.Volgnummer = 1
OUTER APPLY staedion_dm.Huuraanpassing.fn_Huurprijs(HUURSOM.[Realty Object No_], datefromparts(year(getdate()), 7, 1)) AS ITVF2
WHERE ((HUURSOM.[Rent Sum Period Code] LIKE left(year(getdate()), 4) + '%' AND @Tijdvak IS NULL)
		OR HUURSOM.[Rent Sum Period Code] = @Tijdvak
		)
       AND HUURSOM.[Counts For Rent Sum] = 1
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Huuraanpassing', 'FUNCTION', N'fn_SimulatieHuursom', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Huuraanpassing', 'FUNCTION', N'fn_SimulatieHuursom', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Functie voor verslaglegging om data van huursombenadering te kunnen analyseren na simulatie huurverhoging. Alleen default parameter voor tijdvak hoeft te worden aangepast.', 'SCHEMA', N'Huuraanpassing', 'FUNCTION', N'fn_SimulatieHuursom', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select * from staedion_dm.Huuraanpassing.[fn_SimulatieHuursom] (default)', 'SCHEMA', N'Huuraanpassing', 'FUNCTION', N'fn_SimulatieHuursom', NULL, NULL
GO
