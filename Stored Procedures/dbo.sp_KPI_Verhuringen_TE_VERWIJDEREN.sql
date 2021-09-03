SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_KPI_Verhuringen_TE_VERWIJDEREN] 
as  
/*#################################################################################
VAN 			Jaco
BETREFT			Verwerken prognoses in kubus (live)
----------------------------------------------------------------------------------
TESTEN			
exec [dbo].[dsp_ssas_ProcessKubusKPI] 'Foute naam' 
			
----------------------------------------------------------------------------------
WIJZIGING		
20191210 Aangemaakt
----------------------------------------------------------------------------------
TIJDELIJK
----------------------------------------------------------------------------------

##################################################################################*/

BEGIN TRY

	------------------------------------------------
	-- STAP 0) Parameters verwerken
	------------------------------------------------
	declare @start as datetime
	declare @finish as datetime
	declare @tijdsduur as datetime
	set		@start =current_timestamp

	------------------------------------------------
	-- STAP 1) Input verwerken van sharepoint
	------------------------------------------------
	-- NB: als huurder nog een keer een woning betrekt dan haal je deze niet op met onderstaande query !
;

WITH cte_eerste_contract
AS (
       SELECT [Eenheidnr_]
              ,[Customer No_]
              ,Ingangsdatum = min([Ingangsdatum])
       FROM empire_Data.dbo.[Staedion$Contract]
       --WHERE [Dummy Contract] = 0 
       WHERE (
                     Einddatum > [Ingangsdatum]
                     OR Einddatum = '17530101'
                     )
              AND [Customer No_] <> ''
       GROUP BY [Eenheidnr_]
              ,[Customer No_]
       )
       ,cte_indicator
AS (
       SELECT id
       FROM Dashboard.Indicator
       WHERE Omschrijving = 'Aantal verhuringen 2020'
       )
INSERT INTO [staedion_dm].[Dashboard].[Realisatie] (
       fk_indicator_id
       ,datum
       ,waarde
			 ,laaddatum
       )
SELECT CTE_I.id
       ,Datum = eomonth(min(C.Ingangsdatum))
       ,Aantal = count(*)
			 ,Laaddatum = getdate()
--into #verhuringen_contract
FROM empire_data.dbo.staedion$Contract AS C
JOIN cte_eerste_contract AS CTE_eerste
       ON CTE_eerste.[Customer No_] = C.[Customer No_]
              AND CTE_eerste.[Eenheidnr_] = C.Eenheidnr_
JOIN empire_Data.dbo.staedion$oge AS OGE
       ON OGE.Nr_ = C.Eenheidnr_
JOIN empire_Data.dbo.staedion$Type AS TT
       ON TT.[Code] = OGE.[Type]
              AND TT.Soort = 0
JOIN cte_indicator AS CTE_I
       ON 1 = 1
WHERE TT.[Analysis Group Code] LIKE '%WON%'
       AND year(CTE_eerste.Ingangsdatum) = 2019
GROUP BY month(C.Ingangsdatum), CTE_I.id

  
	set		@finish = current_timestamp
	set		@tijdsduur = @finish - @start

	select 'Tijdsduur: ' 
					+ convert(varchar(15),@tijdsduur,108)
					+ ' - gegevens zijn verwerkt in kubus: ' AS onderwerp

	END TRY
	BEGIN CATCH

		set		@finish = current_timestamp
		set		@tijdsduur = @finish - @start
	
		select 'Tijdsduur: ' 
					+ convert(varchar(15),@tijdsduur,108)
					+ ' - foutmelding voor Jaco\Eric: ' 
					+ ERROR_MESSAGE()  
					+ ' - procedure: ' 
					+ ERROR_PROCEDURE() AS onderwerp

	END CATCH;
GO
