SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE function [Huuraanpassing].[fn_CollectieveContracten] (@Tijdvak nvarchar(20) = null, @BatchCollectief nvarchar(20) = 'BRIEFCOLL' ) 
returns table 
as
/* #################################################################################################################################
WIJZIGING	  
20200401 JvdW - Versie 1: aangemaakt 
20210419 JvdW - Versie 2: aangepast 
------------------------------------------------------------------------------------------------------------------------------------
TEST
------------------------------------------------------------------------------------------------------------------------------------
select * from staedion_dm.Huuraanpassing.[fn_CollectieveContracten](default,default) where Klantnummer = 'HRDR-0040699'

select	Tijdvak, Eenheid, Volgnummer, Huurdernaam, Klantnummer, Postcode, Plaats, Prolongatietermijn 
from		empire_Dwh.dbo.[ITVF_hvh_collectieve_contracten_testomgeving] (default, default)

select count(*),sum([Brutohuur 3006 contractregel]),sum([[Brutohuur 0107 contractregel]) FROM staedion_dm.Huuraanpassing.fn_CollectieveContracten (default, default)
select count(*), sum([Brutohuur 3006]),sum([Brutohuur 0107]) FROM empire_dwh.dbo.[tmv_hvh_collectieve_contracten_testomgeving TE VERWIJDEREN]


------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Huuraanpassing', 'fn_CollectieveContracten'

-- extended property toevoegen op object-niveau
USE staedion_dm
GO
EXEC sys.sp_Updateextendedproperty   
@name = N'MS_Description',   
@value = N'Betreft de gegevens per 30-6 en 1-7 van het lopend jaar van de eenheden die in de simulatie het kenmerk "BRIEFCOLL" hebben meegekregen. Betreft dus bevroren gegevens ten tijde van het huuraanpassingsweekend.
NB: dit rapport is ook in een testfase te gebruiken door de data van die testomgeving te kopieren naar de aan dit bestand ten grondslag liggende bron (staedion_dm.Huuraanpassing). ',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'FUNCTION',  @level1name = 'fn_CollectieveContracten'
;
EXEC sys.sp_Updateextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'FUNCTION',  @level1name = 'fn_CollectieveContracten'
;
EXEC sys.sp_Updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select * from staedion_dm.Huuraanpassing.[fn_CollectieveContracten](default,default)',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'FUNCTION',  @level1name = 'fn_CollectieveContracten'
;  
EXEC sys.sp_Updateextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Huuraanpassing',  
@level1type = N'FUNCTION',  @level1name = 'fn_CollectieveContracten'
;  



------------------------------------------------------------------------------------------------------------------------------------
PERFORMANCE: vermoedelijk indexen nodig !!
------------------------------------------------------------------------------------------------------------------------------------
use staedion_dm
;
CREATE NONCLUSTERED INDEX i1_Staedion$Property_Valuation
ON [Huuraanpassing].[Staedion$Property Valuation] ([Eenheidnr_],[Ingangsdatum],[Einddatum])
INCLUDE ([Volgnummer])
GO
USE [staedion_dm]
GO
CREATE NONCLUSTERED INDEX i1_Staedion$$element
ON [Huuraanpassing].[staedion$element] ([Tabel],[Eenheidnr_],[Eenmalig])
INCLUDE ([Volgnummer],[BTW-productboekingsgroep],[Soort],[Bedrag (LV)],[Elementsoort],[Administratie],[Leges],[Diversen])


################################################################################################################################# */
RETURN
WITH CTE_Tijdvak
AS (
       SELECT Tijdvak = coalesce(@Tijdvak, convert(NVARCHAR(9), left(year(getdate()), 4) + '-' + left(year(dateadd(yy, 1, getdate())), 4)))
			 ,[Gegenereerd] = (select max([Preparation Date-Time]) from staedion_dm.Huuraanpassing.[staedion$OGE Rent Increase])

       )
SELECT Tijdvak = SIM.[Period Code]
       ,Eenheid = OGE.Nr_
       ,Volgnummer = CONTR.Volgnr_
       ,Huurdernaam = coalesce(nullif(CONTR.Naam, ' '), 'Leegstand')
       ,Klantnummer = coalesce(nullif(CONTR.[Customer No_], ''), 'Leegstand')
       ,Huurderadres = coalesce(nullif(CUST.[Address], ''), 'Leegstand')
       ,Postcode = coalesce(nullif(CUST.[Post Code], ''), 'Leegstand')
       ,Plaats = coalesce(nullif(CUST.City, ''), 'Leegstand')
       ,CONTR.Prolongatietermijn
       ,[Sleutel eenheidnummer] = NULL
       ,[Indexeringsbatchnaam contractregel] = CONTR.indexeringsbatchnaam
       ,[Indexeringsbatchnaam simulatie] = SIM.[Batch Code]
       ,[Huurverhogingsbeleidstype ogekaart] = OGE.[Rent Increase Policy Type Code]
       ,[Huurverhogingsbeleidstype simulatie] = SIM.[Rent Incr_ Policy Type Code]
       ,[Nettohuuraftopping opgekaart] = OGE.[Net Rent Capping Code]
       ,[Nettohuuraftopping simulatie] = SIM.[Net Rent Capping Code]
       ,[Nettohuur 3006 simulatie] = convert(FLOAT, SIM.[Current Net Rent])
       ,[Nettohuur 0107 simulatie] = convert(FLOAT, SIM.[New Net Rent])
       ,[Nettohuur 3006 contractregel] = convert(FLOAT, ITVF1.Nettohuur)
       ,[Nettohuur 0107 contractregel] = convert(FLOAT, ITVF2.Nettohuur)
       ,[Brutohuur 3006 contractregel] = convert(FLOAT, ITVF1.Brutohuur)
       ,[Brutohuur 0107 contractregel] = convert(FLOAT, ITVF2.Brutohuur)
       ,[Brutohuur 3006 contractregel incl btw] = convert(FLOAT, ITVF1.brutohuur_inclbtw)
       ,[Brutohuur 0107 contractregel incl btw] = convert(FLOAT, ITVF2.brutohuur_inclbtw)
	   ,[Gegenereerd] = (select [Gegenereerd] from CTE_Tijdvak)
-- select top 10 OGE.*
-- select count(*), count(distinct OGE.Nr_)
FROM staedion_dm.Huuraanpassing.[Staedion$oge] AS OGE
LEFT OUTER JOIN staedion_dm.Huuraanpassing.[staedion$OGE Rent Increase] AS SIM
       ON SIM.[Period Code] = (
                     SELECT Tijdvak
                     FROM CTE_Tijdvak
                     )
              AND SIM.[Realty Object No_] = OGE.Nr_
LEFT OUTER JOIN staedion_dm.Huuraanpassing.[staedion$Contract] AS CONTR
       ON CONTR.Eenheidnr_ = OGE.Nr_
              -- AND SIM.[Contract Entry No_] = CONTR.Volgnr_					-- te gebruiken als 1-7-regels nog niet zijn doorgevoerd
							and SIM.[New Contract Entry No_] = CONTR.Volgnr_	-- te gebruiken als 1-7-regels zijn doorgevoerd
LEFT OUTER JOIN staedion_dm.Huuraanpassing.Customer AS CUST
       ON CUST.No_ collate database_Default = CONTR.[Customer No_] collate database_Default
OUTER APPLY staedion_dm.Huuraanpassing.fn_Huurprijs(CONTR.eenheidnr_, datefromparts(year(getdate()), 6, 30)) AS ITVF1
OUTER APPLY staedion_dm.Huuraanpassing.fn_Huurprijs(CONTR.eenheidnr_, datefromparts(year(getdate()), 7, 1)) AS ITVF2
WHERE OGE.[Common Area] = 0
       AND OGE.[Begin exploitatie] <= getdate()
       AND (
              OGE.[Einde exploitatie] >= getdate()
              OR OGE.[Einde exploitatie] = '17530101'
              )
       AND (
              CONTR.indexeringsbatchnaam = @BatchCollectief
              OR SIM.[Batch Code] = @BatchCollectief
              )
GO
