SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  function [Projecten].[fn_OpleveringStart_tijdelijk VERVALLEN] (@Peildatum as date = null, @SoortProject as nvarchar(50) = 'Nieuwbouw') 
returns table 
as
/* ###################################################################################################
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
JvdW 20201221 Aangemaakt tbv jaarplan 2021 obv ingevulde excel over nov 2020 (ingelezen in  staedion_dm.Projecten.InvulsheetOpleveringEnStart)
PP 20210204 Toevoeging van Jaarplan voorwaarde filter op peildatum
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
select * from Projecten.[fn_OpleveringStart_tijdelijk] ('20200131', 'Nieuwbouw');
select * from Projecten.[fn_OpleveringStart_tijdelijk] ('20200131', 'Woningverbetering');
select * from Projecten.[fn_OpleveringStart_tijdelijk] ('20200229', 'Nieuwbouw');
select * from Projecten.[fn_OpleveringStart_tijdelijk] ('20200229', 'Woningverbetering');
------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
-- Variant ter voorkoming foutmelding 2: The metadata could not be determined because statement 'exec (@sql)' in procedure 'dsp_info_object_en_velden'  contains dynamic SQL.  Consider using the WITH RESULT SETS clause to explicitly describe the result set.
SELECT * FROM OPENROWSET('SQLNCLI', 
'Server=s-dwh2012-db;Trusted_Connection=yes;', 
'EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] ''staedion_dm'', ''Projecten'', ''fn_OpleveringStart_tijdelijk''
WITH RESULT SETS  
(   ([NaamTabel] nvarchar(50) ,						-- meerdere resultset op te geven door () te gebruiken
    [Kenmerk] nvarchar(50) ,  
		[OmschrijvingObject] sql_variant ,  
    [Soort_object] nvarchar(50) ,      
		[NaamVeld] nvarchar(50) ,  
		[OmschrijvingVeld] sql_variant ,  
    [DataTypeVeld] nvarchar(50) ,  
		[MaximaleLengteVeld] int,
		[collation_name] nvarchar(50),  
		[Volgorde] smallint)
)
')

################################################################################################### */	
RETURN
WITH cte_peildatum
AS (
       SELECT Peildatum = Coalesce(@Peildatum, eomonth(dateadd(m, - 1, getdate())))
       )
SELECT [Soort Project]
       ,[Datum] = PEIL.Peildatum
       ,Project
       ,[Aantal start gerealiseerd] = CASE month(PEIL.Peildatum)
              WHEN 1
                     THEN coalesce([start 01], 0)
              WHEN 2
                     THEN coalesce([start 02], 0)
              WHEN 3
                     THEN coalesce([start 03], 0)
              WHEN 4
                     THEN coalesce([start 04], 0)
              WHEN 5
                     THEN coalesce([start 05], 0)
              WHEN 6
                     THEN coalesce([start 06], 0)
              WHEN 7
                     THEN coalesce([start 07], 0)
              WHEN 8
                     THEN coalesce([start 08], 0)
              WHEN 9
                     THEN coalesce([start 09], 0)
              WHEN 10
                     THEN coalesce([start 10], 0)
              WHEN 11
                     THEN coalesce([start 11], 0)
              WHEN 12
                     THEN coalesce([start 12], 0)
              END
       ,[Aantal oplevering gerealiseerd] = CASE month(PEIL.Peildatum)
              WHEN 1
                     THEN coalesce([oplevering 01], 0)
              WHEN 2
                     THEN coalesce([oplevering 02], 0)
              WHEN 3
                     THEN coalesce([oplevering 03], 0)
              WHEN 4
                     THEN coalesce([oplevering 04], 0)
              WHEN 5
                     THEN coalesce([oplevering 05], 0)
              WHEN 6
                     THEN coalesce([oplevering 06], 0)
              WHEN 7
                     THEN coalesce([oplevering 07], 0)
              WHEN 8
                     THEN coalesce([oplevering 08], 0)
              WHEN 9
                     THEN coalesce([oplevering 09], 0)
              WHEN 10
                     THEN coalesce([oplevering 10], 0)
              WHEN 11
                     THEN coalesce([oplevering 11], 0)
              WHEN 12
                     THEN coalesce([oplevering 12], 0)
              END

--select *, Opmerking = 'Bestand per mail ontvangen 17-12-2020'
FROM staedion_dm.Projecten.InvulsheetOpleveringEnStart
JOIN cte_peildatum AS PEIL
       ON 1 = 1
WHERE [Soort Project] = @SoortProject and Jaarplan = YEAR(PEIL.Peildatum)

GO
