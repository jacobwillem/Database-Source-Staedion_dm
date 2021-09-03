SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Datakwaliteit].[OntbrekendeKalehuur]
as

SELECT Eenheidnr = BRON.Nr_, 
       CLUS.Clusternr, 
       CLUS.Clusternaam, 
       Assetmanager = coalesce(CONT.Assetmanager, 'Onbekend'), 
       [Huurder] = coalesce(HRD.huurder1, 'Leegstand'),
       [Kalehuur] = coalesce(HPR.kalehuur,0),
			 [Korting] =   coalesce(HPR.nettohuur_incl_korting_btw,0),
			 [Type eenheid] = TT.Omschrijving,
			 BRON.[Begin exploitatie] ,
			 BRON.[Einde exploitatie] ,
			 HPR.huurdernr,
			 Brutohuur =  coalesce(HPR.brutohuur_inclbtw,0),
			 Huurverhogingsbeleidstype = BRON.[Rent Increase Policy Type Code]
			 -- select top 10 TT.*
FROM empire_data.dbo.staedion$oge AS BRON
left outer join empire_Data.dbo.staedion$type as TT
on TT.[Code] = BRON.[Type]
and TT.Soort <> 2
     OUTER APPLY empire_staedion_data.[dbo].[ITVFnContactbeheerInclNaam](BRON.Nr_) AS CONT
     OUTER APPLY empire_staedion_data.[dbo].ITVfnCLusterBouwblok(BRON.Nr_) AS CLUS
     OUTER APPLY empire_staedion_data.[dbo].[ITVfnHuurprijs](BRON.Nr_, getdate()) AS HPR
     OUTER APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(HPR.huurdernr) AS HRD
WHERE BRON.[Common Area] = 0
and HPR.kalehuur = 0
and BRON.[Begin exploitatie] <> '17530101'
and BRON.[Einde exploitatie] = '17530101'
and BRON.[Status] in (0,3)  -- =Leegstand,Uit beheer,Renovatie,Verhuurd,Administratief,Verkocht,In ontwikkeling
--and BRON.Nr_ = 'OGEH-0061514'

GO
