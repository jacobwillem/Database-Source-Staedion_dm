SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE function [dbo].[ITVF_verdeelsleutels] ( @Peildatum date , @Verdeeltype nvarchar(20) = 'GEWOGEN' )
returns table 
as
/* #################################################################################################################################
------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
TESTEN
------------------------------------------------------------------------------------------------------------------------------------

select * from empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) where Verdeelsleutel_FT_cluster <> Verdeelsleutel_BB_cluster
select * from empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) where Corpodatatype = 'PP' and (Verdeelsleutel_BB_cluster <> 0.1 or Verdeelsleutel_FT_cluster <> 0.1 or Verdeelsleutel_KVS_cluster <> 0.1)
select * into #ff from empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) where Corpodatatype = 'PP' and (Verdeelsleutel_BB_cluster <> 0.1 or Verdeelsleutel_FT_cluster <> 0.1 or Verdeelsleutel_KVS_cluster <> 0.1)
select * into #f from empire_dwh.dbo.[ITVF_verdeelsleutels] ('20171201','GEWOGEN' )
			
select * from empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) where EenheidNr = 'OGEH-0004969'
select * from backup_empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) where EenheidNr = 'OGEH-0004969'
						
select count(*), count(distinct EenheidNr) from backup_empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) 
select count(*), count(distinct EenheidNr) from empire_dwh.dbo.[ITVF_verdeelsleutels] (default,'GEWOGEN' ) 

-- Waar dubbelen ?						
SELECT *
FROM backup_empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN')
WHERE EenheidNr IN (
      SELECT Eenheidnr
      FROM backup_empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN')
      GROUP BY Eenheidnr
      HAVING count(*) > 1
      )




------------------------------------------------------------------------------------------------------------------------------------
WIJZIGING	  20180504 JvdW - test view of sproc voor ophalen actuals projectadministratie
						20180528 JvdW - Versie 2: peildatum werd niet getoond 
						20180605 JvdW - Versie 1: POGC verdeelsleeutels toegevoegd, hernoemde functie naar [ITVF_verdeelsleutels]
						20181001 JvdW - Versie 4: 18 10 059 Uitbreiding excel-rapportage verdeelsleutels empire	
						20181231 JvdW - Versie 5: toevoeging van SVKN / SVKI / Water / STKN-cluster van betreffende eenheid

NOG DOEN		Eventueel uniek maken regels en aangeven waar er dubbelen ontstaan
------------------------------------------------------------------------------------------------------------------------------------
BASIS				empire_dwh: 
						-- NB: verdeelsleutel = int !!! moet zijn decimal
						select ce.datum,c.bk_nr_, e.bk_nr_,  ce.verdeelsleutel,v.descr
						from empire_dwh.dbo.cluster_eenheid as ce
						join empire_dwh.dbo.cluster as c
						on c.id = ce.fk_cluster_id
						join empire_dwh.dbo.eenheid as e
						on e.id = ce.fk_eenheid_id
						join empire_dwh.dbo.verdeelsleuteltype as v
						on v.id = ce.fk_verdeelsleuteltype_id 
						where c.bk_nr_ = 'FT-1101'
						and ce.datum = (select loading_Day from empire_logic.dbo.dlt_loading_day)
						and	e.bk_nr_ = 'OGEH-0002001'
						order by datum 

BASIS				empire_data
						select count(*) from empire_data.[dbo].[Staedion$Cluster_Distribution_Key_Types]
						select count(*) from empire_data.[dbo].[Staedion$Cluster_Distrn_Keys_Header] 
						select count(*) from empire_data.[dbo].[Staedion$Cluster_Distrn_Keys_Line]

						select	distinct left([Cluster no_],3) from empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Header]
						select	left(BASIS.[Cluster no_],3),count(LINE.[Realty Unit No_])
						from		empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Header] as BASIS
						join 		empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Line] as LINE
						on			BASIS.[Cluster No_] = LINE.[Cluster No_]
						and			BASIS.[Distribution Key Type] = LINE.[Distribution Key Type]
						and			BASIS.[Version No_] = LINE.[Version No_]
						where		BASIS.[Start date] <= getdate()
						and			(BASIS.[End Date] >=getdate() or BASIS.[End Date] = '17530101')
						group by left(BASIS.[Cluster no_],3)
################################################################################################################################# */

return

/* TEST
 Declare @Verdeeltype nvarchar(20) = 'GEWOGEN'; 
 Declare @Peildatum datetime = getdate();
 Declare @Clusternr nvarchar(20) = null; -- 'FT-1453';
 Declare @Eenheidnr nvarchar(20) = 'OGEH-0053005';
*/

	WITH 
	CTE_BASIS ([Cluster No_], [Distribution Key Type], [Start Date],[End Date], [Status], [Version No_], Volgnr)
					as 
					(select	[Cluster No_],[Distribution Key Type], [Start Date],[End Date], [Status], [Version No_],row_number() over (partition by [Cluster No_],[Distribution Key Type], [Start Date] order by [Version No_] desc)																
					from		empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Header]
					where		[Distribution Key Type] = @Verdeeltype
						 AND [Status] = 1 --Geactiveerd (er zijn op een peildata soms meerdere regels actief (0 = voorlopig)
						 and  [Start date] <= isnull(@Peildatum, getdate())
									 AND (
													[End Date] >= isnull(@Peildatum, getdate())
													OR [End Date] = '17530101'
													)
							)
					,
	CTE_VERDEEL ([Cluster No_], [Distribution Key Type], [Start Date],[End Date], [Status], [Version No_], [Realty Unit No_],Numerator)
					as
					(select	BASIS.[Cluster No_], BASIS.[Distribution Key Type], BASIS.[Start Date],BASIS.[End Date], BASIS.[Status], BASIS.[Version No_], LINE.[Realty Unit No_],LINE.Numerator
					from		CTE_BASIS as BASIS
					join 		empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Line] as LINE
					on			BASIS.[Cluster No_] = LINE.[Cluster No_]
					and			BASIS.[Distribution Key Type] = LINE.[Distribution Key Type]
					and			BASIS.[Version No_] = LINE.[Version No_]
					where		BASIS.[Start date] <= isnull(@Peildatum,getdate())
					and			(BASIS.[End Date] >=isnull(@Peildatum,getdate()) or BASIS.[End Date] = '17530101')
					and			BASIS.Volgnr = 1)
					,
	CTE_BASISPROJECT ([Cluster No_], [Distribution Key Type], [Start Date],[End Date], [Status], [Version No_], Volgnr)
					as 
					(select	[Cluster No_],[Distribution Key Type], [Start Date],[End Date], [Status], [Version No_],row_number() over (partition by [Cluster No_],[Distribution Key Type], [Start Date] order by [Version No_] desc)																
					from		empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Header]
					where		[Distribution Key Type] = 'LINEAIR'
						 AND [Status] = 1 --Geactiveerd (er zijn op een peildata soms meerdere regels actief (0 = voorlopig)
						 and  [Start date] <= isnull(@Peildatum, getdate())
									 AND (
													[End Date] >= isnull(@Peildatum, getdate())
													OR [End Date] = '17530101'
													)
					)
					,
	CTE_PROJECT ([Cluster No_], [Distribution Key Type], [Start Date],[End Date], [Status], [Version No_], [Realty Unit No_],Numerator)
					as
					(select	BASIS.[Cluster No_], BASIS.[Distribution Key Type], BASIS.[Start Date],BASIS.[End Date], BASIS.[Status], BASIS.[Version No_], LINE.[Realty Unit No_],LINE.Numerator
					from		CTE_BASISPROJECT as BASIS
					join 		empire_Data.dbo.[Staedion$Cluster_Distrn_Keys_Line] as LINE
					on			BASIS.[Cluster No_] = LINE.[Cluster No_]
					and			BASIS.[Distribution Key Type] = LINE.[Distribution Key Type]
					and			BASIS.[Version No_] = LINE.[Version No_]
					where		BASIS.[Start date] <= isnull(@Peildatum,getdate())
					and			(BASIS.[End Date] >=isnull(@Peildatum,getdate()) or BASIS.[End Date] = '17530101')
					and			BASIS.Volgnr = 1)
					,
	CTE_Peildatum (Peildatum) 
					as			
					(select	isnull(@Peildatum,getdate())) 

	select						Datum														= Peildatum,
										Verdeelsleuteltype							= @Verdeeltype,
										[Sleutel eenheid]								= DWH.id ,
										Eenheidnummer										= OGE.Nr_,
										[KVS-clusternummer]							= CTE_G_KVS.[Cluster No_],
										[KVS-verdeelsleutel]						= CTE_G_KVS.Numerator,
										-- redundant toegevoegd
										[FT-clusternummer]							= I.[Clusternr],
										[FT-clusternaam]								= I.[Clusternaam],
										[Adres eenheid] 								= OGE.straatnaam + '  ' + OGE.huisnr_ + '  ' + OGE.Toevoegsel,
										[Corpodata type]								= TT.[Analysis Group Code],
										[Technisch type]								= TT.Omschrijving,
										[Datum in exploitatie]					= OGE.[Begin exploitatie],
										[Datum uit exploitatie]					= OGE.[Einde exploitatie]
	from							empire_data.dbo.[Staedion$oge] as OGE
	join							empire_data.dbo.[Staedion$Type] as TT
	on								OGE.[Type] = TT.[Code]
	and								TT.Soort = 0
	left outer join		CTE_VERDEEL as CTE_G_KVS
	on								CTE_G_KVS.[Realty Unit No_] = OGE.Nr_
	and								CTE_G_KVS.[Cluster No_] like 'KVS%' 
	join							CTE_Peildatum CTE_P
	on 								1=1
	join							empire_dwh.dbo.eenheid as DWH
	on								DWH.bk_nr_ = OGE.Nr_
	and								DWH.da_bedrijf = 'Staedion'
	CROSS APPLY empire_staedion_data.[dbo].[ITVfnCLusterBouwblok](OGE.nr_) AS I			
	where							OGE.[Begin exploitatie] <= CTE_P.Peildatum
	and								(OGE.[Einde exploitatie] > CTE_P.Peildatum or OGE.[Einde exploitatie] ='17530101' )
--	and								OGE.nr_ in ('OGEH-0000983','OGEH-0053005')
GO
