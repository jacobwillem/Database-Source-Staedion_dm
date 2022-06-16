SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
















CREATE view	[Medewerker].[TalentVisma OUD]
as 
/* ###################################################################################################
VAN				JvdW
BETREFT		view obv dagelijks bijgewerkte xml-gegevens van Talent\Visma zoals verwerkt in tabellen database [TS_data]_20190111
						> Toont afdeling per vandaag dan wel bij vertrokken werknemers: laatst bekende afdeling
						> Toont Functie per vandaag dan wel bij vertrokken werknemers: laatst bekende functie
STATUS			Productie, versie 12
ZIE					A 41796 Centrale bron werknemersgegevens in dwh
CHECK				select Personeelsnr from visma.Werknemers group by Personeelsnr having count(*) > 1
						select * from [empire_staedion_data].visma.Werknemers where [Datum uit dienst] is null and ([Organisatie niveau 1] is null or [Organisatie niveau 1] = '')

						select count(*) from [empire_staedion_data].bak.Werknemers_20190117
						select count(*) from [empire_staedion_data].visma.Werknemers 
						select personeelsnr, count(*) from [empire_staedion_data].visma.Werknemers  group by personeelsnr having count(*) > 1
						select Empire_wrkn, count(*) from [empire_staedion_data].visma.Werknemers  group by Empire_wrkn having count(*) > 1
						select Empire_wrkn, count(*) from [empire_staedion_data].bak.Werknemers_20190117  group by Empire_wrkn having count(*) > 1

						select	[Organisatie niveau 1]
								,[Organisatie niveau 2]
								,[Organisatie niveau 3]
								,[Organisatie niveau 4]
								,[Organisatie niveau 5]
								,[Organisatie niveau 6]
								,Kostenplaats
								,(select Name from empire_data.dbo.staedion$dimension_value where Code = Kostenplaats) as Kostenplaats_omschrijving
								,count(*)
						from	[empire_staedion_data].visma.Werknemers 
						where	[Datum uit dienst] is null 
						group by [Organisatie niveau 1]
								,[Organisatie niveau 2]
								,[Organisatie niveau 3]
								,[Organisatie niveau 4]
								,[Organisatie niveau 5]
								,[Organisatie niveau 6]
								,Kostenplaats
-----------------------------------------------------------------------------------
WIJZIGINGEN	20170614 aangemaakt 
						20170824 Versie 2: nav 
									select distinct [KamerNr],Locatie,[Limiet goedkeuring] from empire_staedion_data.visma.Werknemers
									select distinct [Personeelsnr manager],[Leidinggevende] from empire_staedion_data.visma.Werknemers
									select * from empire_staedion_data.visma.Werknemers where [Organisatie niveau 4] like '%Treasury%'
								Na controle aanpassingen gedaan mbt MAIL / TEL om dubbele regels te voorkomen
						20171204 Versie 4: 
										uitgecommentarieerd: and manager_personeelsnr <> 100918055			-- WORKAROUND dubbele foute regels: zorgden voor dubbeltellingen		
										geen dubbelen en organisatie-niveau is gevuld
						20171206 Versie 5: Kostenplaats toegevoegd + Organisatie niveau 3 + check in commentaar
						20180110 Versie 6: Marieke Kramer uit dienst  ? 
										> cte con anders opgesteld
										> waarom eigenlijk niet cte obv startdate / enddate ?
						20180122 Versie 7: Toegevoegd
										tlt_model_employees.hrm_salaris
										tlt_model_employees.hrm_salaris_uur
										tlt_model_employees.Hrm_srt_arb_contr
										tlt_model_employees.Hrm_dlt_fakt
										tlt_model_employees.hrm_omschrijving
						20180215 Versie 8: na aanpassing van data-engineers meerdere records voor employees - hoogste id nemen 
											select [Personeelsnr], count(*) 
											from	empire_staedion_Data.visma.[Werknemers]
											group by Personeelsnr
											having count(*) > 1
						20180314 Versie 9: tbv processen OLAP een record voor onbekend opgevoerd
						20180906 Versie 10: kolom [werknemernr uit empire] + [resourcenr uit empire] toegevoegd tbv integratie met Empire
											select count(*) 
											from	empire_staedion_Data.visma.[Werknemers]

											select	count(*),sum(case when Empire_wrkn is not null then 1 else 0 end),sum(case when Empire_res is not null then 1 else 0 end)
											from empire_staedion_Data.visma.[Werknemers]
						20190201 R17 / Cloudversie
												* Veld verwijderd:
												select	pos_kamer_nr, pos_locatie_code, pos_locatie_tekst
												from		empire_staedion_data.bak.[tlt_model_sub_departments] 
												=> waarde [Onbekend, nvt]
						20190404 paar lege waarden voor full_name
						20190410 dubbele regel: uitdienst moet na indienst liggen
											select count(*) from empire_Staedion_Data.visma.werknemers -- 1272
											select count(*) from empire_Staedion_Data.visma.werknemers -- 1271
            20190610 Versie 14: dubbele EMPIRE_WRKN: geeft issues in pbi
												select Empire_wrkn,* 
												from	 empire_staedion_data.visma.Werknemers 
												where  Empire_wrkn in ( 'WRKN-01465','WRKN-00851','WRKN-00921','WRKN-01669')
												order by 1

												select Code, staedion_inlognaam,*
												from	empire_data.dbo.salesperson_purchaser
												where Code in ( 'WRKN-01465','WRKN-00851','WRKN-00921','WRKN-01669')

												
tlt_model_sub_departments.vestiging_valuename ipv pos_locatie_tekst
tlt_model_sub_departments.vestiging_value ipv pos_locatie_code
tlt_model_sub_departments.kamernummer_value ipv pos_kamer_nr

												select	 	approval_limit
												from		empire_staedion_data.bak.[tlt_model_sub_departments
												=> waarde [Onbekend, nvt]

												* R17 verwïjderd:
												[salesperson_purchaser].[User ID]														
												=> maatwerk: staedion_inlognaam

												* Wel aanwezig maar nog leeg: 
												select distinct hrm_inlognaam, hrm_srt_arb_contr, hrm_salaris, hrm_salaris_uur, hrm_dlt_fakt, hrm_omschrijving, hrm_fullname
												from		empire_staedion_data.bak.[tlt_model_employees]  		
												
												* Omdat hrm_inlognaam ook leeg is, deze gevuld obv werk-email + idem voor Empire_wrkn + Empire_res !!

												* Veiligheidshalve daar waar gegevens nog ontbreken voor onderstaande kolommen de waarde nemen van 17-01-2019											 
														Maandsalaris, [Salaris per uur], [Soort arbeidscontract], [Deeltijdfactor], [Werknemersgroep]
														, [KamerNr]	,[Locatie]	,[Limiet goedkeuring],[Personeelsnr manager]
---------------------------------------------------------------------------------------------------------------------------------------------											
																		

												SELECT [Inlognaam]
															,[EMP_id]
															,[Empire_wrkn]
															,[Empire_res]
													FROM [empire_staedion_data].[visma].[Werknemers CLOUD VERSIE NOG AANPASSEN]

												SELECT [Inlognaam]
															,[EMP_id]
															,[Empire_wrkn]
															,[Empire_res]
													FROM [empire_staedion_data].[visma].[Werknemers] 
				
													-- check aantallen
													select	 Personeelsnr  , [Volledige naam] ,[Datum in dienst],[Datum Uit Dienst]
													from		[visma].[Werknemers CLOUD VERSIE NOG AANPASSEN]
													except
													select	 Personeelsnr  , [Volledige naam] ,[Datum in dienst],[Datum Uit Dienst]
													from		[visma].[Werknemers]

													-- check afdeling ed
													select	 Personeelsnr  , [Volledige naam] ,[Bedrijfsonderdeel],[Afdeling]
													from		[visma].[Werknemers CLOUD VERSIE NOG AANPASSEN]
													except
													select	 Personeelsnr  , [Volledige naam] , [Bedrijfsonderdeel],[Afdeling]
													from		[visma].[Werknemers]
-----------------------------------------------------------------------------------
OUDE KOPPELING
						SELECT	[Voornaam],[Tussenvoegsel],[Achternaam],[Geboortedatum],[Functie],Afdeling
								,[Bedrijfsonderdeel],[Telefoon],[E-mail],[Inlognaam]
								,[Datum In Dienst],[Datum Uit Dienst],[Personeelsnr],[Manager],[MobielNr],[Voorletters]
						FROM	[S-EHRM].[IntranetSync].[dbo].[vIntranetkoppelingExport]
						where Voornaam = 'Jaco'
                   					  		
										-- Vergelijk OUD
						select	Inlognaam,Achternaam,Functie, [Datum in dienst],[Datum uit dienst]
						from	[S-EHRM].[IntranetSync].[dbo].[vIntranetkoppelingExport] 
						where	lower(Afdeling) = 'klantenservice' 
						and		[Datum uit dienst] = ''

						select	inlognaam, Achternaam,Functie, [Datum in dienst], [Datum Uit Dienst],*
						from	empire_staedion_data.visma.Werknemers 
						where	lower(Afdeling) = 'klantenservice' 
						and		[Datum in dienst] <=getdate()
						and		([Datum uit dienst] is null or [Datum uit dienst] >=getdate())


														
################################################################################################### */	
with 
EMP	(com_id, employeeid, salutationid, salutation, initials, firstname, nickname, nameusage, birthname, prefixbirthname, partnername, prefixpartnername, use_first_name, use_lastname, use_fullname, dateofbirth, officialdate, maritalstatusid, maritalstatus, gender, bsn, corraddress, nationality, [language], titlebefore, titleafter, hrm_fullname, hrm_inlognaam, hrm_employeeid, id, hrm_srt_arb_contr, hrm_salaris, hrm_salaris_uur, hrm_dlt_fakt, hrm_omschrijving, volgnr)
as (select com_id, employeeid, salutationid, salutation, initials, firstname, nickname, nameusage, birthname, prefixbirthname, partnername, prefixpartnername, use_first_name, use_lastname, use_fullname, dateofbirth, officialdate, maritalstatusid, maritalstatus, gender, bsn, corraddress, nationality, [language], titlebefore, titleafter, hrm_fullname, hrm_inlognaam, hrm_employeeid, id, hrm_srt_arb_contr, hrm_salaris, hrm_salaris_uur, hrm_dlt_fakt, hrm_omschrijving,  row_number() over (partition by employeeid order by id  desc)
		from	empire_staedion_data.bak.[tlt_model_employees] 
		),
AFD (id,sco_id,costcenter,orgunit,orgunitname,validfrom,validuntil,kamernummer_value, vestiging_value, vestiging_valuename,volgnr)
	as (select id,sco_id,costcenter,orgunit,orgunitname,validfrom,validuntil
		, convert(nvarchar(100),kamernummer_value) as kamernummer_value -- Als text-kolom gedefineerd ?
		, convert(nvarchar(100),vestiging_value) as vestiging_value -- Als text-kolom gedefineerd ?
		, convert(nvarchar(100),vestiging_valuename ) as vestiging_valuename -- Als text-kolom gedefineerd ?
		, row_number() over (partition by sco_id order by validfrom  desc) 
		from	empire_staedion_data.bak.[tlt_model_sub_departments]
		where	validfrom <= getdate()),
FUN (id,sco_id,costunit,functionid,functionname,validfrom,validuntil,approval_limit,volgnr)
	as (select id,sco_id,costunit,functionid,functionname,validfrom,validuntil
		, '[Onbekend, nvt]' as approval_limit
		, row_number() over (partition by sco_id order by validfrom  desc) as  volgnr	
		from	empire_staedion_data.bak.[tlt_model_sub_functions]
		where	validfrom <= getdate()),
CON (id, emp_id,startdate,enddate,endreasonname,volgnr)
	as (select id,emp_id,startdate,enddate,endreasonname
-- 20180110		, row_number() over (partition by emp_id order by subcontractid  desc) as  volgnr	
				, row_number() over (partition by emp_id order by isnull(enddate,'20990101') desc) as  volgnr	
		from	empire_staedion_data.bak.[tlt_model_sub_contracts]),
BRON (bestandsnaam, tijdstempel, volgnr)
	as (select filename,filestamp, row_number() over (partition by companyname order by filestamp desc) as volgnr
			from empire_staedion_data.bak.[tlt_model_companies]),
TEL (emp_id, phonetypeid, phonetype, phoneno, volgnr)
	as (select emp_id,phonetypeid, phonetype, phoneno, row_number() over (partition by emp_id,phonetypeid order by phoneno desc) as volgnr
			from empire_staedion_data.bak.[tlt_model_phones]),
MAIL (emp_id, emailtypeid, emailtype, emailaddress, volgnr)
	as (select emp_id, emailtypeid, emailtype, emailaddress, row_number() over (partition by emp_id, emailtypeid order by emailaddress desc) as volgnr
			from empire_staedion_data.bak.[tlt_model_emails]),
EMPIRE_WRKN  ([Code], [User ID])
		as (
SELECT [Code]
			 --R17: geen [User ID] meer
       --,CASE 
       --       WHEN [User ID] = ''				
       --              AND [E-Mail] = ''
       --              THEN upper('STAEDION\' + replace([E-Mail 2], '@staedion.nl', ''))
       --       ELSE CASE 
       --                     WHEN [User ID] = ''
       --                            AND [E-Mail] <> ''
       --                            THEN upper('STAEDION\' + replace([E-Mail], '@staedion.nl', ''))
       --                     ELSE [User ID]
       --                     END
       --       END AS [User ID] -- select *
					, [staedion_inlognaam] as [User ID]							
FROM empire_Data.dbo.[salesperson_purchaser]
WHERE [staedion_inlognaam] <> '')
       --OR [E-Mail] <> ''
       --OR [E-Mail 2] <> '' )
       ,

EMPIRE_res  (No_, [User ID])
	as (select No_, [User ID]
			from empire_Data.dbo.Staedion$Resource
			where [User ID] <> ''),
CTE as 
	(SELECT Personeelsnr, Inlognaam, Empire_wrkn, Empire_Res, Maandsalaris, [Salaris per uur], [Soort arbeidscontract], [Deeltijdfactor], [Werknemersgroep]
				, [KamerNr]	,[Locatie]	,[Limiet goedkeuring],[Personeelsnr manager]
	from		 [empire_staedion_data].[aanvulling].[Werknemers_20190117] ) 

select					[Personeelsnr]								= EMP.employeeid	
								,[Aanhef]											= EMP.salutation					
								,[Burgerlijke status]					= EMP.maritalstatus
								,[Voorletters]								= EMP.initials
								,[Tussenvoegsel]							= EMP.prefixbirthname
								,[Voornaam]										= EMP.firstname
								,[Achternaam]									= EMP.birthname
								,[Roepnaam]										= EMP.nickname
								,[Volledige naam]							= coalesce(EMP.use_fullname, EMP.firstname + isnull(' '+EMP.prefixbirthname,' ')+EMP.birthname)
								,[Geboortedatum]							= EMP.dateofbirth
								,[Datum in dienst]						= EMP.officialdate				
								,[BSN]												= EMP.bsn
				--				,CON.startdate					
								,[Datum Uit Dienst]						= CON.enddate
								,[Reden einde dienstverband]	= CON.endreasonname
								,[Afdeling]										= AFD.orgunitname	
				--				,AFD.orgunit					 
								,[Functie]										= FUN.functionname	
								,[Prive telefoon]							= TEL1.[phoneno]	
								,[Zakelijk telefoon]					= TEL4.[phoneno]	
								,[Zakelijk mobiel]						= TEL10.[phoneno]	
								,[Prive email]								= MAIL1.emailaddress				
								,[Werk email]									= MAIL2.emailaddress	
--								,[Inlognaam]									= isnull('STAEDION\'+ upper(EMP.hrm_inlognaam),'')	
								,[Inlognaam]									= upper('STAEDION\' + replace(MAIL2.emailaddress, '@staedion.nl', ''))
								,[Geslacht]										= EMP.gender
								,EMP_id												= EMP.id 
								,Empire_wrkn									= WRKN.code
								,Empire_res										= RES.No_								
				--				,CON.id =SCO_id
				--				,ORG.manageruserid				
								,[Organisatie niveau 1]				= isnull(ORG.use_org_level_1,'')	
								,[Organisatie niveau 2]				= isnull(ORG.use_org_level_2,'')	
								,Bedrijfsonderdeel						= isnull(ORG.use_org_level_3,'')	
								,[Organisatie niveau 3]				= isnull(ORG.use_org_level_3,'')	
								,[Organisatie niveau 4]				= isnull(ORG.use_org_level_4,'')	
								,[Organisatie niveau 5]				= isnull(ORG.use_org_level_5,'')	
								,[Organisatie niveau 6]				= isnull(ORG.use_org_level_6,'')	
								,[Organisatie niveau 7]				= isnull(ORG.use_org_level_7,'')	
								,[Organisatie niveau 8]				= isnull(ORG.use_org_level_8,'')	
								,[KamerNr]										= coalesce(AFD.kamernummer_value, /* BAK.[KamerNr],*/'')
								,[Locatie]										= coalesce(AFD.vestiging_valuename,/* BAK.[Locatie].*/'')
								,[Limiet goedkeuring]					= coalesce(FUN.approval_limit,BAK.[Limiet goedkeuring],'')
								,[Personeelsnr manager]				= coalesce(ORG.manager_personeelsnr,BAK.[Personeelsnr manager],'')
								,[Leidinggevende]							= isnull(ORG.managerfullname,'')
								,[Kostenplaats]								= isnull(AFD.costcenter,'')
								,[Maandsalaris]								= Coalesce(EMP.hrm_salaris,BAK.[Maandsalaris])
								,[Salaris per uur]						= Coalesce(EMP.hrm_salaris_uur,BAK.[Salaris per uur])
								,[Soort arbeidscontract]			= Coalesce(EMP.Hrm_srt_arb_contr,BAK.[Soort arbeidscontract])
								,Deeltijdfactor								= Coalesce(EMP.Hrm_dlt_fakt,BAK.Deeltijdfactor)
								,Werknemersgroep 							= Coalesce(EMP.hrm_omschrijving,BAK.Werknemersgroep)
								,Bestandsnaam									= BRON.bestandsnaam
								,Tijdstempel									= BRON.tijdstempel
--select * from empire_staedion_data.bak.[tlt_model_employees] where employeeid = 918055
from						EMP
left outer join	CON
on							EMP.id = CON.emp_id
and							CON.volgnr =1
left outer join	AFD
on							CON.id = AFD.sco_id		
and							AFD.volgnr =1
left outer join	FUN
on							CON.id = FUN.sco_id
and							FUN.volgnr =1
left outer join	BRON
on							BRON.volgnr =1
left outer join empire_staedion_data.bak.tlt_model_org_structure as ORG
on							ORG.orgunitid = AFD.orgunit
--and				manager_personeelsnr <> 100918055			-- WORKAROUND dubbele foute regels: zorgden voor dubbeltellingen
left outer join	TEL as TEL1
on							TEL1.emp_id = EMP.id
and							TEL1.phonetypeid = 1
and							TEL1.volgnr =1
left outer join	TEL as TEL4
on							TEL4.emp_id = EMP.id
and							TEL4.phonetypeid = 4
and							TEL4.volgnr =1
left outer join	TEL as TEL10
on							TEL10.emp_id = EMP.id
and							TEL10.phonetypeid = 10
and							TEL10.volgnr =1
left outer join	MAIL as MAIL1
on							MAIL1.emp_id = EMP.id
and							MAIL1.emailtypeid = 1
and							MAIL1.volgnr =1
left outer join	MAIL as MAIL2
on							MAIL2.emp_id = EMP.id
and							MAIL2.emailtypeid = 2
and							MAIL2.volgnr =1
left outer join EMPIRE_WRKN as WRKN
--on							WRKN.[User ID] = isnull('STAEDION\'+ upper(EMP.hrm_inlognaam),'XXXXXX')	
on							WRKN.[User ID] = upper('STAEDION\' + replace(MAIL2.emailaddress, '@staedion.nl', ''))
and							isnull(WRKN.[User ID],'') <> ''
left outer join EMPIRE_res as RES
--on							RES.[User ID] = isnull('STAEDION\'+ upper(EMP.hrm_inlognaam),'XXXXXX')	
on							RES.[User ID] = upper('STAEDION\' + replace(MAIL2.emailaddress, '@staedion.nl', ''))
and							isnull(RES.[User ID],'') <> ''
left outer join CTE as BAK
on							BAK.[Personeelsnr]	= EMP.employeeid	
where						EMP.volgnr = 1
and							datediff(d,isnull(EMP.officialdate,'20010101'), isnull(CON.enddate,'20990101')) >= 0 
and							EMP.employeeid  <> 1008910		-- 1008910 = Pietje Test 
and							EMP.employeeid  <> 1007120    -- 1007120 = Saskia Sukul = uit dienst maar gaf een dubbele WRKN-00921
and							EMP.employeeid  <> 1006870    -- 1006870 = Hessel Rengers = uit dienst , opgevoerd onder ander nr
and							EMP.employeeid  <> 1010190    -- 1010190 = stagiaire, ook opgevoerd onder ander nr: 1009740

--AND							WRKN.code = 'WRKN-01651'


UNION

select					[Personeelsnr]								= 0	
								,[Aanhef]											= null
								,[Burgerlijke status]					= null
								,[Voorletters]								= null
								,[Tussenvoegsel]							= null
								,[Voornaam]										= null
								,[Achternaam]									= null
								,[Roepnaam]										= null
								,[Volledige naam]							= '[Onbekend, nvt]'
								,[Geboortedatum]							= null
								,[Datum in dienst]						= null
								,[BSN]												= null
				--				,CON.startdate					
								,[Datum Uit Dienst]						= null
								,[Reden einde dienstverband]	= null
								,[Afdeling]										= null
				--				,AFD.orgunit					 
								,[Functie]										= null
								,[Prive telefoon]							= null
								,[Zakelijk telefoon]					= null
								,[Zakelijk mobiel]						= null
								,[Prive email]								= null
								,[Werk email]									= null
								,[Inlognaam]									= null
								,[Geslacht]										= null
								,EMP_id												= null
								,Empire_wrkn									= null
								,Empire_res										= null	
				--				,CON.id =SCO_id
				--				,ORG.manageruserid				
								,[Organisatie niveau 1]				= null
								,[Organisatie niveau 2]				= null
								,Bedrijfsonderdeel						= null
								,[Organisatie niveau 3]				= null
								,[Organisatie niveau 4]				= null
								,[Organisatie niveau 5]				= null
								,[Organisatie niveau 6]				= null
								,[Organisatie niveau 7]				= null
								,[Organisatie niveau 8]				= null
								,[KamerNr]										= null
								,[Locatie]										= null
								,[Limiet goedkeuring]					= null
								,[Personeelsnr manager]				= null
								,[Leidinggevende]							= null
								,[Kostenplaats]								= null
								,[Maandsalaris]								= null
								,[Salaris per uur]						= null
								,[Soort arbeidscontract]			= null
								,Deeltijdfactor								= null
								,Werknemersgroep 							= null
								,Bestandsnaam									= 'Aanvulling tbv processen kubus Overig'
								,Tijdstempel									= null




















GO
